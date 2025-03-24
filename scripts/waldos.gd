extends Weapon

const BASE_DAMAGE = 8.0
const BASE_SPEED = PI / 2
# const BASE_COOLDOWN = 1.5
const BASE_COOLDOWN = 0.5
const BASE_SCALE = Vector2.ONE
const SLOW_VALUE = 0.25
const OVERHAUL_GROWTH_RATE = Vector2(0.3, 0.3)
#Level up stats
# const LEVEL_UP_DAMAGE = 1.2
# const LEVEL_UP_SPEED = 1.2
# const LEVEL_UP_COOLDOWN = 0.99
# const LEVEL_UP_SCALE = 1.05


var icon: AtlasTexture = preload("res://sprites/frames/waldos_icon.tres")

var weapon_scale: Vector2
var slow_enabled: bool = false
var inner_ring_enabled: bool = false
var overhaul_enabled: bool = false
var expanding: bool = false
var max_scale = Vector2(3,3)

var inner_ring_enemies = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	name = "Spinning Waldos"
	weapon_type = Weapon.Type.WALDOS
	target_type = TargetType.NONE
	description = "Spinning waldos form an area of constant damage."
	# weapon = preload("res://prefabs/weapon.tscn").instantiate()
	# add_child(weapon)
	# reset()

func reset() -> void:
	set_stats(BASE_DAMAGE, 1.0, 1.0)
	reset_timer()
	weapon_scale = BASE_SCALE
	scale = weapon_scale
	first_level_up = true
	overhaul_enabled = false
	inner_ring_enabled = false
	expanding = false
	slow_enabled = false
	# make sure we hide the waldos since they're special when they reset.
	%InnerRing.visible = false
	visible = false

func _process(delta: float) -> void:
	super._process(delta)
	# Prune the inner ring dict every n frames to remove dead references. TODO - maybe this should be its own derived weapon for ease of use? hmmm
	if GameController.global_frame_count % ENEMY_CLEANUP_FRAME_OFFSET == 0 and not inner_ring_enemies.is_empty(): 
		var cleaned_array = inner_ring_enemies.values().filter(is_instance_valid)
		inner_ring_enemies.clear()
		for e in cleaned_array: inner_ring_enemies.set(e.get_instance_id(), e)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	rotation += BASE_SPEED * delta
	%InnerRing.rotation -= BASE_SPEED * delta * 2 # Have to double this to make it spin opposite due to the parent also spinning

	if overhaul_enabled:
		# Burst mode
		if expanding:
			scale = clamp(scale + OVERHAUL_GROWTH_RATE * delta, weapon_scale, max_scale)
			if scale.x >= max_scale.x:
				expanding = false
				#print_debug("expand")
		else:
			scale = clamp(scale - OVERHAUL_GROWTH_RATE * delta, weapon_scale, max_scale)
			if scale.x <= weapon_scale.x:
				expanding = true
				#print_debug("shrink")

	%InnerRing.scale = Vector2(0.5, 0.5) # The inner ring should always be a fixed starting size.

	# Deal damage to every
	if ready_to_fire and not enemies_in_range.is_empty():
		deal_damage(enemies_in_range.values())
		fire_weapon()
		# Check to see if the inner ring is enabled. If so, repeat the process.
		if inner_ring_enabled and not inner_ring_enemies.is_empty():
			deal_damage(inner_ring_enemies.values()) # Pass the entire array of values (our actual enemies) into the adamage function.
		# print_debug("Inner ring dealt damage")
		# Probably unnessary but a safety check for weird corner cases
		#fire_weapon()

## Adds the enemy to the inner ring dict while within range.
func _on_inner_ring_entered(area: Area2D) -> void:
	if area is Enemy and inner_ring_enabled: inner_ring_enemies.set(area.get_instance_id(), area)

## Removes the enemy from the inner ring dict when they leave the range.
func _on_inner_ring_exited(area: Area2D) -> void:
	if area is Enemy and inner_ring_enabled:
		if inner_ring_enemies.has(area):
			inner_ring_enemies.erase(area)

## Deal damage to each enemy in range.
func deal_damage(enemies: Array) -> void:
	for e in enemies:
		e.take_damage(damage)
		if slow_enabled: e.apply_slow(SLOW_VALUE)


# Level 1: Base: a slowly expanding, passive damage field.
# Level 2: Increase size growth rate and a slight damage boost.
# Level 3: Increase the rotation speed so it covers more area per unit time.
# Level 4: Introduce a secondary effect, like a brief slow on enemies.
# Level 5: New Mechanic: Unlock a secondary ring (or an inner core) that deals extra damage.
# Level 6: Further boost the damage per tick and perhaps add a small shield effect to the player.
# Level 7: Signature Overhaul: The weapon might gain a temporary burst mode, where its rotation speeds up dramatically or its area significantly increases for a short period.

func level_up() -> void:
	# Call the weapon's level up function, then finalize any others that aren't in weapon (projectiles, lifetime, etc)
	if first_level_up:
		first_level_up = false
		visible = true
		%InnerRing.visible = false
	else:
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
				slow_enabled = true
			5:
				# Level 5: Add inner core that deals bonus damage
				%InnerRing.visible = true
				inner_ring_enabled = true
			6:
				# Level 6: Further boost damage frequency and add a shield effect
				cooldown *= 9
				# TODO - shield effect
			7:
				# Level 7: Signature overhaul - burst mode? 
				# Level up UI handles checking if the weapon is a levle up option. Duh.
				overhaul_enabled = true
				expanding = true
				
	scale = weapon_scale
	super.level_up()
	fire_weapon()

func get_level_up_text() -> String:
	if first_level_up: return description
	else:
		match level + 1:
			2:
				return "Increased damage and size."
			3:
				return "Increased damage frequency."
			4:
				return "Slow enemies on hit."	
			5:
				return "Inner core deals increased damage."
			6:
				return "Increased damage frequency and shield effect."
			7:
				return "Signature: Burst Mode."
	return "Error! If you got here notify someone who isn't me."

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
