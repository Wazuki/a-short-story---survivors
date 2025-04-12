class_name DrawCircle
extends Node2D
# A Node2D designed to draw a circle att the current pos.
var radius: float ## The radius of the circle to draw.
var pos: Vector2 ## The location to draw the circle.

func _init(r: float = 0, target_pos: Vector2 = Vector2.ZERO) -> void:
	set_params(r, target_pos)

## Sets the radius to float [param r] and queue the object for redraw.
func set_params(r: float, target_pos: Vector2 = Vector2.ZERO) -> void:
	radius = r
	pos = target_pos
	queue_redraw()

func _draw() -> void:
	draw_circle(pos, radius, Color.WHITE, false)
	#print_debug("Drawing circle")