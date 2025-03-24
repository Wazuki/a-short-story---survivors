extends Node2D

# Simple script to follow the player using the built-in damping and expose the mob spawn point.
@export var target: Node2D # Target the camera should follow.
@onready var camera: Camera2D = %MainCamera
@onready var mob_spawn_point: PathFollow2D = %MobSpawnPoint ## PathFollow2D to spawn enemies on screen.

#@export var damping: float = 0.1
#var camera_bounds: Rect2

func _ready() -> void:
	EnemyManager.mob_spawn_point = mob_spawn_point
	#camera_bounds = Rect2(camera.limit_left, camera.limit_top, camera.limit_right, camera.limit_bottom) # Rect2 Constructor is (x, y, width, height). This will make the Rect2 start at a Vector2 pos and stretch to the limits listed.

func _process(_delta: float) -> void:
	if not target: return
	global_position = target.global_position

	#var target_pos = target.global_position
	#var new_pos = global_position.lerp(target_pos, damping)
	# var clamped_position = target_pos.clamp(camera_bounds.position, camera_bounds.position + camera_bounds.size)

