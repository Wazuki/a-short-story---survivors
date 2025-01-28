extends Marker2D

const BASE_DAMAGE = 5.0
const BASE_SPEED = 1.0
const BASE_COOLDOWN = 2.5
const BASE_SLAMS = 1

#Level up stats
const LEVEL_UP_DAMAGE = 1.1
const LEVEL_UP_SPEED = 1.01
const LEVEL_UP_COOLDOWN = 0.99
const LEVEL_UP_SLAMS_MOD = 5

#Other Values
const SLAM_OFFSET = Vector2(20, -10) # PREV (-30, -30), then (-20, -10)
var max_slams: int = 1
var slam_count: int = 0
var targeting: bool = false
var attack_origin: Vector2

var icon: AtlasTexture = preload("res://sprites/frames/slam_icon.tres")

var first_level_up

var weapon

# TODO - knockback?

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	name = "Slam"
	weapon = preload("res://prefabs/weapon.tscn").instantiate()
	add_child(weapon)
	# reset()

func reset() -> void:
	max_slams = BASE_SLAMS
	# print_debug("Slam reset")
	weapon.set_stats(BASE_DAMAGE, BASE_SPEED, BASE_COOLDOWN)
	weapon.reset_timer()

	first_level_up = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if weapon.ready_to_fire && not targeting:
		# Spawn slams!
		slam_count = 0
		attack_origin = global_position
		spawn_next_slam()
		$NextSlamTimer.start()

# Handles timing and spawning swords whenever the Weapon timer expires, called on physics process
func spawn_next_slam() -> void:
	# Rotate this pivot towards the target, then spawn new weapons
	# look_at(GameController.player.get_closest_target())
	if not targeting: 
		# look_at(get_global_mouse_position()) # TESTING MOUSE AIM
		look_at(GameController.player.get_closest_target())
		targeting = true

	# look_at(get_viewport().get_mouse_position().rotated(rotation))

	# Spawn a new slam, then set its position based on the offset
	var new_slam = preload("res://prefabs/slam_bullet.tscn").instantiate()
	new_slam.set_stats(weapon.damage, weapon.speed)

	add_child(new_slam)
	
	var multiplier = slam_count + 1
	var y_direction = 1 if multiplier % 2 == 0 else -1
	

	# Set the new slam's position based on the offset
	# var offset = SLAM_OFFSET * (i + 1) * pow(-1, i)
	# "Right" is zero degrees, which means all our spawning needs to be based around going to the positive x axis
	# var offset = Vector2(SLAM_OFFSET.x * multiplier, SLAM_OFFSET.y * y_direction)

	# Use the pivot's rotation to calculcate the offset in world space
	# var offset_distance = Vector2(SLAM_OFFSET.x * multiplier, SLAM_OFFSET.y * y_direction)
	# var offset_distance = SLAM_OFFSET * multiplier

	# var offset = Vector2(cos(rotation), sin(rotation)) * offset_distance
	var offset = Vector2(SLAM_OFFSET.x * multiplier, SLAM_OFFSET.y * y_direction).rotated(rotation)
	new_slam.global_position = attack_origin + offset
	# print_debug("Offset: " + str(offset))
	# Reparent the new slam to GameScene so it won't move with the player.
	new_slam.reparent(get_node("/root/GameScene"))

	

	slam_count += 1


func _on_next_slam_timer_timeout() -> void:
	# Spawn the next slam in the chain.
	# Rewrite the whole thing so it spawns one slam at a time until we hit max, tehn reset the timer
	# Logic: Spawn slam, increment counter, if counter is less than max, reset timer, else reset counter and timer
	if slam_count < max_slams:
		spawn_next_slam()
	else:
		# Reset all teh slamming stuff
		slam_count = 0
		$NextSlamTimer.stop()
		targeting = false
		weapon.fire_weapon()



func level_up() -> void:
	# Call the weapon's level up function, then finalize any others that aren't in weapon (projectiles, lifetime, etc)
	if first_level_up:
		first_level_up = false
		weapon.fire_weapon()
		return

	# Only gain a slam every X levels based on the mod
	weapon.level_up(LEVEL_UP_DAMAGE, LEVEL_UP_SPEED, LEVEL_UP_COOLDOWN)
	# HEY DUMMY increase the level THEN the max slams lmao
	max_slams = (max_slams + 1) if (weapon.level % LEVEL_UP_SLAMS_MOD) == 0 else max_slams
	
	weapon.fire_weapon() # Design this way, the player starts with the cooldown instead of getting a "free shot".

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


func get_level_up_text() -> String:
	# Need to watch order of operations especially with modulus and concatenating strings!
	var new_slams = max_slams + 1 if (weapon.level + 1) % LEVEL_UP_SLAMS_MOD == 0 else max_slams
	var level_up_string: String
	if first_level_up: level_up_string = "Level 1\nDamage " + str(weapon.damage) + "\nSpeed " + str(weapon.speed) + "/s\nSlams " + str(max_slams) + "s\nCooldown " + str(weapon.cooldown) + "s";
	else: 
		level_up_string = "Level " + str(weapon.level) + " -> " + str(weapon.level + 1) + "\n"
		level_up_string += "Damage " + str(GameController.round_to_dec(weapon.damage, 2)) + " -> " + str(GameController.round_to_dec(weapon.damage * LEVEL_UP_DAMAGE, 2)) + "\n"
		level_up_string += "Speed " + str(GameController.round_to_dec(rad_to_deg(weapon.speed), 2)) + " -> " + str(GameController.round_to_dec(rad_to_deg(weapon.speed * LEVEL_UP_SPEED),2)) + "\n"
		level_up_string += "Slams " + str(max_slams) + "s -> " + str(new_slams) + "s\n"
		level_up_string += "Cooldown " + str(GameController.round_to_dec(weapon.cooldown, 2)) + "s -> " + str(GameController.round_to_dec((weapon.cooldown * LEVEL_UP_COOLDOWN),2)) + "s";
		
	return level_up_string
