extends Panel

var level_up_option


func set_level_up_information(option: Node2D, level_up_text: String) -> void:
	level_up_option = option
	%LevelUpName.text = "[center]" + level_up_option.name + "[/center]"
	# %WeaponIcon.animation = level_up_info["spritesheet_ID"]
	# %WeaponIcon.rotation = level_up_info["icon_rotation"]
	# %WeaponIcon.position = level_up_info["icon_offset"]
	# %WeaponIcon.scale = level_up_info["icon_scale"]
	%LevelInformation.text = "[center]" + level_up_text+ "[/center]" 

func _on_level_up_button_pressed() -> void:
	level_up_option.call("level_up") # In theory this works because of godot weirdness. I think
	# Call the Level Up UI to finalize leveling.
	GameController.level_up_UI.finalize_level_up()

func set_icon(icon: AtlasTexture) -> void:
	%WeaponIcon.texture = icon
