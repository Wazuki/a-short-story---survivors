class_name Waldos
extends Weapon

const SLOW_ENABLED_LEVEL = 4
const INNER_RING_LEVEL = 5
# const BASE_DAMAGE = 8.0
# const BASE_SPEED = PI / 2
# # const BASE_COOLDOWN = 1.5
# const BASE_COOLDOWN = 0.5
# const BASE_SCALE = Vector2.ONE
# const SLOW_VALUE = 0.25
# const OVERHAUL_GROWTH_RATE = Vector2(0.3, 0.3)
# #Level up stats
# # const LEVEL_UP_DAMAGE = 1.2
# # const LEVEL_UP_SPEED = 1.2
# # const LEVEL_UP_COOLDOWN = 0.99
# # const LEVEL_UP_SCALE = 1.05


#var weapon_scale: Vector2
var inner_ring
var inner_ring_scale: Vector2
var max_inner_ring_scale : Vector2

var slow_value: float
var overhaul_growth_rate: Vector2
var max_scale: Vector2
var expanding: bool = false

# var inner_ring_enemies = {}

func initialize(data: WeaponData) -> void:
	super.initialize(data)
	# Set any Waldos-specific variables as well!
	slow_value = data.slow_value
	inner_ring_scale = data.inner_ring_scale
	max_inner_ring_scale = data.max_inner_ring_scale
	overhaul_growth_rate = data.overhaul_growth_rate
	max_scale = data.max_scale
	

# Called when the node enters the scene tree for the first time.
# func _ready() -> void:
# 	super._ready()
# 	name = "Spinning Waldos"
# 	weapon_type = Weapon.Type.WALDOS
# 	target_type = TargetType.NONE
# 	description = "Spinning waldos form an area of constant damage."
# 	icon = preload("res://assets/UI/icons/waldos_icon.tres")
# 	# weapon = preload("res://prefabs/weapon.tscn").instantiate()
# 	# add_child(weapon)
# 	# reset()

# func reset() -> void:
# 	set_stats(BASE_DAMAGE, 1.0, 1.0)
# 	reset_timer()
# 	weapon_scale = BASE_SCALE
# 	scale = weapon_scale
# 	first_level_up = true
# 	overhaul_enabled = false
# 	inner_ring_enabled = false
# 	expanding = false
# 	slow_enabled = false
# 	# make sure we hide the waldos since they're special when they reset.
# 	%InnerRing.visible = false
# 	visible = false

func _process(delta: float) -> void:
	super._process(delta)
	# Prune the inner ring dict every n frames to remove dead references. TODO - maybe this should be its own derived weapon for ease of use? hmmm


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	rotation += speed * delta
	#%InnerRing.rotation -= BASE_SPEED * delta * 2 # Have to double this to make it spin opposite due to the parent also spinning

	if is_overhaul_enabled():
		# Burst mode
		if expanding:
			scale = clamp(scale + overhaul_growth_rate * delta, weapon_scale, max_scale)
			if scale.x >= max_scale.x:
				expanding = false
				#print_debug("expand")
		else:
			scale = clamp(scale - overhaul_growth_rate * delta, weapon_scale, max_scale)
			if scale.x <= weapon_scale.x:
				expanding = true
				#print_debug("shrink")

	# Deal damage to every
	if ready_to_fire and not enemies_in_range.is_empty():
		deal_damage(enemies_in_range.values())
		fire_weapon()
		# Check to see if the inner ring is enabled. If so, repeat the process.

		# print_debug("Inner ring dealt damage")
		# Probably unnessary but a safety check for weird corner cases
		#fire_weapon()


## Deal damage to each enemy in range.
func deal_damage(enemies: Array) -> void:
	for e in enemies:
		if e.dead: continue
		e.take_damage(damage)
		if is_slow_enabled(): e.apply_slow(slow_value)


# Level 1: Base: a slowly expanding, passive damage field.
# Level 2: Increase size growth rate and a slight damage boost.
# Level 3: Increase the rotation speed so it covers more area per unit time.
# Level 4: Introduce a secondary effect, like a brief slow on enemies.
# Level 5: New Mechanic: Unlock a secondary ring (or an inner core) that deals extra damage.
# Level 6: Further boost the damage per tick and perhaps add a small shield effect to the player.
# Level 7: Signature Overhaul: The weapon might gain a temporary burst mode, where its rotation speeds up dramatically or its area significantly increases for a short period.

func level_up() -> void:
	# Call the weapon's level up function, then finalize any others that aren't in weapon (projectiles, lifetime, etc)
	super.level_up()
	level += 1
	match level:
		2:
			# Level 2: ~10% damage and scale increase
			damage *= 1.1
			weapon_scale *= 1.25
		3:
			# Level 3: Increased damage frequency (basically Cooldown)
			cooldown *= 0.9
		4:
			# Level 4: Slow enemies on hit
			pass # Handled internally by consts.
		5:
			# Level 5: Add inner core that deals bonus damage
			inner_ring = instantiate_bullet_by_key(SceneKey.BULLET, global_position, SpriteConstants.Z_INDEX.INNER_WALDOS)
			call_deferred("add_child", inner_ring)
			# # Assign the inner ring to the RemoteTransform2D so it'll follow the main waldos without scaling. Defer everything since not in tree yet.
			# %RemoteTransform2D.set_deferred("remote_path", inner_ring.call_deferred("get_path"))
			# #%RemoteTransform2D.remote_path = inner_ring.get_path()
		6:
			# Level 6: Further boost damage frequency and add a shield effect
			cooldown *= 9
			# TODO - shield effect?
		7:
			# Level 7: Signature overhaul - burst mode? 
			# Level up UI handles checking if the weapon is a levle up option. Duh.
			#overhaul_enabled = true
			inner_ring.scale = max_inner_ring_scale
			expanding = true
				
	scale = weapon_scale
	fire_weapon()

## Returns whether or not slow is enabled based on the weapon's level and the defined consts.
func is_slow_enabled() -> bool: return level >= SLOW_ENABLED_LEVEL

# func level_up() -> void:
# 	# Call the weapon's level up function, then finalize any others that aren't in weapon (projectiles, lifetime, etc)
# 	if first_level_up:
# 		first_level_up = false
# 		visible = true
# 		weapon.fire_weapon()
# 		return
	
# 	weapon.level_up(LEVEL_UP_DAMAGE, 1.0, LEVEL_UP_COOLDOWN)
# 	scale *= LEVEL_UP_SCALE
# 	weapon.fire_weapon() # Design this way, the player starts with the cooldown instead of getting a "free shot".



# func get_level_up_text() -> String:
# 	# Need to watch order of operations especially with modulus and concatenating strings!
# 	var level_up_string: String
# 	if first_level_up: level_up_string = "Level 1\nDamage " + str(weapon.damage) + "\nInterval " + str(weapon.cooldown) + "/s";
# 	else: 
# 		level_up_string = "Level " + str(weapon.level) + " -> " + str(weapon.level + 1) + "\n"
# 		level_up_string += "Damage " + str(GameController.round_to_dec(weapon.damage, 2)) + " -> " + str(GameController.round_to_dec(weapon.damage * LEVEL_UP_DAMAGE, 2)) + "\n"
# 		level_up_string += "Size " + str(GameController.round_to_dec(scale.x, 2)) + " -> " + str(GameController.round_to_dec(scale.x * LEVEL_UP_SCALE, 2)) + "\n"
# 		level_up_string += "Interval " + str(GameController.round_to_dec(weapon.cooldown, 2)) + "s -> " + str(GameController.round_to_dec((weapon.cooldown * LEVEL_UP_COOLDOWN),2)) + "s";
		
# 	return level_up_string
