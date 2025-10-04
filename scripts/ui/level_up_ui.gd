extends Control

const MAX_LEVEL_UP_OPTIONS = 4
const MAX_WEAPON_LEVEL = 7
const LEVEL_UP_HEALTH_VAL = 10
const LEVEL_UP_SPEED_VAL = 5

var health_icon: Texture2D = preload("res://assets/UI/icons/health_icon.tres")
var speed_icon: Texture2D = preload("res://assets/UI/icons/speed_icon.tres")

var level_up_container

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_up_container = preload("res://prefabs/ui/level_up_container.tscn").instantiate()
	add_child(level_up_container)
	
	visible = false
	

func show_level_up_screen() -> void:
	GameController.pause_game()

	# var weapon_data = WeaponManager.weapon_data.values().duplicate() # Make sure to duplicate the array because we don't want to directly affect it.
	# weapon_data.shuffle()
	var level_up_options = []
	# print_debug("Weapons has " + str(weapons.size()) + " Compared to the base: " + str(GameController.weapons.size()))

	# Create a list of level up options that the player can choose from, utilizing the new weapon tags and augment manager.
	# Currently: At every odd level, each weapon will gain a unique augment IN ADDITION to its random generic augment it receives.
	# Player augments have been tabled for now, but may return in the future.

	# Iterate throug the player's weapons and, for each one that is below the level cap, add it to the weapons. Then create a new
	# set of augments for each of the weapons.

	var weapons = WeaponManager.get_active_weapons()
	var weapons_that_can_level = []
	for weapon in weapons.values():
		# If the weapon is below max level and is an active weapon it is a valid choice to receive a level up option.
		if weapon.level < MAX_WEAPON_LEVEL:
			weapons_that_can_level.append(weapon)

	# For each weapon that CAN level, retrieve its list of possible generic level ups and add it to the total pool that we will pick from
	for weapon in weapons_that_can_level:
		var generic_augments = AugmentManager.get_generic_weapon_augments_by_weapon(weapon)
		if generic_augments.size() > 0:
			# First, set the rarity of the augments returned based on the weapon's level
			var rarity = floori(weapon.level / 2)
			for augment in generic_augments: 
				augment.rarity = rarity
				augment.weapon = weapon # Set the weapon for the augment so it can apply correctly later.

			# Add the weapon's generic augments to the pool of level up options.
			for augment in generic_augments:
				level_up_options.append(augment)

	# Now that we have the weapons and their augments, we can create the level up options.
	# Shuffle the level up options to ensure randomness.
	level_up_options.shuffle()
	level_up_options = level_up_options.slice(0, MAX_LEVEL_UP_OPTIONS) # Limit the number of level up options to the max allowed.

	if level_up_options.size() == 0: push_warning("Error! No level up options found! Which means it's finally time to fix this! <3")

	for option in level_up_options:
		var level_up_choice = preload("res://prefabs/ui/level_up_template.tscn").instantiate()

		var level_up_text = "Level " + str(option.weapon.level) + " -> " + str(option.weapon.level + 1) + "\n" + option.get_description() # Get the description of the augment or weapon level up.
		var icon: AtlasTexture = option.weapon.icon

		# Set the level up information for the choice.
		option.name = option.weapon.name + " " + option.name ## TODO - define this better.
		level_up_choice.set_level_up_information(option, level_up_text)
		level_up_choice.set_icon(icon)
		level_up_container.add_child(level_up_choice)

	# # Find the player's current weapon and make it a level up option.
	# # Add level up options til we hit the max per level (4?)
	# # Then create all the GUI elements for each level up option.
	
	# # Cycle through each of the available weapons - if they're valid level up options, add them to the options array.
	# while level_up_options.size() < MAX_LEVEL_UP_OPTIONS:
	# 	if weapon_data.is_empty(): break
	# 	var current_data = weapon_data.pop_front() as WeaponData # Pick a random weapon from the list of weapons
	# 	# If the weapon is at max level, it's not a valid option - remove it from the array and try again.
	# 	if WeaponManager.is_weapon_valid_level_up_option(current_data.weapon_type): level_up_options.append(current_data)
	# 	else: continue
	# 	# if weapon.level >= MAX_WEAPON_LEVEL: 
	# 	# 	continue
	# 	# else: level_up_options.append(weapon)

	# # Now that we have the array, if it's smaller than the MAX_LEVEL_UP_OPTIONS, add a few extra options.
	# while level_up_options.size() < MAX_LEVEL_UP_OPTIONS:
	# 	# Create a speed or health bonus and add it to the options array.
	# 	if randf() > 0.5: level_up_options.append("health")
	# 	else: level_up_options.append("speed")

	# # Now create the level up UI!
	# for option in level_up_options:
	# 	var level_up_text
	# 	var icon :AtlasTexture

	# 	var level_up_choice = preload("res://prefabs/ui/level_up_template.tscn").instantiate()

	# 	# First, make sure the level up option isn't one of the bonus options:
	# 	if typeof(option) == TYPE_STRING:
	# 		match option:
	# 			"health": 
	# 				level_up_text = "Gain " + str(LEVEL_UP_HEALTH_VAL) + " bonus health."
	# 				icon = health_icon
	# 			"speed":
	# 				level_up_text = "Gain " + str(LEVEL_UP_SPEED_VAL) + " bonus speed."
	# 				icon = speed_icon
				
	# 		level_up_choice.set_level_up_information_string(option, level_up_text)
	# 	else:
	# 		# Set up the level up choice for the weapon.
	# 		var level = WeaponManager.get_weapon_level(option.weapon_type)
	# 		level_up_text = "Level " + str(level+1) + "\n" # Add one to the level here because we are showing player the future level, not current.
	# 		level_up_text += option.get_level_up_text(level)
	# 		icon = option.icon
	# 		level_up_choice.set_level_up_information(option, level_up_text)


	# 	level_up_choice.set_icon(icon)
	# 	level_up_container.add_child(level_up_choice)

	# for w in GameController.weapons:
	# 	# Skip showing hte weapon as an option if it's at max level
	# 	if w.weapon.level >= MAX_WEAPON_LEVEL: continue # Need to get the level from the actual weapon node

	# 	total_level_up_options += 1
	# 	# Get the level up text and the relevant info to initialize the buttons etc
	# 	var level_up_text = w.get_level_up_text()
	# 	# var level_up_information = w.get_level_up_info()
	# 	var level_up_choice = preload("res://prefabs/level_up_template.tscn").instantiate()
		
	# 	# Send the data to the new template to tell the player what levelingg up will do
	# 	level_up_choice.set_icon(w.icon)
	# 	level_up_choice.set_level_up_information(w, level_up_text)
	# 	level_up_container.add_child(level_up_choice)
	
	# var bonus_level_up_options = ["health", "speed"]

	# while total_level_up_options < 2:
	# 	# Create some extra level up options for the player
	# 	total_level_up_options += 1
	# 	var level_up_choice = preload("res://prefabs/level_up_template.tscn").instantiate()
	# 	var option
	# 	var level_up_text = ""
	# 	var level_up_icon

	# 	match bonus_level_up_options.pick_random():
	# 		"health":
	# 			option = "health"
	# 			level_up_text = "Gain " + str(LEVEL_UP_HEALTH_VAL) + " bonus health."
	# 			level_up_icon = health_icon
	# 		"speed":
	# 			option = "speed"
	# 			level_up_text = "Gain " + str(LEVEL_UP_SPEED_VAL) + " bonus speed."
	# 			level_up_icon = speed_icon

	# 	level_up_choice.set_icon(level_up_icon)
	# 	level_up_choice.set_level_up_information_string(option, level_up_text)
	# 	level_up_container.add_child(level_up_choice)


	visible = true
	# print_debug("Displaying level up screen!")

func finalize_level_up() -> void:
	# Destroy all the container children and resume the game
	visible = false
	for n in level_up_container.get_children():
		level_up_container.remove_child(n)
		n.queue_free()
	
	GameController.unpause_game()
