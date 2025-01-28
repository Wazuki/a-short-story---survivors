extends Node2D

# Base Weapon stats
const BASE_DAMAGE = 1.0
const BASE_SPEED = 500.0
const BASE_PROJECTILES = 1
const BASE_COOLDOWN = 0.5

#Level up stats
const LEVEL_UP_DAMAGE = 1.5
const LEVEL_UP_SPEED = 1.025
const LEVEL_UP_PROJECTILES_MOD = 5
const LEVEL_UP_COOLDOWN = 0.95

#Other Values


var icon: AtlasTexture = preload("res://sprites/frames/spreadfire_icon.tres")
# Variables other Weapons DON'T have
var projectiles
var first_level_up
# var ready_to_fire

var weapon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	name = "Spreadfire"
	weapon = preload("res://prefabs/weapon.tscn").instantiate()
	add_child(weapon)
	# reset()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if weapon.ready_to_fire:
		# Do all the things you'd do if you'd fire the weapon
		
		# Get the player's pos, and the player's nearest target, for the spreadfire fire_weapon
		fire_weapon()
		# Call the fire_weapon from the Weapon node to reset the timer, then spawn bullets etc
		weapon.fire_weapon()

	
	
func reset() -> void: 
	weapon.set_stats(BASE_DAMAGE, BASE_SPEED, BASE_COOLDOWN)
	weapon.reset_timer()
	projectiles = BASE_PROJECTILES
	first_level_up = true
	

# Fire the weapon, using the a V2 target
func fire_weapon() -> void:
	var fire_angle: float = 0
	
	# new fire algo - set angle every time, removed needless if. If bullets aren't angling look here first!
	if weapon.ready_to_fire and GameController.player.get_target() != Vector2.ZERO: # Check to see if player actually has target
		for p in projectiles:
			fire_angle = p * 15
			
			if p % 2 == 0: fire_angle *= -1
			else: abs(fire_angle)
			
			spawn_bullet(GameController.player.get_target(), GameController.player, fire_angle)

func spawn_bullet(target: Vector2, player: Node2D, angle: float):
	var new_bullet = preload("res://prefabs/spreadfire_bullet.tscn").instantiate()
	new_bullet.global_position = player.global_position
	new_bullet.global_rotation = player.global_rotation
	new_bullet.look_at(target)
	new_bullet.global_rotation_degrees += angle
	new_bullet.call("set_stats") # Weird GDScript hardcoding thing - call functions directly with call()
	
	add_child(new_bullet)
	new_bullet.position = Vector2.ZERO
	new_bullet.reparent(get_node("/root/GameScene")) # Reparent the new bullet to GameScene so it won't move with the player.

	
	

func level_up() -> void:
	# Call the weapon's level up function, then finalize any others that aren't in weapon (projectiles, lifetime, etc)
	if first_level_up:
		first_level_up = false
		weapon.fire_weapon()
		return
	
	weapon.level_up(LEVEL_UP_DAMAGE, LEVEL_UP_SPEED, LEVEL_UP_COOLDOWN)
	projectiles = (projectiles + 1) if (weapon.level % LEVEL_UP_PROJECTILES_MOD) == 0 else projectiles
	
	weapon.fire_weapon() # Design this way, the player starts with the cooldown instead of getting a "free shot".

func get_damage() -> float:
	return weapon.get_damage()

func get_speed() -> float:
	return weapon.get_speed()

# Clean this up, don't need most of it now
# func get_level_up_info() -> Dictionary:
#	var info = {
#		"name" : name,
#		"spritesheet_ID" : SPRITESHEET_ID,
#		"icon_rotation" : ICON_ROTATION,
#		"icon_offset" : ICON_OFFSET,
#		"icon_scale" : ICON_SCALE,
#	}
	
#	return info

func get_level_up_text() -> String:
	# Need to watch order of operations especially with modulus and concatenating strings!
	var new_projectiles = projectiles + 1 if (weapon.level + 1) % LEVEL_UP_PROJECTILES_MOD == 0 else projectiles
	var level_up_string: String
	if first_level_up: level_up_string = "Level 1\nDamage " + str(weapon.damage) + "\nProjectiles " + str(projectiles) + "\nSpeed " + str(weapon.speed) + "\nCooldown " + str(weapon.cooldown)+ "s";
	else: 
		level_up_string = "Level " + str(weapon.level) + " -> " + str(weapon.level + 1) + "\n"
		level_up_string += "Damage " + str(GameController.round_to_dec(weapon.damage, 2)) + " -> " + str(GameController.round_to_dec(weapon.damage * LEVEL_UP_DAMAGE, 2)) + "\n"
		level_up_string += "Projectiles " + str(projectiles) + " -> " + str(new_projectiles) + "\n"
		level_up_string += "Speed " + str(GameController.round_to_dec(weapon.speed, 2)) + " -> " + str(GameController.round_to_dec(weapon.speed * LEVEL_UP_SPEED, 2)) + "\n"
		level_up_string += "Cooldown " + str(GameController.round_to_dec(weapon.cooldown, 2)) + "s -> " + str(GameController.round_to_dec((weapon.cooldown * LEVEL_UP_COOLDOWN),2)) + "s";
		
	return level_up_string
