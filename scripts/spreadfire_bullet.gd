extends Area2D

var max_range: float = 1500
var traveled_distance: float = 0
var direction
var speed: float
var damage: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	direction = Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta
	
	traveled_distance += speed * delta
	
	if traveled_distance >= max_range:
		queue_free() # destroy the bulle if itt goes past its max range
	
func set_stats() -> void:
	damage = GameController.spreadfire.get_damage()
	speed = GameController.spreadfire.get_speed()


func _on_body_entered(body: Node2D) -> void:
	# If we hit an enemy, destroy ourselves and deal damage (unless Piercing - TODO?)
	if body != null && not body.is_dead: # If we're using masks property, it should ONLY be an enemy!
		body.take_damage(damage)
	
	queue_free()
