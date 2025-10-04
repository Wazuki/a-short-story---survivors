extends Panel

const Rarity = Utils.Rarity
var level_up_option

func _ready() -> void:
	pass

## Param [option] is ducktyped; the only requirement is that it has a name.
func set_level_up_information(option, level_up_text: String) -> void:
	level_up_option = option

	var rarity_color: String = ""

	if level_up_option.has_method("get_rarity"):
		# Match the rarity of the augment to the traditional rarity colors.
		match level_up_option.get_rarity():
			Rarity.COMMON: rarity_color = "light gray"
			Rarity.UNCOMMON: rarity_color = "green"
			Rarity.RARE: rarity_color = "blue"
			Rarity.EPIC: rarity_color = "purple"
			Rarity.LEGENDARY: rarity_color = "gold"
		
		self_modulate = Color(rarity_color) # Change the panel's color to match the rarity.
		# Maybe change the icon or text color too?

	%LevelUpName.text = "[center]" + level_up_option.name + "[/center]"
	# %WeaponIcon.animation = level_up_info["spritesheet_ID"]
	# %WeaponIcon.rotation = level_up_info["icon_rotation"]
	# %WeaponIcon.position = level_up_info["icon_offset"]
	# %WeaponIcon.scale = level_up_info["icon_scale"]
	# Add a line break before the level up text to allow seperation between icon and text.
	%LevelInformation.text = "[center]\n"
	if rarity_color != "":
		%LevelInformation.text += "[[color=" + rarity_color + "]" + Utils.rarity_translation_dictionary[level_up_option.get_rarity()] + "[/color]]"

	%LevelInformation.text += "\n\n" + level_up_text+ "[/center]"





func set_level_up_information_string(option: String, level_up_text: String) -> void:
	level_up_option = option
	%LevelUpName.text = "[center]" + level_up_option + "[/center]"
	%LevelInformation.text = "[center]" + level_up_text + "[/center]"


func _on_level_up_button_pressed() -> void:
	# First, apply the augment selected to the weapon and increase the weapon's level.
	WeaponManager.level_up_weapon(level_up_option.weapon.weapon_type)
	level_up_option.apply_augment(level_up_option.weapon) # Apply the augment to the weapon.

	# # Check to see if we're passing a string. If so, adjust the player's health or speed accordingly
	# # TODO - the player should probably be handling htis!
	# if typeof(level_up_option) == TYPE_STRING:
	# 	match level_up_option:
	# 		"health":
	# 			GameController.player.max_health += GameController.level_up_UI.LEVEL_UP_HEALTH_VAL
	# 			GameController.player.health += GameController.level_up_UI.LEVEL_UP_HEALTH_VAL
	# 		"speed":
	# 			GameController.player.speed += GameController.level_up_UI.LEVEL_UP_SPEED_VAL
	# else: 
	# 	# Tell the weapon manager to level up the right weapon based on the weapon's type.
	# 	WeaponManager.level_up_weapon(level_up_option.weapon_type)
	# 	#level_up_option.call("level_up") # In theory this works because of godot weirdness. I think
	# # Call the Level Up UI to finalize leveling.
	GameController.level_up_UI.finalize_level_up()

func set_icon(icon: AtlasTexture) -> void:
	%WeaponIcon.texture = icon
