class_name Bullet extends Area2D


var weapon: Weapon ## The weapon that spawned this bullet
# Weapon-derived attributes
var damage: float
var speed: float ## Some bullets don't move
var starting_pos: Vector2 ## Our starting pos
# var original_z_index: int ## Sprite's layer on the z-index (Ordering)

# Instantiated Attirbutes
var target_node: Node2D ## May have a target for an effect
var lifetime: float ## Tracks lifetime of a projectile (if applicable)
var lifetime_dependent: bool = false

# Other Parameters
var affected_areas: Array[Area2D] # Array of bodies that the weapon is affecting. Used to avoid tons of physics calls.


## [b]Set the defaults for the spawned bullet.[/b][br]
## [b]Required:[/b] [code]damage: float, spawn position:Vector2, z-index: SpriteConstants.Z_INDEX[/code] [br]
## [b]Optional:[/b] [code]speed: float, target: Node2D, lifetime: float[/code][br]
func initialize(spawning_weapon: Weapon, pos: Vector2, sprite_z_index: int, target: Node2D = null, projectile_lifetime: float = 0.0, is_lifetime_dependent = false) -> void:
	weapon = spawning_weapon

	# Weapon-derived attributes
	damage = weapon.damage
	speed = weapon.speed

	# Instantiated attributes
	starting_pos = pos
	global_position = starting_pos
	z_index = sprite_z_index
	target_node = target
	lifetime = projectile_lifetime # Automatically destroys self after this time if lifetime_dependent
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
