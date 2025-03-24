class_name Enemy
extends Area2D
# TODO - Refactor me

#############################
####### REFACTOR AREA #######
#############################
const Stat = CharacterStats.Stat
const AVOIDANCE_MAGNITUDE = 3 ## Magnitude to amplify the avoidance direction to add a little stronger avoidance movement.

@onready var state_machine: StateMachine = %StateMachine
@onready var animation_player = %Spritesheet ## "AnimationPlayer" for the enemy (currently [AnimatedSprite2D])
@onready var death_sound = %DeathSound ## Plays the enemy's dying sound.

var final_direction: Vector2 = Vector2.ZERO ## Final move direction for the enemy (the "output" of the movement component)
var move_dir: Vector2 = Vector2.ZERO ## Primary move direction towards player (the "intent" of the movement component)
var avoidance_dir: Vector2 = Vector2.ZERO ## Movement component for avoiding obstacles, enemies, etc.
var avoidance_weight: float = 0.1
var velocity: Vector2 = Vector2.ZERO ## Velocity [Vector2] of the enemy.
var stats: EnemyStats
var slowed: bool = false

# Values inside the stat block.
# var contact_damage: float
# var attack_damage: float

var player: Player

signal damaged(damage: float)
signal enemy_died(enemy: Enemy)
signal health_depleted()

#############################
const HEALTH_BAR_SCALE = 0.05
const DISPLACEMENT_FRICTION = 120.0
const STUN_MODULATE_COLOR = "0000ff"



var knockback_velocity: Vector2
# var knockback_target: Vector2
var knockback_friction: float = 400.0 # The rate at which knockback decays - should decay rapidly, like the enemy is quickly getting their footing back
var slowed_speed: float = 0.0
var slow_decay_rate: float = 5.0
var avoidance_time: float


# var knocked_back: bool = false
var displaced: bool = false
var stunned: bool = false
var shooting = false
var dead = false

# Signals


var enemy_health_bar_background = preload("res://sprites/frames/enemy_health_bar_background.tres")
var enemy_health_bar = preload("res://sprites/frames/enemy_health_bar_progress_texture.tres")

func _ready() -> void:
	player = GameController.player

## Set up the enemy's stats based on the type from [EnemyStats.EnemyType]
func initialize(statblock: EnemyStats) -> void:
	# Set the stats based on the enemy type
	stats = statblock.get_copy()

	# Retrieve the enemy's vitals from the statblock and set them all up properly.
	name = stats.character_name
	animation_player.sprite_frames = stats.spritesheet
	scale = stats.enemy_scale

	# Initialize the state machine with the [AnimationNames.WALK] animation since all enemies start by pursuing the player.
	state_machine.actor = self
	state_machine.initialize(AnimationNames.WALK)


func _physics_process(delta: float) -> void:
	# TODO - status effect functions. For now simply keep clamping speed if we are slowed.
	if stats.get_stat(Stat.SPEED) < stats.base_speed: 
		stats.set_stat(Stat.SPEED, clampf(stats.speed + slow_decay_rate * delta, 0, stats.base_speed))

func move() -> void:
	if shooting or stunned: return

	global_position += velocity

# Slow the enemy by a percentage of their speed
func apply_slow(slow: float) -> void:
	# Only apply slow if the enemy is not already slowed
	var current_speed = stats.get_stat(Stat.SPEED)
	if current_speed == stats.base_speed: stats.set_stat(Stat.SPEED, current_speed * (1.0 - slow))

# func _is_displaced() -> void:
# 	if displaced: %DisplacementTimer.start()
# 	else: %DisplacementTimer.stop()

## Apply a stun to the enemy and start a timer based on the duration. Modulate the enemy to indicate they are stunned.
func apply_stun(duration: float) -> void:
	stunned = true
	modulate = STUN_MODULATE_COLOR
	var stun_timer = get_tree().create_timer(duration)
	stun_timer.connect("timeout", remove_stun)

## Clear the stun and reset the modulation back to normal (white).
func remove_stun() -> void: 
	stunned = false
	modulate = Color.WHITE

func take_damage(dam: float) -> void:
	stats.subtract_from_stat(Stat.HEALTH, dam)
	emit_signal("damaged", dam)

	# Set the emit direction of the particles to tbe the direct opposite of incoming attack angle (i.e., from the player) with * -1
	var emit_dir = global_position.direction_to(player.global_position) * -1
	%GPUParticles2D.process_material.set_direction(Vector3(emit_dir.x, emit_dir.y, 0))
	%GPUParticles2D.restart()
	%GPUParticles2D.emitting = true

	if stats.get_stat(Stat.HEALTH) <= 0:
		dead = true
		health_depleted.emit()
		enemy_died.emit(self)
		# Spawn an explosion of some kind? use call_deferred if you do
		# Spawn an experience orb
		GameController.spawn_experience_orb(global_position, stats.xp_value)
		if randf() < stats.health_drop_chance: GameController.spawn_health_pickup(global_position)

func apply_knockback(source: Vector2, strength: float) -> void:
	# Calculate the direction from the knockback source to this enemy
	var direction: Vector2 = (global_position - source).normalized()
	# knockback_velocity = direction * strength
	# apply_impulse(direction * strength)

###################
## Updates the enemy's move direction to the player's current position. Use sparringly.
func update_move_dir() -> void: move_dir = global_position.direction_to(player.global_position)

## Helps enemies avoid each other by moving them slightly away from each other and interpolating an avoidance_dir with the move_dir[br]
## TODO: Multi-enemy avoidance?
func _on_enemy_avoidance_area_area_entered(other_enemy:Area2D) -> void:
	if avoidance_dir == Vector2.ZERO: # Only update the avoidance if not currently avoiding another enemy.
		avoidance_dir = global_position.direction_to(other_enemy.global_position) * -1 # Invert the direction so it's moving away from the enemy.
		avoidance_dir *= AVOIDANCE_MAGNITUDE
		avoidance_weight = 0.1 # We only want the enemies to avoid each other slightly.
		# print_debug(name + " is avoiding " + other_enemy.name + " with an avoid_dir of " + str(avoidance_dir))


## When touching the player transition to the IDLE state so the enemy just stands close to them and deals damage.
func _on_body_entered(body:Node2D) -> void:
	if body == GameController.player: 
		state_machine.change_state(AnimationNames.IDLE)

		## If we touch the player we should add a small avoidance direction away from the player so the player doesn't get FULLY mobbed			
		# # Move away from the player (-1) times the magnitude and change the avoidance weight so they don't fully mob but also don't move too far away.
		# avoidance_dir = global_position.direction_to(body.global_position) * -1
		# avoidance_dir *= AVOIDANCE_MAGNITUDE
		# avoidance_weight = 0.5


## Once we stop touching the player we can transition to the walk state.
func _on_body_exited(body:Node2D) -> void:
	if body == GameController.player:
		state_machine.change_state(AnimationNames.WALK)
 		#avoidance_dir = Vector2.ZERO # Reset the avoidance_dir if we stop touching the player