class_name Bullet extends Area2D

# Required parameters of all bullets
var damage: float
var starting_pos: Vector2 ## Our starting pos
var original_z_index: int ## Sprite's layer on the z-index (Ordering)

# Optional parameters
var speed: float ## Some bullets don't move
var target_node: Node2D ## May have a target for an effect
var lifetime: float ## Tracks lifetime of a projectile (if applicable)
var lifetime_dependent: bool = false

# Other Parameters
var affected_areas: Array[Area2D] # Array of bodies that the weapon is affecting. Used to avoid tons of physics calls.


## [b]Set the defaults for the spawned bullet.[/b][br]
## [b]Required:[/b] [code]damage: float, spawn position:Vector2, z-index: SpriteConstants.Z_INDEX[/code] [br]
## [b]Optional:[/b] [code]speed: float, target: Node2D, lifetime: float[/code][br]
func initialize(dmg: float, pos: Vector2, layer_index: int, spd: float = 0.0, target: Node2D = null, projectile_lifetime: float = 0.0, is_lifetime_dependent = false) -> void:
	damage = dmg
	starting_pos = pos
	global_position = starting_pos
	speed = spd
	original_z_index = layer_index
	z_index = original_z_index
	target_node = target
	lifetime = projectile_lifetime # On Lifetime end, Queue_Fre with timer automatically? Function
	lifetime_dependent = is_lifetime_dependent


func _ready() -> void:
	if lifetime_dependent: enable_timer_expiration()

## Automatically kill self on call_deferred() with a timer option, like in instantiate (timer_die = false)
func enable_timer_expiration() -> void:
	# Create the timer, add it to the tree, and connect the signal.
	var timer = get_tree().create_timer(lifetime, false, true) 
	timer.timeout.connect(destroy_self_on_timer_timeout)
	# print_debug("Timer expiration enabled")

## When our timer expires, destroy self on the next proper frame.
func destroy_self_on_timer_timeout() -> void:
	call_deferred("queue_free")
	# print_debug("Destroying " + name)
