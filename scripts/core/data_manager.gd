extends Node

@onready var unlock_screen = get_node("/root/GameScene/UI/UnlockScreen")
var character_database: CharacterDatabase = preload("res://data/characters/character_database.tres")

var characters: Array[PlayerCharacterData]
#const QUEST_FOLDER = "res://data/quests/"

var data = {}

signal data_changed(key: String, value: Variant)
signal data_reset
signal updated_quests

func _init():
	#character_database._init()
	characters = character_database.get_all_characters()
	# Copy the stat_map to to the stats var for easy access.
	# for c in characters: c.stats = c.stat_map.to_dict()

## Instantiate all quests, then connect the query_requested signal to Questify.
func _ready() -> void:
	# Connect the functions to the Questify signals for quest completion and condition query.
	Questify.condition_query_requested.connect(_on_condition_requested)
	# Instantiate all the quests, start tthem, and then load the player's data to update them.
	instantiate_quests()
	print_debug("Total quests: " + str(Questify.get_quests().size()))
	load_data_from_disk()
	print_debug("Active quests: " + str(Questify.get_active_quests().size()))
	print_debug("Completed quests: " + str(Questify.get_completed_quests().size()))
	updated_quests.emit()

## When trying to update a quest, evaluate the type of variable being examined and compare that to the value of the requester.
func _on_condition_requested(type: String, key: String, value: Variant, requester: QuestCondition) -> void:
	if type.begins_with("var"):
		var operator := type.get_slice(":", 1)
		var variable = get_value(key)
		var result := false
		if variable != null:
			match operator:
				type, "eq", "==":
					result = variable == value
				"neq", "ne", "!eq", "!=":
					result = variable != value
				"lt", "<":
					assert(not variable is bool, "Incorrect variable type for quest condition query operator")
					result = variable < value
				"lte", "<=":
					assert(not variable is bool, "Incorrect variable type for quest condition query operator")
					result = variable <= value
				"gt", ">":
					assert(not variable is bool, "Incorrect variable type for quest condition query operator")
					result = variable > value
				"gte", ">=":
					assert(not variable is bool, "Incorrect variable type for quest condition query operator")
					result = variable >= value
				_:
					printerr("Unknown operator '%s' in quest condition query" % operator)
		#print_debug("Result: " + str(result))
		requester.set_completed(result)

## Iterates through all quests available and then starts them.[br]
## [b]Quests:[/b] Character unlock quests -> assigned to each character
func instantiate_quests() -> void:
	# Iterate through the character quests, instantiate them, then match them to the character list and assign them. And pray.
	for character in characters:
		# Only instantiate actual quests - default characters have a null quest value so they auto-unlock
		var quest:QuestResource
		if character.unlock_quest_resource != null:
			quest = character.unlock_quest_resource.instantiate()
			character.unlock_quest = quest # Assign the quest INSTANCE back to the character so tracking works right.
			# Start the quest (so its objectives are set up) and then create a tracker panel for it.
			Questify.start_quest(quest)
			# Questify.update_quests()
			get_node("/root/GameScene/UI/ProgressTrackerControl").create_progress_tracker_panel(quest)
			# We should also connect the Quest Complete signal [quest_completed(quest)] to the unlock screen
			 # A character with an empty quest path has a "null" quest - they're a default character, no unlock reqs.


	#for c in characters: print_debug(c.character_name + " has the quest: " + (c.unlock_quest.name if c.unlock_quest_path != "" else " default character"))
	# var quest_paths = ResourceLoader.list_directory(QUEST_FOLDER)

	# # Iterate through the quest directory and load each quest.
	# for q in quest_paths:
	# 	var instance = load(QUEST_FOLDER + q).instantiate()
	# 	Questify.start_quest(instance)

## Sets the value of [key: String] to [value: Variant]. Adds the key if it doesn't exist.
func set_value(key: String, value: Variant) -> void:
	if data.has(key):
		data[key] = value
	else: data.get_or_add(key, value)
	data_changed.emit(key, value)

## Adds the value keyed to [key: String] to [value: Variant]. Adds the key if it doesn't exist.
func add_value(key: String, value: Variant) -> void:
	if data.has(key):
		data[key] = data[key] + value
	else: data.get_or_add(key, value)
	data_changed.emit(key, data[key])

## Returns the data associated with [key: String]
func get_value(key: String) -> Variant:
	if data.has(key):
		return data[key]
	return null

## Loads the player's data from disk.
func load_data_from_disk() -> void:
	var save_data = ConfigFile.new()
	var error = save_data.load("user://save_game.cfg")
	if error != OK: return

	# Load the player's preferences
	GameController.touch_input_enabled = save_data.get_value("Settings", "touch_input_enabled", false)
	$"/root/GameScene/UI/MainMenu".set_touch_input_button_state(GameController.touch_input_enabled)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(save_data.get_value("Settings", "sound_volume", 0.5)))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(save_data.get_value("Settings", "music_volume", 0.5)))

	# Load the player's tracked variables from file and assign it to the data variable.
	if save_data.has_section("SaveData"):
		var keys := save_data.get_section_keys("SaveData")
		for k in keys:
			set_value(k, save_data.get_value("SaveData", k, 0))

	# tracked_variables.set_value(TrackedVariables.Type.KILLS, save_data.get_value("SaveData","enemies killed", 0))
	# tracked_variables.set_value(TrackedVariables.Type.XP, save_data.get_value("SaveData","xp gained", 0))
	# tracked_variables.set_value(TrackedVariables.Type.DAMAGE, save_data.get_value("SaveData","damage done", 0))
	# tracked_variables.set_value(TrackedVariables.Type.LEVELS, save_data.get_value("SaveData","levels gained", 0))
	
	for key in data.keys():
		print_debug(str(key) + " " + str(data[key]))

	# Tell Questify to update quest data.
	Questify.update_quests()
	updated_quests.emit()
	

## Saves the player's data to disk.
func save_data_to_disk() -> void:
	var save_data = ConfigFile.new()
	# Save the player's preferences too!
	save_data.set_value("Settings", "touch_input_enabled", GameController.touch_input_enabled)
	save_data.set_value("Settings", "sound_volume", db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))))
	save_data.set_value("Settings", "music_volume", db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))))
	
	# Save the player's stats
	for key in data.keys():
		save_data.set_value("SaveData", key, data[key])

	# save_data.set_value("SaveData","enemies killed", tracked_variables.get_value(TrackedVariables.Type.KILLS))
	# save_data.set_value("SaveData","xp gained", tracked_variables.get_value(TrackedVariables.Type.XP))
	# save_data.set_value("SaveData","damage done", tracked_variables.get_value(TrackedVariables.Type.DAMAGE))
	# save_data.set_value("SaveData","levels gained", tracked_variables.get_value(TrackedVariables.Type.LEVELS))

	save_data.save("user://save_game.cfg")
	print_debug("Game saved!")

	# Tell Questify to update quest data.
	Questify.update_quests()
	updated_quests.emit()

## Resets the player's saved data, clears the variables, and restarts all quests. Then save the data.
func reset_saved_data() -> void:
	# First, clear the data and the quests.
	data.clear()
	data_reset.emit()
	Questify.clear()
	# Reinstantiate all the available quests and start them.
	instantiate_quests()
	# Determine the lock status for each character again.
	for c in characters: c.determine_lock_status()

	var save_data = ConfigFile.new()
	var error = save_data.load("user://save_game.cfg")
	if error != OK: return

	# Load the player's tracked variables from file and assign it to the data variable.
	if save_data.has_section("SaveData"):
		var keys := save_data.get_section_keys("SaveData")
		for key in keys:
			save_data.set_value("SaveData", key, null)

	# tracked_variables.set_value(TrackedVariables.Type.KILLS, save_data.get_value("SaveData","enemies killed", 0))
	# tracked_variables.set_value(TrackedVariables.Type.XP, save_data.get_value("SaveData","xp gained", 0))
	# tracked_variables.set_value(TrackedVariables.Type.DAMAGE, save_data.get_value("SaveData","damage done", 0))
	# tracked_variables.set_value(TrackedVariables.Type.LEVELS, save_data.get_value("SaveData","levels gained", 0))
	
	for key in data.keys():
		print_debug(str(key) + " " + str(data[key]))

	save_data.save("user://save_game.cfg")
	updated_quests.emit()
