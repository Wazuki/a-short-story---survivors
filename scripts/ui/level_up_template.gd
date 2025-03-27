extends Panel

var level_up_option

func _ready() -> void:
	pass

func set_level_up_information(option, level_up_text: String) -> void:
	level_up_option = option
	%LevelUpName.text = "[center]" + level_up_option.name + "[/center]"
	# %WeaponIcon.animation = level_up_info["spritesheet_ID"]
	# %WeaponIcon.rotation = level_up_info["icon_rotation"]
	# %WeaponIcon.position = level_up_info["icon_offset"]
	# %WeaponIcon.scale = level_up_info["icon_scale"]
	# Add a line break before the level up text to allow seperation between icon and text.
	%LevelInformation.text = "[center]\n" + level_up_text+ "[/center]"

func set_level_up_information_string(option: String, level_up_text: String) -> void:
	level_up_option = option
	%LevelUpName.text = "[center]" + level_up_option + "[/center]"
	%LevelInformation.text = "[center]" + level_up_text + "[/center]"


func _on_level_up_button_pressed() -> void:
	# Check to see if we're passing a string. If so, adjust the player's health or speed accordingly
	# TODO - the player should probably be handling htis!
	if typeof(level_up_option) == TYPE_STRING:
		match level_up_option:
			"health":
				GameController.player.max_health += GameController.level_up_UI.LEVEL_UP_HEALTH_VAL
				GameController.player.health += GameController.level_up_UI.LEVEL_UP_HEALTH_VAL
			"speed":
				GameController.player.speed += GameController.level_up_UI.LEVEL_UP_SPEED_VAL
	else: level_up_option.call("level_up") # In theory this works because of godot weirdness. I think
	# Call the Level Up UI to finalize leveling.
	GameController.level_up_UI.finalize_level_up()

func set_icon(icon: AtlasTexture) -> void:
	%WeaponIcon.texture = icon
