extends ColorRect

@export var node: Node2D
@onready var camera := get_viewport().get_camera_2d()

## TODO - Fix this so it actually works properly. Was broken recently and kind of ehh now.
func set_distortion_center(world_position: Vector2) -> void:
	if camera == null: camera = Camera2D.new()

	# Get the current viewport size
	var viewport_size = get_viewport_rect().size

	# Get the camera's center pos (accounts for smoothing and limits)
	var camera_center = camera.get_screen_center_position()
	
	# Calculate screen position (normalize from 0.0 - 1.0)
	var screen_position: Vector2 = ((world_position - camera_center) * camera.zoom + viewport_size / 2) # Convert world pos to screen coords, then apply camera zoom and center the offset

	# Convert to normalized coords
	var normalized_position = screen_position / viewport_size

	# Make sure material is shader material
	material.set_shader_parameter("center", normalized_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set_distortion_center(GameController.player.global_position)
