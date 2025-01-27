extends Area2D

var lifetime = 0.0
var max_lifetime: float
var damage: float
var speed: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed = GameController.energy_sword.get_speed()
	damage = GameController.energy_sword.get_damage()
	max_lifetime = GameController.energy_sword.get_lifetime()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Rotate the pivot according to the speed.
	get_parent().rotation += speed * delta
	
	# Track the lifetime and destroy it if it's past the max
	lifetime += delta
	if lifetime >= max_lifetime:
		# Destroy the pivot AND this
		var pivot = get_parent()
		pivot.remove_child(self)
		pivot.queue_free()
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	# Energy swords only die after a time, not on number of hits
	if body != null && not body.is_dead: # If we're using masks property, it should ONLY be an enemy!
		body.take_damage(damage)
