extends Weapon

# Level up unlock consts
const MINI_SLAM_LEVEL = 4
const MINI_SLAM_COUNT = 4
const SLOW_ENABLED_LEVEL = 5

# Slam-specific variables
var slow_value: float
var shockwave_strength: float
var weapon_reduction_scale: float
var weapon_min_scale: Vector2

# Mini-Slam Specific variables
var mini_slam_damage_modifier: float
var mini_slam_offset: float
var mini_slam_scale: Vector2

# var shockwave_time = 0.0
# var max_shockwave_time = 0.0
# var last_shockwave_time = -1.0

# var slow_enabled = false
# var overhaul_enabled: bool = false
var slam_bullet: Bullet # Main slam bullet.
@onready var shockwave_anim_player: AnimationPlayer = $SlamShockwave/ShockwaveAnimPlayer
# @onready var slam_bullet = %SlamBullet as Bullet

func initialize(data: WeaponData) -> void:
	super.initialize(data)
	# Call any remaining specific initialization below.
	slow_value = data.slow_value
	shockwave_strength = data.shockwave_strength
	weapon_reduction_scale = data.weapon_reduction_scale
	weapon_scale = data.weapon_scale
	weapon_min_scale = data.weapon_min_scale
	# Mini-slam specific
	mini_slam_offset = data.mini_slam_offset
	mini_slam_scale = data.mini_slam_scale
	mini_slam_damage_modifier = data.bullet_scene_map.to_dict()[SceneKey.SECONDARY_BULLET].damage_modifier
	# Because this is a melee weapon we need to instantiate the bullet here and add it to the scene tree at ready.
	slam_bullet = instantiate_bullet_by_key(SceneKey.BULLET, global_position, SpriteConstants.Z_INDEX.SLAM) as Bullet



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	add_child(slam_bullet)
	slam_bullet.scale = weapon_scale
	# name = "Slam"
	# weapon_type = Weapon.Type.SLAM
	# description = "A massive slam that deals damage in an area.\n\nShrinks while moving."
	# icon = preload("res://assets/UI/icons/slam_icon.tres")
	# # Reparent the shockwave to be a child of the UI so it affects everything. TODO - this needs a fix and this also doesn't belong here. 
	# TODO - this should ne fixed along with the entire Shockwave.
	var ui_layer = $"/root/GameScene/UI"
	var shockwave: ColorRect = %SlamShockwave
	shockwave.reparent(ui_layer)
	ui_layer.move_child(shockwave, 0)
	shockwave.position = Vector2.ZERO

	# Unecessary - done on slam because it may change.
	# Set the bullet's data from the scene map. - must be done in ready, not init.
	#slam_bullet.set_stats(damage, speed)
	# slam_bullet.get_node("AnimatedSprite2D").connect("animation_finished", _on_slam_animation_finished)
	# reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	# if shockwave_time < max_shockwave_time:
	# 	# Shader speed is about 60 units per second
	# 	var shockwave_speed = 240
	# 	shockwave_time += _delta

	# 	if int(shockwave_time * shockwave_speed) > last_shockwave_time:
	# 		GameController.apply_shockwave_displacement(slam_bullet.attack_origin,shockwave_speed, shockwave_time, 150)
	# 		last_shockwave_time = int(shockwave_time * shockwave_speed) # Store last time we applied the shockwave

	# If the player is moving, slowly scale the weapon down the min size. If not, reset the size to maximum.
	if GameController.player.velocity.length() == 0: slam_bullet.scale = weapon_scale
	else: slam_bullet.scale = slam_bullet.scale.move_toward(weapon_min_scale, weapon_reduction_scale * _delta) # move_towards returns a vector2 - doesn't actually assign it, doi

	if ready_to_fire and not enemies_in_range.is_empty(): slam()


## TODO!!! MAybe tween the animation so it "spreads" outward?! GENIUS
func slam() -> void:
	begin_attack_sequence.emit() # Tell the listeners (Cooldown Panel et al) that we have started attacking.
	# Could be moved to the end of the weapon timer, but shouldn't matter since we end up back here as a result of the timer being reset.
	# Reset the bullet back to its original position so it lines up to the player's position. 
	slam_bullet.set_as_top_level(false)
	slam_bullet.set_stats(damage, speed)
	slam_bullet.global_position = global_position
	# slam_bullet.reparent(self)
	# slam_bullet.scale = scale
	# Only put the weapon on cooldown if we hit something.
	if slam_bullet.slam(global_position): 
		if level >= OVERHAUL_LEVEL: 
			shockwave_anim_player.play(AnimationNames.SHOCKWAVE)
			GameController.apply_shockwave_displacement(slam_bullet.attack_origin, shockwave_strength)
			#max_shockwave_time = shockwave_anim_player.current_animation_length
			#shockwave_time = 0.0
		# weapon.fire_weapon() #  - slam_bullet.get_child(0).sprite_frames.get_frame_texture("default", 9).get_size()) - returns the size of the sprite frame
	# print_debug("Global Pos: " + str(global_position) + " Local Pos: " + str(to_local(GameController.player.global_position)))
	# Spawn slams!
	#slam_count = 0
	#spawn_next_slam()
	# slam()
	#$NextSlamTimer.start()


func spawn_mini_slams() -> void:
	if level < MINI_SLAM_LEVEL: return # Only spawn the mini-slams if we're the appropriate level

	# Spam a new slam in each orthagonal direction, offset by a small amount
	# Only spawn mini-slam when the initial slam ends to represent a "chaning" effect and reduce screen clutter
	# Add an extra cycle for every level past the first.

	var slam_cycles = level - MINI_SLAM_LEVEL + 1 # Spawn extra mini-slams for each level past the cutoff
	var offsets = []
	for i in range(1, slam_cycles + 1):
		var distance = i * mini_slam_offset * slam_bullet.scale.x
		offsets.append(Vector2(distance, 0))
		offsets.append(Vector2(-distance, 0))
		offsets.append(Vector2(0, distance))
		offsets.append(Vector2(0, -distance))
	
	for cycle in range(slam_cycles):
		for s in range(MINI_SLAM_COUNT):
			var new_slam = instantiate_bullet_by_key(SceneKey.SECONDARY_BULLET, global_position, SpriteConstants.Z_INDEX.SLAM) as Bullet
			new_slam.set_stats(damage * mini_slam_damage_modifier, speed)
			# Scale the mini-slams from 0.25-0.65 (clamped) based on the current slam scale and a set minimum.
			var mini_slam_adjusted_scale: float = clampf(mini_slam_offset * (slam_bullet.scale.x / weapon_scale.x), 0.25, mini_slam_scale.x)
			new_slam.scale = Vector2(mini_slam_adjusted_scale, mini_slam_adjusted_scale) # Mini-slams should be affected by the current slam size.
			# new_slam.get_node("AnimatedSprite2D").modulate = Color(1, 0, 0, 1)
			# new_slam.name = "Mini-Slam"
			slam_bullet.add_child(new_slam)
			
			# Set the new slam's position based on the offset
			# new_slam.position = Vector2.ZERO
			new_slam.is_mini_slam = true
			# Calculate the index based on the cycle times the current slam to get the correct offset to stagger the slams
			var index = cycle * MINI_SLAM_COUNT + s
			new_slam.slam(slam_bullet.attack_origin + offsets[index].rotated(slam_bullet.rotation))
			# print_debug("We are at " + str(global_position) + " and spawned a mini slam at " + str(new_slam.global_position + offsets[s]))
		await get_tree().create_timer(0.2).timeout # Add a small delay before the next orthagonal slam


# New fire weapon process
# Slam's size will scale down as the player moves, to a maximum minimum size.
# When stopping (velocity == 0) the slam will scale up to a maximum size.
# Slam should only first when there are enemies in range - effectively "slam_bullet" becomes just part of the controller like Light Blade.

#func slam() -> void:


# Level 1: Base slam: single AOE burst with a fixed radius.
# Level 2: Increase damage by a small percentage and/or slightly enlarge the AOE.
# Level 3: Slightly reduced cooldown or faster animation.
# Level 4: Improved Mechanics: The slam now chains to an extra mini-slam (a quick secondary burst).
# Level 5: Further increase in area and damage, plus a minor debuff (like slowing enemies in the AOE).
# Level 6: A unique tweak like a “shockwave” effect that travels further, extending damage beyond the initial hit.
# Level 7: Signature Overhaul: The final form might spawn multiple mini-slams or leave a lingering damage-over-time area.



func level_up() -> void:
	# Call the weapon's level up function, then finalize any others that aren't in weapon (projectiles, lifetime, etc)			
	super.level_up()
	level += 1
	match level:
		2:
			# ~10% damage increase, 10% size increase
			damage *= 1.1
			weapon_scale *= 1.1
		3:
			# Slightly reduced cooldown or faster animation
			cooldown *= 0.9
		4:
			# Improved Mechanics: The slam now chains to an extra mini-slam (a quick secondary burst)
			pass # Nothing to change here due to consts being used
		5:
			# Further increase in area and damage, plus a minor debuff (like slowing enemies in the AOE)
			damage *= 1.1
			weapon_scale *= 1.1
		# Extra mini-slams at level 6
		# Overaul at level 7

	fire_weapon()

func is_slow_enabled() -> bool:
	return level >= SLOW_ENABLED_LEVEL


# # Handles timing and spawning swords whenever the Weapon timer expires, called on physics process
# func spawn_next_slam() -> void:
# 	# Rotate this pivot towards the target, then spawn new weapons
# 	# look_at(GameController.player.get_closest_target())
# 	if not targeting: 
# 		# look_at(get_global_mouse_position()) # TESTING MOUSE AIM
# 		look_at(GameController.player.get_closest_target())
# 		targeting = true

# 	# look_at(get_viewport().get_mouse_position().rotated(rotation))

# 	# Spawn a new slam, then set its position based on the offset
# 	var new_slam = preload("res://prefabs/slam_bullet.tscn").instantiate()
# 	new_slam.set_stats(weapon.damage, weapon.speed)

# 	add_child(new_slam)
	
# 	var multiplier = slam_count + 1
# 	var y_direction = 1 if multiplier % 2 == 0 else -1
	

# 	# Set the new slam's position based on the offset
# 	# var offset = SLAM_OFFSET * (i + 1) * pow(-1, i)
# 	# "Right" is zero degrees, which means all our spawning needs to be based around going to the positive x axis
# 	# var offset = Vector2(SLAM_OFFSET.x * multiplier, SLAM_OFFSET.y * y_direction)

# 	# Use the pivot's rotation to calculcate the offset in world space
# 	# var offset_distance = Vector2(SLAM_OFFSET.x * multiplier, SLAM_OFFSET.y * y_direction)
# 	# var offset_distance = SLAM_OFFSET * multiplier

# 	# var offset = Vector2(cos(rotation), sin(rotation)) * offset_distance
# 	var offset = Vector2(SLAM_OFFSET.x * multiplier, SLAM_OFFSET.y * y_direction).rotated(rotation)
# 	new_slam.global_position = attack_origin + offset
# 	# print_debug("Offset: " + str(offset))
# 	# Reparent the new slam to GameScene so it won't move with the player.
# 	new_slam.reparent(get_node("/root/GameScene"))

	
# 	# var anim_player: AnimationPlayer = shockwave.get_child(0)
# 	# anim_player.play("Shockwave")
# 	slam_count += 1


# func _on_next_slam_timer_timeout() -> void:
# 	# Spawn the next slam in the chain.
# 	# Rewrite the whole thing so it spawns one slam at a time until we hit max, tehn reset the timer
# 	# Logic: Spawn slam, increment counter, if counter is less than max, reset timer, else reset counter and timer
# 	if slam_count < max_slams:
# 		spawn_next_slam()
# 	else:
# 		# Reset all teh slamming stuff
# 		slam_count = 0
# 		$NextSlamTimer.stop()
# 		targeting = false
# 		weapon.fire_weapon()

# func level_up() -> void:
# 	# Call the weapon's level up function, then finalize any others that aren't in weapon (projectiles, lifetime, etc)
# 	if first_level_up:
# 		first_level_up = false
# 		weapon.fire_weapon()
# 		return

# 	# Only gain a slam every X levels based on the mod
# 	weapon.level_up(LEVEL_UP_DAMAGE, LEVEL_UP_SPEED, LEVEL_UP_COOLDOWN)
# 	# HEY DUMMY increase the level THEN the max slams lmao
# 	max_slams = (max_slams + 1) if (weapon.level % LEVEL_UP_SLAMS_MOD) == 0 else max_slams
	
# 	weapon.fire_weapon() # Design this way, the player starts with the cooldown instead of getting a "free shot".

# Required information, in order:
# name: String, sprite_sheet_ID: String, icon_rotation: float, icon_offset: Vector2, icon_scale: Vector2, info_text: String

# Clean this up, don't need most of it now
# func get_level_up_info() -> Dictionary:
#	var info = {
#		"name" : name,
#		"spritesheet_ID" : SPRITESHEET_ID,
#		"icon_rotation" : ICON_ROTATION,
#		"icon_offset" : ICON_OFFSET,
#		"icon_scale" : ICON_SCALE,
#	}
#	
#	return info


# func get_level_up_text() -> String:
# 	# Need to watch order of operations especially with modulus and concatenating strings!
# 	var new_slams = max_slams + 1 if (weapon.level + 1) % LEVEL_UP_SLAMS_MOD == 0 else max_slams
# 	var level_up_string: String
# 	if first_level_up: level_up_string = "Level 1\nDamage " + str(weapon.damage) + "\nSpeed " + str(weapon.speed) + "/s\nSlams " + str(max_slams) + "s\nCooldown " + str(weapon.cooldown) + "s";
# 	else: 
# 		level_up_string = "Level " + str(weapon.level) + " -> " + str(weapon.level + 1) + "\n"
# 		level_up_string += "Damage " + str(GameController.round_to_dec(weapon.damage, 2)) + " -> " + str(GameController.round_to_dec(weapon.damage * LEVEL_UP_DAMAGE, 2)) + "\n"
# 		level_up_string += "Speed " + str(GameController.round_to_dec(rad_to_deg(weapon.speed), 2)) + " -> " + str(GameController.round_to_dec(rad_to_deg(weapon.speed * LEVEL_UP_SPEED),2)) + "\n"
# 		level_up_string += "Slams " + str(max_slams) + "s -> " + str(new_slams) + "s\n"
# 		level_up_string += "Cooldown " + str(GameController.round_to_dec(weapon.cooldown, 2)) + "s -> " + str(GameController.round_to_dec((weapon.cooldown * LEVEL_UP_COOLDOWN),2)) + "s";
		
# 	return level_up_string
