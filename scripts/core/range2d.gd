class_name Range2D
extends Area2D
## A component class for range colliders for seeing targets that are in range

# TODO

@export var collider: CollisionShape2D ## The collider used for determining range

func _ready() -> void:
	assert(get_child_count() != 0, "Error! Range2D collider does not have a collision shape! Owner: " + owner.name)

## Set's the radius of the collision shape to [param radius]
func set_range(radius: float) -> void:
	collider.shape.radius = radius


