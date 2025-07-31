#class_name Enemy
extends Area2D

@onready var nav_agent: NavigationAgent2D = %NavigationAgent2D ## Navigation agent for walking on the navmesh.
@onready var state_machine: StateMachine = %StateMachine ## State machine for handling any enemy states.
@onready var effect_manager: StatusEffectManager = %StatusEffectManager ## Status effect manager for handling status effect system.
@onready var animation_player = %Spritesheet ## "AnimationPlayer" for the enemy (currently [AnimatedSprite2D])
@onready var death_sound = %DeathSound ## Plays the enemy's dying sound.

# var final_direction: Vector2 = Vector2.ZERO ## Final move direction for the enemy (the "output" of the movement component)
var move_dir: Vector2 = Vector2.ZERO ## Primary move direction towards player (the "intent" of the movement component)
var velocity: Vector2 = Vector2.ZERO ## Velocity [Vector2] of the enemy.
var statblock: EnemyData
var stats: Dictionary
#var slowed: bool = false

var attacking = false
var player_in_range: bool = false


var player: Player

signal damaged(damage: float)
signal enemy_died(enemy: Enemy)
signal health_depleted()



# var knockback_velocity: Vector2
# var knockback_target: Vector2
# var knockback_friction: float = 400.0 # The rate at which knockback decays - should decay rapidly, like the enemy is quickly getting their footing back
#var slowed_speed: float = 0.0
#var slow_decay_rate: float = 5.0
# var avoidance_time: float


# var knocked_back: bool = false
var displaced: bool = false
var stunned: bool = false
var dead = false



func _ready() -> void:
	player = GameController.player

## Set up the enemy's stats based on the type from [EnemyStats.EnemyType]
func initialize(data: EnemyData) -> void:
	# Set the z-index of our enemies according to our sprite constants. TODO - different z-index for different enemies?
	z_index = SpriteConstants.Z_INDEX.ENEMY

	# Set the stats based on the enemy type
	statblock = data.get_copy()
	stats = statblock.stat_map.to_dict()
	statblock.base_speed = stats[CharacterData.Stat.SPEED] # Set the base speed to our speed.
	#print_debug("Total stats: " + str(stats.size()) + " vs map: " + str(statblock.stat_map.to_dict().size()))

	# Retrieve the enemy's vitals from the statblock and set them all up properly.
	name = statblock.character_name
	animation_player.sprite_frames = statblock.spritesheet
	scale = statblock.enemy_scale

	# Initialize the state machine with the [AnimationNames.WALK] animation since all enemies start by pursuing the player.
	state_machine.actor = self
	state_machine.initialize(AnimationNames.WALK)

	# If we are an attacking enemy, make sure to set our range (the radius of our collider) and enable monitoring on t he attack range.
	if statblock.is_attacker():
		%AttackRange.monitoring = true
		%AttackRangeCollider.shape.radius = statblock.attack_range
		# print_debug("Attack range: " + str(stats.attack_range) + ", collider rad: " + str(%AttackRangeCollider.shape.radius))
	else: # Prune the attack state since we're not an attacker.
		state_machine.states[AnimationNames.ATTACK].queue_free() # Remove the attack state from enemies that don't attack.
		state_machine.states.erase(AnimationNames.ATTACK) # Don't forget to free up the space in the dictionary.
	# TODO - probably a better way to do this but for now it'll work for our purposes. See you soon, future Ky.

func take_damage(dam: float, effect: StatusEffect = null) -> void:
	stats[CharacterData.Stat.HEALTH] -= dam
	emit_signal("damaged", dam)

	# Set the emit direction of the particles to tbe the direct opposite of incoming attack angle (i.e., from the player) with * -1
	var emit_dir = global_position.direction_to(player.global_position) * -1
	%HurtParticles.process_material.set_direction(Vector3(emit_dir.x, emit_dir.y, 0))
	%HurtParticles.restart()
	%HurtParticles.emitting = true

	if stats[CharacterData.Stat.HEALTH] <= 0:
		dead = true
		health_depleted.emit()
		enemy_died.emit(self)
		# Spawn an explosion of some kind? use call_deferred if you do
		# Spawn an experience orb
		GameController.spawn_experience_orb(global_position, statblock.xp_value)
		if randf() < statblock.health_drop_chance: GameController.spawn_health_pickup(global_position)
	elif effect: # We shouldn't apply effects if the target is dead. TODO - maybe allow knockback?
		effect_manager.apply_effect(effect)


## Spawns the projectile to fly towards the [target_pos: Vector2]
func spawn_projectile(target_pos: Vector2) -> void:
	# Play our attack sequence at the targeting position.
	assert(statblock.attack_prefab != null, "Error! An attacking enemy is missing their prefab to instantiate!")
	var projectile: EnemyBullet = statblock.attack_prefab.instantiate()
	# Initialize the projectile after instantiation and then set it as top level so it doesn't follow the enemy.
	projectile.global_position = global_position
	projectile.initialize(target_pos, statblock.attack_damage)
	add_child(projectile)
	projectile.top_level = true
	
## Handles the enemy movement based on a velocity already adjusted for delta.
func move() -> void:
	if attacking or stunned: return

	global_position += velocity

## Updates the enemy's move direction to the player's current position. Use sparringly.
func update_move_dir() -> void: 
	nav_agent.target_position = player.global_position
	var next_point = nav_agent.get_next_path_position()
	move_dir = (next_point - global_position).normalized()

## When touching the player transition to the IDLE state so the enemy just stands close to them and deals damage.
func _on_body_entered(body:Node2D) -> void:
	if body == GameController.player and not state_machine.current_state is EnemyAttack: 
		state_machine.change_state(AnimationNames.IDLE)


## Once we stop touching the player we can transition to the walk state.
func _on_body_exited(body:Node2D) -> void:
	if body == GameController.player:
		state_machine.change_state(AnimationNames.WALK)

## Mark that the player is in range for state transitions.
func _on_attack_range_body_entered(body:Node2D) -> void:
	if body is Player: player_in_range = true

## When the player exits, mark the player as no longer in range.
func _on_attack_range_body_exited(body: Node2D) -> void:
	if body is Player: player_in_range = false

## Play an attack sound from the attack sound randomizer audiostream.
func play_attack_sound() -> void: %AttackSounds.play()

## Reset the enemy's speed to their base speed from the stat block.
func reset_speed() -> void:
	stats[CharacterData.Stat.SPEED] = statblock.base_speed
