extends Control

const MAX_LEVEL_UP_OPTIONS = 4
const MAX_WEAPON_LEVEL = 7
const LEVEL_UP_HEALTH_VAL = 5
const LEVEL_UP_SPEED_VAL = 10

var health_icon: Texture2D = preload("res://sprites/wenrexa/Skill Icons (Rounded)/health.tres")
var speed_icon: Texture2D = preload("res://sprites/wenrexa/Skill Icons (Rounded)/speed.tres")

var level_up_container

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_up_container = preload("res://prefabs/level_up_container.tscn").instantiate()
	add_child(level_up_container)
	
	visible = false
	

func show_level_up_screen() -> void:
	GameController.pause_game()

	var weapons = GameController.weapons.duplicate()
	weapons.shuffle()
	var level_up_options = []
	# print_debug("Weapons has " + str(weapons.size()) + " Compared to the base: " + str(GameController.weapons.size()))

	# Find the player's current weapon and make it a level up option.
	# Add level up options til we hit the max per level (4?)
	# Then create all the GUI elements for each level up option.
	
	# Cycle through each of the available weapons - if they're valid level up options, add them to the options array.
	while level_up_options.size() < MAX_LEVEL_UP_OPTIONS:
		if weapons.is_empty(): break
		var weapon = weapons.pop_front() # Pick a random weapon from the list of weapons
		# If the weapon is at max level, it's not a valid option - remove it from the array and try again.
		# print_debug("Array size: " + str(weapons.size()))
		# TEMPORARY FIX - TODO - refactor ALL weapons!
		if weapon.name == "ChainLightning":
			if weapon.level >= MAX_WEAPON_LEVEL: 
				continue
			else: level_up_options.append(weapon)
		elif weapon.weapon.level >= MAX_WEAPON_LEVEL: 
			continue
		else: level_up_options.append(weapon)

	# Now that we have the array, if it's smaller than the MAX_LEVEL_UP_OPTIONS, add a few extra options.
	while level_up_options.size() < MAX_LEVEL_UP_OPTIONS:
		# Create a speed or health bonus and add it to the options array.
		if randf() > 0.5: level_up_options.append("health")
		else: level_up_options.append("speed")

	# Now create the level up UI!
	for option in level_up_options:
		var level_up_text
		var icon :AtlasTexture

		var level_up_choice = preload("res://prefabs/level_up_template.tscn").instantiate()

		# First, make sure the level up option isn't one of the bonus options:
		if typeof(option) == TYPE_STRING:
			match option:
				"health": 
					level_up_text = "Gain " + str(LEVEL_UP_HEALTH_VAL) + " bonus health."
					icon = health_icon
				"speed":
					level_up_text = "Gain " + str(LEVEL_UP_SPEED_VAL) + " bonus speed."
					icon = speed_icon
				
			level_up_choice.set_level_up_information_string(option, level_up_text)
		else:
			# Set up the level up choice for the weapon.
			level_up_text = option.get_level_up_text()
			icon = option.icon
			level_up_choice.set_level_up_information(option, level_up_text)


		level_up_choice.set_icon(icon)
		level_up_container.add_child(level_up_choice)

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
