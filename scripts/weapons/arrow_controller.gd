extends Weapon

# # Base Weapon stats
# const BASE_DAMAGE = 2.0
# const BASE_SPEED = 500.0
# const BASE_PIERCE = 1
# const BASE_COOLDOWN = 1.75
# const BASE_RANGE = 750.0

# #Level up stats
# const LEVEL_UP_DAMAGE = 1.15
# const LEVEL_UP_SPEED = 1.025
# const LEVEL_UP_PIERCE_MOD = 2
# const LEVEL_UP_COOLDOWN = 0.98

# Other Values
# Level 1: Base: a single, piercing projectile with moderate damage.
# Level 2: Increase projectile speed and a small damage bonus.
# Level 3: Add a slight homing or tracking feature (or improve targeting efficiency).
# Level 4: Enhance piercing (e.g., an arrow can hit one additional enemy).
# Level 5: New Mechanic: Introduce a chance for a double shot (or a secondary arrow fires automatically).
# Level 6: Improve the tracking further, maybe add a visual cue for critical hits.
# Level 7: Signature Overhaul: The arrow becomes “charged” after a brief pause, delivering a burst of damage or even splitting into multiple projectiles on impact.

# const SMALL_ARROW_SIZE: Vector2 = Vector2(0.5, 0.5)
# Variables other Weapons DON'T have
# Arrow consts
const DOUBLE_SHOT_LEVEL = 5

#  Arrow-specific variables
var max_range: float
var pierce: int
var pierce_increase_mod: int
var double_shot_chance: float
var mini_arrow_scale: Vector2

# var ready_to_fire

# # Called when the node enters the scene tree for the first time.
# func _ready() -> void:
# 	super._ready()
# 	name = "Arrow"
# 	weapon_type = Weapon.Type.ARROW
# 	target_type = TargetType.HIGHEST_HP
# 	description = "A single piercing projectile with moderate damage."
# 	icon = preload("res://assets/UI/icons/arrow_icon.tres")
# 	# weapon = preload("res://prefabs/weapon.tscn").instantiate()
# 	# add_child(weapon)
# 	# reset()

func initialize(data: WeaponData) -> void:
	super.initialize(data)
	# Also initialize weapon-specific variables
	max_range = data.max_range
	pierce = data.pierce
	pierce_increase_mod = data.pierce_increase_mod
	double_shot_chance = data.double_shot_chance
	mini_arrow_scale = data.mini_arrow_scale


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	# Fire the arrow if we can.
	arrow()
		

	
# func reset() -> void: 
# 	set_stats(BASE_DAMAGE, BASE_SPEED, BASE_COOLDOWN)
# 	reset_timer()
# 	pierce = BASE_PIERCE
# 	first_level_up = true
# 	double_shot = false
# 	double_shot_chance = 0
# 	overhaul_split_enabled = false
	

# Fire the weapon, using the a V2 target
func arrow() -> void:
	# new fire algo - set angle every time, removed needless if. If bullets aren't angling look here first!
	if ready_to_fire and highest_hp_enemy_in_range != null: # Check to see if player actually has target
		spawn_arrow(highest_hp_enemy_in_range)
		if double_shot():
			# Add a small delay before firing the second arrow
			await get_tree().create_timer(0.25).timeout
			spawn_arrow(enemies_in_range.values().pick_random(), mini_arrow_scale) # Double-shot arrows should be a little smaller

		fire_weapon()

func spawn_arrow(target: Node2D, arrow_size: Vector2 = Vector2.ONE) -> void:
	var new_arrow = instantiate_bullet_by_key(SceneKey.BULLET, global_position, SpriteConstants.Z_INDEX.ARROW, target)
	# new_arrow.initialize(damage, speed, BASE_RANGE, pierce) # TODO - Range increase with level?
	new_arrow.scale = arrow_size

	# Enable splitting if level 7 has been reached (enabling the overhaul). Small arrows shouldn't split.
	if is_overhaul_enabled() && arrow_size == Vector2.ONE: new_arrow.splittable = true

	# Set the arrow's global position to the player's position + offset
	look_at(target.global_position) # Rotate the pivot, not the arrow.
	#call_deferred("add_child",new_arrow) # Add the arrow to the scene
	WeaponManager.add_child(new_arrow) # Add the new arrow to the child of the WeaponManager (has no transform inheritance)
	# new_arrow.call_deferred("reparent", get_node("/root/GameScene")) # Reparent the new bullet to GameScene so it won't move with the player.
	# new_arrow.reparent(get_node("/root/GameScene")) # Reparent the new bullet to GameScene so it won't move with the player.
	%ArrowSounds.play()

func spawn_split_arrows(spawn_pos: Vector2) -> void:
	# Spawn 8 split arrows when killing a target.
	for a in 8:
		var new_arrow = instantiate_bullet_by_key(SceneKey.SECONDARY_BULLET, spawn_pos, SpriteConstants.Z_INDEX.ARROW)
		# new_arrow.initialize(damage / 2, speed, BASE_RANGE, pierce)
		new_arrow.scale = mini_arrow_scale # Set the mini arrow's scale directly.
		# These calls MUST be deferred because enemies die during the physics process and we can only perform these during idle time.
		WeaponManager.call_deferred("add_child", new_arrow) # Add the new arrow to the child of the WeaponManager (has no transform inheritance)
		new_arrow.call_deferred("set_arrow_angle", a*45) # Set the arrow's angle based on our current iteration index.
		#print_debug("New arrow speed: " + str(new_arrow.speed))
		# Add the arrows to the scene, then angle them based on the current count.__find_method_line_number_in_script
		# call_deferred("add_child", new_arrow)

		#new_arrow.set_arrow_angle(a*45)
		# new_arrow.call_deferred("reparent", get_node("/root/GameScene"))
		# new_arrow.reparent(get_node("/root/GameScene"))
		#new_arrow.call_deferred("set_global_position", spawn_pos)
		#new_arrow.call_deferred("set_rotation_degrees", a * 45)
		#new_arrow.global_position = spawn_pos
		#new_arrow.global_rotation_degrees = a * 45 # 45 degrees to make an 8-way attack

# Other Values
# Level 1: Base: a single, piercing projectile with moderate damage.
# Level 2: Increase projectile speed and a small damage bonus.
# Level 3: Add a slight homing or tracking feature (or improve targeting efficiency).
# Level 4: Enhance piercing (e.g., an arrow can hit one additional enemy).
# Level 5: New Mechanic: Introduce a chance for a double shot (or a secondary arrow fires automatically).
# Level 6: Improve the tracking further, maybe add a visual cue for critical hits.
# Level 7: Signature Overhaul: The arrow becomes “charged” after a brief pause, delivering a burst of damage or even splitting into multiple projectiles on impact.

func level_up() -> void:
	# Call the weapon's level up function, then finalize any others that aren't in weapon (projectiles, lifetime, etc)
	super.level_up()
	level += 1
	match level:
		2:
			# Level 2: Increase projectile speed and a small damage bonus.
			damage += 10
			speed += 250.0
		3:
			# Level 3: Add a slight homing or tracking feature (or improve targeting efficiency).
			cooldown = 0.25
			# TODO - tracking implementation?
		4:
			# Level 4: Enhance piercing (e.g., an arrow can hit one additional enemy).
			pierce = 2		

		5:
			# Level 5: New Mechanic: Introduce a chance for a double shot (or a secondary arrow fires automatically).
			#double_shot = true
			double_shot_chance = 0.25
		6:
			# Level 6: Improve the tracking further, maybe add a visual cue for critical hits.
			crit_chance = 0.25
			crit_mod = 1.5
			# Level 7: Split the arrow when killing an enemy.
			# Level up UI handles checking if the weapon is a levle up option. Duh.
			#overhaul_split_enabled = true
				

	fire_weapon()

## Determines whether to fire a double shot based on the current level and on the double shot chance.
func double_shot() -> bool: 
	if level < DOUBLE_SHOT_LEVEL: return false
	return randf() <= double_shot_chance


# Old level_up function
#func level_up() -> void:
	# Call the weapon's level up function, then finalize any others that aren't in weapon (projectiles, lifetime, etc)
	#if first_level_up:
	#	first_level_up = false
	#	weapon.fire_weapon()
	#	return
	
	#weapon.level_up(LEVEL_UP_DAMAGE, LEVEL_UP_SPEED, LEVEL_UP_COOLDOWN)
	#pierce = (pierce + 1) if (weapon.level % LEVEL_UP_PIERCE_MOD) == 0 else pierce
	
	#weapon.fire_weapon() # Design this way, the player starts with the cooldown instead of getting a "free shot".

# Old get_level_up_text
#func get_level_up_text() -> String:
	# Need to watch order of operations especially with modulus and concatenating strings!
	#var new_pierce = pierce + 1 if (weapon.level + 1) % LEVEL_UP_PIERCE_MOD == 0 else pierce
	#var level_up_string: String
	#if first_level_up: level_up_string = "Level 1\nDamage " + str(weapon.damage) + "\nPieceing " + str(pierce) + "\nSpeed " + str(weapon.speed) + "\nCooldown " + str(weapon.cooldown)+ "s";
	#else: 
	#	level_up_string = "Level " + str(weapon.level) + " -> " + str(weapon.level + 1) + "\n"
	#	level_up_string += "Damage " + str(GameController.round_to_dec(weapon.damage, 2)) + " -> " + str(GameController.round_to_dec(weapon.damage * LEVEL_UP_DAMAGE, 2)) + "\n"
	#	level_up_string += "Piercing " + str(pierce) + " -> " + str(new_pierce) + "\n"
	#	level_up_string += "Speed " + str(GameController.round_to_dec(weapon.speed, 2)) + " -> " + str(GameController.round_to_dec(weapon.speed * LEVEL_UP_SPEED, 2)) + "\n"
	#	level_up_string += "Cooldown " + str(GameController.round_to_dec(weapon.cooldown, 2)) + "s -> " + str(GameController.round_to_dec((weapon.cooldown * LEVEL_UP_COOLDOWN),2)) + "s";
		
	#return level_up_string
