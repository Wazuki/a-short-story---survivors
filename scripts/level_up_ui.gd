extends Control

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
	
	var total_level_up_options = 0

	for w in GameController.weapons:
		# Skip showing hte weapon as an option if it's at max level
		if w.weapon.level >= MAX_WEAPON_LEVEL: continue # Need to get the level from the actual weapon node
		total_level_up_options += 1
		# Get the level up text and the relevant info to initialize the buttons etc
		var level_up_text = w.get_level_up_text()
		# var level_up_information = w.get_level_up_info()
		var level_up_choice = preload("res://prefabs/level_up_template.tscn").instantiate()
		
		# Send the data to the new template to tell the player what levelingg up will do
		level_up_choice.set_icon(w.icon)
		level_up_choice.set_level_up_information(w, level_up_text)
		level_up_container.add_child(level_up_choice)
	
	var bonus_level_up_options = ["health", "speed"]

	while total_level_up_options < 2:
		# Create some extra level up options for the player
		total_level_up_options += 1
		var level_up_choice = preload("res://prefabs/level_up_template.tscn").instantiate()
		var option
		var level_up_text = ""
		var level_up_icon

		match bonus_level_up_options.pick_random():
			"health":
				option = "health"
				level_up_text = "Gain " + str(LEVEL_UP_HEALTH_VAL) + " bonus health."
				level_up_icon = health_icon
			"speed":
				option = "speed"
				level_up_text = "Gain " + str(LEVEL_UP_SPEED_VAL) + " bonus speed."
				level_up_icon = speed_icon

		level_up_choice.set_icon(level_up_icon)
		level_up_choice.set_level_up_information_string(option, level_up_text)
		level_up_container.add_child(level_up_choice)


	visible = true
	# print_debug("Displaying level up screen!")

func finalize_level_up() -> void:
	# Destroy all the container children and resume the game
	visible = false
	for n in level_up_container.get_children():
		level_up_container.remove_child(n)
		n.queue_free()
	
	GameController.unpause_game()
