class_name BaseEnemy
extends Area2D
## The base enemy class/scene to be used for an inherited scene by more advanced enemies.

# @onready vars for base enemy components
@onready var animation_player := %AnimationPlayer ## The animation player that plays animations from [AnimationNames]
@onready var hurt_particles := %HurtParticles ## The particle emitter that emits when the enemy suffers damage.
@onready var sprite_root := %SpriteRoot ## The root for the spritesheet, used to animate a variety of movement effects.
@onready var spritesheet := %Spritesheet ## The actual spritesheet as an [AnimatedSprite2D]

@onready var death_sound := %DeathSound ## [AudioStreamPlayer2D] for the sound of the enemy dying.
@onready var attack_sounds := %AttackSounds ## [AudioStreamPlayer2D] for the sound(s) of enemies attacking, if applicable.

@onready var nav_agent := %NavAgent ## The [NavigationAgent2D] used to calculate enemy movement.
@onready var state_machine := %StateMachine ## The [EnemyStateMachine] that handles enemy states and contains all enemy states.
@onready var effect_manager := %StatusEffectManager ## The [StatusEffectManager] that handles enemy status effect and applies them accordingly.

var stats: Stats ## The stats object that tracks the enemy's statistics. Need .new() called with a [StatsData] object
var dead = false ## Determines if the enemy is dead or not. Used to prevent further damage and movement.

# Movement logic variables
var move_dir: Vector2 = Vector2.ZERO ## The normalized vector that our enemy will move in
var velocity: Vector2 = Vector2.ZERO ## The velocity applied to the enemy to move them over delta
var contact_damage: float ## The amount of damage done (over 1 second) to the player when touching this enemy.

var is_attacker := false ## Determines if the enemy is an attacker. TODO - remove this maybe for better component work?
# Attacking logic variables
var player_in_range: bool = false ## Determines if the player is currently in range of the enemy's weapon range collider. 

# Drop variables
var xp_value: float = 0.0 ## The amount of experience this enemy is worth.
var health_drop_chance: float = 0.0 ## The chance for an enemy to drop a health pickup when defeated.

# func _ready() -> void:
# 	#super._ready()
# 	#assert(stats != null, "Error! Stats is null! Must call initialize(data) befor adding the enemy to the scene tree!")
# 	# Connect our stats signals to react to when the enemy takes damage or dies
# 	#stats.damaged.connect(damaged)
# 	#stats.defeated.connect(defeated)

## Initialize the enemy based on the [param data] [EnemyData] object, retrieving the stats from our resource.
func initialize(data: EnemyData) -> void:
	# Initialize the stats and connect our signals
	stats = Stats.new(data.stats)
	stats.damaged.connect(damaged)
	stats.defeated.connect(defeated)

	name = data.character_name
	#spritesheet.sprite_frames = data.spritesheet
	scale = data.enemy_scale

	xp_value = data.xp_value
	contact_damage = data.contact_damage
	health_drop_chance = data.health_drop_chance

	# Initialize the state machine with the [AnimationNames.WALK] animation since all enemies start by pursuing the player.
	state_machine.actor = self
	state_machine.initialize(AnimationNames.WALK)

	# If we are an attacking enemy, make sure to set our range (the radius of our collider) and enable monitoring on t he attack range.
	if data.is_attacker():
		%AttackRange.monitoring = true
		%AttackRange.set_range(data.attack_range)
		# print_debug("Attack range: " + str(stats.attack_range) + ", collider rad: " + str(%AttackRangeCollider.shape.radius))
	else: # Prune the attack state since we're not an attacker.
		state_machine.states[AnimationNames.ATTACK].queue_free() # Remove the attack state from enemies that don't attack.
		state_machine.states.erase(AnimationNames.ATTACK) # Don't forget to free up the space in the dictionary.
		# Prune the AttackRange component as well since it isn't needed.
		%AttackRange.queue_free()

## Handles movement based on a velocity already adjusted for delta.
func move() -> void: global_position += velocity

## Updates the enemy's move direction to the player's current position. Use sparringly.
func update_move_dir() -> void: 
	nav_agent.target_position = GameController.player.global_position
	var next_point = nav_agent.get_next_path_position()
	move_dir = (next_point - global_position).normalized()

func take_damage(value: float, effect: StatusEffect = null) -> void:
	# Call the stats take damage function to apply the damage and check for death.
	stats.apply_damage(value)
	if effect != null: effect_manager.apply_effect(effect) # Add the effect to the enemy if applicable.
	# TODO - we should probably be targeting hte stats directly, this is just effectively a wrapper for the stats object since it will emit the damaged signal and send us t o damaged() anyway

## Handles for when the enemy takes damage. Emits hurt particles and emits signals to the EventBus as appropriate.
func damaged(value: float) -> void:
	# Set the emit direction of the particles to tbe the direct opposite of incoming attack angle (i.e., from the player) with * -1
	var emit_dir = global_position.direction_to(GameController.player.global_position) * -1
	%HurtParticles.process_material.set_direction(Vector3(emit_dir.x, emit_dir.y, 0))
	%HurtParticles.restart()
	%HurtParticles.emitting = true

	# Tell the EventBus we took value damage
	Events.enemy_damaged.emit(value)
	#print_debug("ouch!" + str(value))

## Handles when the enemy has been killed.
func defeated() -> void:
	dead = true
	Events.enemy_defeated.emit(self)
	Events.spawn_experience.emit(global_position, xp_value)


## When touching the player transition to the IDLE state so the enemy just stands close to them and deals damage.
func _on_body_entered(_body: Player) -> void:
	if not state_machine.current_state is EnemyAttack: 
		state_machine.change_state(AnimationNames.IDLE)

## Once we stop touching the player we can transition to the walk state.
func _on_body_exited(_body: Player) -> void:
	if not state_machine.current_state is EnemyAttack:
		state_machine.change_state(AnimationNames.WALK)

## Play an attack sound from the attack sound randomizer audiostream.
func play_attack_sound() -> void: %AttackSounds.play()
