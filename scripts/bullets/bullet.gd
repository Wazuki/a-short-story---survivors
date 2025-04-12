class_name Bullet extends Area2D

var weapon: Weapon ## The weapon that spawned this bullet
var bullet_name: String
# Weapon-derived attributes
var damage: float
var damage_modifier: float = 1.0 ## The damage modifier for this bullet. Used for scaling damage with a variety of effects.
var damage_cooldown: float = 0.0 ## How often the bullet will deal damage to the target if applicable.
var speed: float ## Uses the bullet's own speed instead of the weapon speed as they may serve different functions.
var starting_pos: Vector2 ## Our starting pos
# var original_z_index: int ## Sprite's layer on the z-index (Ordering)

# Instantiated Attirbutes
var target_node: Node2D ## May have a target for an effect
var lifetime: float = 0.0 ## Tracks lifetime of a projectile (if applicable). 0 = no lifetime dependency
# var lifetime_dependent: bool = false

# Other Parameters
var affected_areas: Dictionary ## Dictionary [<instance ID, Enemy>] of bodies that the weapon is affecting. Used to avoid tons of physics calls.


## [b]Set the static config for the spawned bullet.[/b][br]
## [b]Required:[/b] [code]spawning_weapon: Weapon, data: BulletData spawn position:Vector2, z-index: SpriteConstants.Z_INDEX[/code] [br]
## [b]Optional:[/b] [code]target: Node2D[/code][br]
func initialize(spawning_weapon: Weapon, data: BulletData, spawn_pos: Vector2, sprite_z_index: int, target: Node2D = null) -> void:
	weapon = spawning_weapon

	# Weapon-derived attributes
	damage = weapon.damage
	# BulletData attributes
	bullet_name = data.name
	damage_modifier = data.damage_modifier
	damage_cooldown = data.damage_cooldown
	speed = data.speed 
	lifetime = data.lifetime # Automatically destroys self after this time if lifetime_dependent
	# Instantiated attributes
	starting_pos = spawn_pos
	global_position = starting_pos
	z_index = sprite_z_index
	target_node = target


func _ready() -> void:
	name = bullet_name # Name assignment requires the node to be in the scene tree
	if lifetime > 0.0: enable_timer_expiration()

	# if bullet_name: print_debug("Loaded " + name)
	# else: print_debug("Loaded " + name + " which had no bullet name.")

## Deal damage to a target based on the damage modifier of the bullet and the damage of the weapon.[br]
## Includes a check to make sure the target is currently a valid instance.
func damage_target(target: Variant, effect: StatusEffect = null) -> bool:
	if is_instance_valid(target) and not target.dead:
		target.take_damage(weapon.damage_calc() * damage_modifier, effect)
		#print_debug("Dealt " + str(weapon.damage_calc() * damage_modifier) + " damage to " + target.name)
		return true
	#else: print("Error! validity: " + str(is_instance_valid(target)) + ", dead: " + str(target.dead))
	return false

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
