extends Node2D

# Simple script to follow the player using the built-in damping and expose the mob spawn point.
@export var target: Node2D # Target the camera should follow.
@onready var camera: Camera2D = %MainCamera
@onready var mob_spawn_point: PathFollow2D = %MobSpawnPoint ## PathFollow2D to spawn enemies on screen.

var shake_fade = 5.0 ## The speed at which the shake fades
var shake_strength = Vector2.ZERO

#@export var damping: float = 0.1
#var camera_bounds: Rect2

func _ready() -> void:
	EnemyManager.mob_spawn_point = mob_spawn_point
	#GameController.game_ended.connect(snap_to_target_start_pos)
	#camera_bounds = Rect2(camera.limit_left, camera.limit_top, camera.limit_right, camera.limit_bottom) # Rect2 Constructor is (x, y, width, height). This will make the Rect2 start at a Vector2 pos and stretch to the limits listed.

func _physics_process(delta: float) -> void:
	if not target or not GameController.game_active: return
	global_position = target.global_position

	# If we have a shake value apply it to the camera, fading over shake_fade speed.
	if shake_strength != Vector2.ZERO:
		shake_strength = shake_strength.lerp(Vector2.ZERO, shake_fade * delta)
		#shake_strength.x = lerpf(shake_strength.x, 0, shake_fade * delta)

		camera.offset = random_offset()
	#var target_pos = target.global_position
	#var new_pos = global_position.lerp(target_pos, damping)
	# var clamped_position = target_pos.clamp(camera_bounds.position, camera_bounds.position + camera_bounds.size)

## Snap the camera to the target's position.
func snap_to_target_start_pos() -> void: global_position = target.global_position

## Applies a shake to the camera based on the passed Vector2
func apply_camera_shake(strength: Vector2) -> void:
	shake_strength = strength

func random_offset() -> Vector2:
	var x_offset = randf_range(-shake_strength.x, shake_strength.x)
	var y_offset = randf_range(-shake_strength.y, shake_strength.y)
	return Vector2(x_offset, y_offset)
