extends Control

var weapons =[]

var level_up_container

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_up_container = preload("res://prefabs/level_up_container.tscn").instantiate()
	add_child(level_up_container)
	
	visible = false
	weapons.append(GameController.spreadfire)
	weapons.append(GameController.energy_sword)
	

func reset_weapons() -> void:
	for w in weapons:
		w.reset()

func show_level_up_screen() -> void:
	GameController.pause_game()
	
	for w in weapons:
		# Get the level up text and the relevant info to initialize the buttons etc
		var level_up_text = w.get_level_up_text()
		# var level_up_information = w.get_level_up_info()
		var level_up_choice = preload("res://prefabs/level_up_template.tscn").instantiate()
		
		# Send the data to the new template to tell the player what levelingg up will do
		level_up_choice.set_icon(w.icon)
		level_up_choice.set_level_up_information(w, level_up_text)
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
