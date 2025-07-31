extends Control

var characters: Array[PlayerCharacterData]
# var character_dict_by_name = {}
var panels_expanded = false

var selected_character_panel: CharacterSelectPanel = null

@onready var character_panel_container = %CharacterPanelContainer

func init() -> void:
	await DataManager.ready
	characters = DataManager.characters
	# print_debug("There are " + str(characters.size()) + " characters loaded!")

	# Debug function for checking some Web5 stuff mostly related to possible load order issues.
	# for c in characters:
	# 	if c.character_name == null:
	# 		print_debug("Error! Found a null character! Running init")
	# 		UNLOCKABLE_CHARACTER_DATA._init()
	# 		characters = UNLOCKABLE_CHARACTER_DATA.get_all_chars()
	# 		break
	# 	else: print_debug(c.character_name)

	# Add the characters to a string dictionary then initialize a panel for each character.
	for c in characters:
		# character_dict_by_name[c.character_name] = c
		# print_debug("Deploying " + c.character_name)
		# Set up the character panel, initialize it, and assign it to the right container.
		var char_panel = preload("res://prefabs/ui/char_select_panel.tscn").instantiate()
		char_panel.initialize(c)
		char_panel.activate_panel.connect(display_character_info)
		%CharacterPanelContainer.add_child(char_panel)
		connect("visibility_changed", char_panel.start_scramble_timer)
		# If the character doesn't have an unlock quest (i.e., they're a starting character), unlock them.
		c.determine_lock_status()
		# if c.unlock_quest == null: c.unlock()
		# elif c.unlock_quest.completed: c.unlock() # If the player already unlocked a character in a previous session, unlock them.

	# TEMPORARY - TODO - REMOVE THIS ONCE WE HAVE ENOUGH CHARACTERS!
	# ADd some "Coming Soon" characters while we have less than 4
	if characters.size() < 8:
		for x in 8 - characters.size():
			# print_debug("Deploying bonus character " + str(x))
			var char_panel = preload("res://prefabs/ui/char_select_panel.tscn").instantiate()
			var c: PlayerCharacterData = PlayerCharacterData.new()
			#c.set_stats("COMING SOON", 9999, 9999, 9999, Weapon.Type.SLAM)
			c.icon = preload("res://assets/sprites/characters/valkyrie/valkyrie_icon.tres")
			
			char_panel.initialize(c)
			char_panel.activate_panel.connect(display_character_info)
			# c.unlocked.connect(char_panel.unlock_char)
			%CharacterPanelContainer.add_child(char_panel)
			connect("visibility_changed", char_panel.start_scramble_timer)

	Questify.quest_completed.connect(check_unlock_requiremets)

# func assign_quest_to_char(char_name, quest) -> void:
# 	for c in characters:
# 		if c.character_name == char_name: c.unlock_quest = quest
# 		if quest == null: c.unlock()
# 		return
	# var matching_char = characters.filter(func(c): c.character_name == char_name)
	# print_debug("Found matching chars: " + str(matching_char.size()))

	# if matching_char.size() > 0: 
	# 	matching_char[0].unlock_quest = quest
	# 	#print("quest assigned")
	# 	if quest == null: matching_char[0].unlock()


func display_character_info(panel: Panel) -> void:
	# Deactivate the previously selected character's panel (if applicable). The clicked panel will set itself.
	if selected_character_panel and selected_character_panel != panel: selected_character_panel.deactivate_panel()
	selected_character_panel = panel

	# Tween the WeaponInfo and CharacterInfo panels to stretch their rects to act like they're phasing in. But only once.
	if not panels_expanded:
		var weapon_tween = get_tree().create_tween()
		weapon_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		weapon_tween.tween_property(%WeaponInfoPanel, "scale:y", 1.0, 0.5)

		var char_tween = get_tree().create_tween()
		char_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		char_tween.tween_property(%CharacterInfoPanel, "scale:y", 1.0, 0.5)
		panels_expanded = true

	# Assign the character's information to the two side panels, including setting icons and text.
	%CharacterIcon.texture = panel.character.icon
	%CharacterNameText.text = panel.character.character_name
	# Concat a string of the character's description and then their stats (Health, Armor, Speed)
	%CharacterInfoText.text = Utils.replace_line_breaks(panel.character.description)
	%CharacterInfoText.text += "\n\nHealth: " + str(panel.character.stats.max_health)
	%CharacterInfoText.text += "\n\nArmor: " + str(panel.character.stats.armor)
	%CharacterInfoText.text += "\n\nSpeed: " + str(panel.character.stats.speed)

	# Assign the character's starting weapon information to the left panel.
	var starting_weapon = WeaponManager.get_weapon_data_by_type(panel.character.starting_weapon)
	# print_debug(panel.character.character_name + "'s starting weapon: " + starting_weapon.name)
	%WeaponIcon.texture = starting_weapon.icon
	%WeaponInfoText.text = Utils.replace_line_breaks(starting_weapon.description)
	%WeaponInfoText.text += "\n\nDamage: " + str(starting_weapon.damage)
	%WeaponInfoText.text += "\n\nCooldown: " + str(starting_weapon.cooldown)
	%WeaponInfoText.text += "\n\nRange: " + str(starting_weapon.weapon_range)

	# Set the button's parameters so when we click it we'll tell the GameController to start the game with this character.

	# if %SelectCharacterButton.is_connected("pressed", _on_character_select_button_pressed.bind(panel.character)): 
	# 	%SelectCharacterButton.disconnect("pressed", _on_character_select_button_pressed.bind(panel.character))
	# 	print_debug("disconnected")
	# else: %SelectCharacterButton.connect("pressed", _on_select_character_button_pressed.bind(panel.character))


# func _on_character_select_button_pressed() -> void:
# 	var char_name = selected_character_panel.character.character_name
# 	if char_name in character_dict_by_name: GameController.select_character(character_dict_by_name[char_name])

func check_unlock_requiremets(quest: QuestResource) -> void:
	# Check if the player has unlocked any characters
	#var completed_quests = Questify.get_completed_quests()
	print_debug("Attempting unlock with " + quest.name)
	for c in characters:
		# print_debug("Unlock status: " + c.character_name + " is " + str(c.is_unlocked))
		# Skip unlocked characters.
		#if c.unlock_quest != null: print("Unlcok quest: " + c.unlock_quest.name)
		if c.is_unlocked: 
			#print(c.character_name + " is already unlocked!")
			continue

		if c.unlock_quest == null or c.unlock_quest == quest:
			print("Unlocking " + c.character_name)
			c.unlock()


		# We're going to be updating the unlock variables differently now so we only need to ask the GameController to check the saved data.
		# Match the unlock variable to the type to see if we've surpassed the threshold. If so, unlock the character.
		# if c.unlock_variable == TrackedVariables.Type.NONE: c.unlock()
		# # Otherwise, unlock the character if the tracked variable (what the player has achieved) is greater than the unlock value
		# elif  GameController.tracked_variables.get_value(c.unlock_variable) >= c.unlock_value:
		# 	c.unlock()
			
# Tell the GameController to start thw game with the selected character.
func _on_select_character_button_pressed() -> void:
	GameController.select_character(selected_character_panel.character)

# When the panel becomes visible or invisible, reset the parameters so the character select screen goes back to normal.
func _on_visibility_changed() -> void:
	%WeaponInfoPanel.scale.y = 0
	%CharacterInfoPanel.scale.y = 0
	if selected_character_panel:
		selected_character_panel.deactivate_panel()
		selected_character_panel = null
	panels_expanded = false

# Hide the character select panel and return to the main menu.
func _on_back_button_pressed() -> void:
	visible = false
	get_node("/root/GameScene/UI/MainMenu/MainMenu").visible = true # TODO - update this to not hard-call a node. Maybe a reference in GameController or a singleton?
