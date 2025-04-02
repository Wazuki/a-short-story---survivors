extends Node
# Class to handle the weapons and their various overarching functions as well as tracking them.
const ENEMY_CLEANUP_FRAME_OFFSET = 15
const MAX_WEAPON_LEVEL = 7
var weapon_database = preload("res://data/weapons/weapon_database.tres")
@onready var cooldown_container = get_node("/root/GameScene/UI/CooldownContainer")
# TODO IMPLEMENTATIONS
# Waldos

var weapon_data: Dictionary = {}
var active_weapons: Dictionary = {} ## List of all active weapons in the game. Structure is [<WeaponType, Weapon>]

func _ready() -> void:
	# Load each weapon's data once at startup from the RefCounted data files.
	for data in weapon_database.weapon_data:
		if weapon_data.has(data.weapon_type):
			print_debug("Warning! Duplicate weapon found with : " + data.name + "! Skipping.")
			continue
		weapon_data.set(data.weapon_type, data)

	# Preload Chain Lightning separately due to a bug. Editor bug? Unknown at this time.
	#var chain_lightning_data = preload("res://data/weapons/chain_lightning_data.tres")
	#weapon_data.set(chain_lightning_data.weapon_type, chain_lightning_data)

	# var dir = DirAccess.open(weapon_data_path)
	# if dir:
	# 	dir.list_dir_begin() # Iterate through the weapon direction and load each weapon data resource file.
	# 	var file_name = dir.get_next()
	# 	while file_name != "":
	# 		if file_name.ends_with(".tres"):
	# 			var loaded_data = load(weapon_data_path + file_name)
	# 			if loaded_data is WeaponData: # Make sure the weapon we're looking at is actually a weapondata resource.
	# 				weapon_data.set(loaded_data.weapon_type, loaded_data)
	# 				print("Loaded weapon data for: ", file_name)
	# 			elif weapon_data.has(loaded_data.weapon_type): print_debug("Warning! Duplicate weapon data file: " + (weapon_data_path + file_name))
	# 			else: print_debug("Warning! Skipping invalid weapon data file: " + (weapon_data_path + file_name))
	# 		file_name = dir.get_next()
	# 	dir.list_dir_end()
	# print_debug("Weapon data loaded: ", str(weapon_data.keys().size()))
	# Connect to the GameController's GameOver signal to reset weapons, panels, etc.
	GameController.game_ended.connect(reset)

## Returns the weapon data for a given [Weapon.Type]
func get_weapon_data(weapon_type: WeaponEnums.Type) -> WeaponData:
	# Returns the weapon data for the given weapon type.
	if weapon_data.has(weapon_type):
		return weapon_data[weapon_type]
	else:
		print_debug("Weapon data not found for: ", str(weapon_type))
		return null

## Instantiate a new weapon of the given type.
func create_weapon(weapon_type: WeaponEnums.Type) -> Weapon:
	var new_weapon = weapon_data[weapon_type].weapon_scene.instantiate()
	#print_debug("Creating weapon: ", str(weapon_data[weapon_type].name))
	
	#print_debug("Instantiated weapon: ", str(new_weapon.name))
	# Make sure our new weapon is actually a weapon. If so initialize it with data, add it to the scene tree, and return it.
	if new_weapon is Weapon:
		# Weapons should initialize -> ready() to make sure everything is populated properly.
		new_weapon.initialize(weapon_data[weapon_type])
		GameController.player.add_child(new_weapon) # Add the new weapon to the player in the scene tree so it will also call _ready() and follow the player.
		active_weapons.set(new_weapon.weapon_type, new_weapon) # Add the new weapon to the active weapons list.
		create_cooldown_panel(new_weapon) # Create a cooldown panel for the weapon.
		return new_weapon
	else:
		print_debug("Weapon scene not found for: ", str(weapon_type))
	return null

## Clear all active weapons from the scene tree and the active weapons list.
func clear_weapons() -> void:
	for weapon in active_weapons.values():
			weapon.queue_free()
	active_weapons.clear()

func get_active_weapons() -> Dictionary:
	# Returns the list of active weapons.
	return active_weapons

# Create a new cooldown panel and instantiate it, then connect the weapon firing signal to resetting the cooldown panel's timer
func create_cooldown_panel(weapon: Weapon) -> void:
	var new_panel = preload("res://prefabs/ui/cooldown_panel.tscn").instantiate()
	new_panel.initialize(weapon.icon, weapon.name, weapon.cooldown)
	weapon.fire.connect(new_panel.reset_cooldown)
	weapon.gained_level.connect(new_panel.update_level_text)
	weapon.begin_attack_sequence.connect(new_panel.begin_attack_sequence)
	cooldown_container.add_child(new_panel)

## Reset functions of the weapon manager - destroy all cooldown panels and all weapons.
func reset() -> void:
	# Destroy all cooldown panels.
	for c in cooldown_container.get_children():
		c.queue_free()
	clear_weapons() # Clear all active weapons.


# Go through the weapons and find the one that matches our type and return it.
func get_weapon_data_by_type(t: WeaponEnums.Type) -> WeaponData:
	if weapon_data.has(t): return weapon_data[t]
	print_debug(Weapon.Type.keys()[t] + " was not found in the weapon array.")
	return null

## Returns if the weapon is one the player currently has.
func is_weapon_active(t: WeaponEnums.Type) -> bool:
	if active_weapons.has(t): return true
	return false

## Returns the weapon's level if it is currently active. Otherwise returns 0 because the weapon is not active.[br]
func get_weapon_level(t: WeaponEnums.Type) -> int:
	if active_weapons.has(t):
		return active_weapons[t].level
	return 0

## Returns if the weapon is a valid level up option based on its level.[br]
## [b]TODO:[/b] Implement quest checks here maybe?[br]
## [b]TODO:[/b] Allow "standard" weapons as level up options.
func is_weapon_valid_level_up_option(t: WeaponEnums.Type) -> bool:
	if active_weapons.has(t):
		if active_weapons[t].level >= MAX_WEAPON_LEVEL: return false
		return true
	return true # Currently only weapons the player has "active" (starting weapons) are valid level up options.

## Instructs the weapon to level up based on the type of weapon passed in. If the weapon is not active it will be instantiated.
func level_up_weapon(t: WeaponEnums.Type) -> void:
	# Level up the weapon
	if active_weapons.has(t):
		active_weapons[t].level_up()
		#print_debug("Leveling up weapon: ", str(active_weapons[t].name))
		active_weapons[t].gained_level.emit(active_weapons[t].level)
	elif weapon_data.has(t): # If the weapon is not active but is a vlaid option, instantiate it.
		create_weapon(t)
	else:
		print_debug("Weapon not found for level up: ", str(t))
