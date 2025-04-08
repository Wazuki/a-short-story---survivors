class_name CompletedUnlockPanel
extends Panel

const TWEEN_TIME = 0.5 ## The time it takes to tween the panel.
const SELF_MODULATE_COLOR = Color(1, 1, 1, 0) ## The color that the panel will be set to when it is hidden.
const SELF_MODULATE_COLOR_VISIBLE = Color(1, 1, 1, 1) ## The color that the panel will be set to when it is visible.
const CHAR_UNLOCK_TEXT = " HAS BEEN LIBERATED!" ## The text that will be displayed when the object is unlocked.

## Initialize the unlock panel from the [param quest] that was completed.
func initialize(quest: QuestResource) -> void:
	%UnlockIcon.texture = load(quest.start_node.get_meta("icon_path"))
	var char_name = quest.start_node.get_meta("reward")
	char_name = char_name.split(" ")[0] # Split the string from "Mobilize <Name>" to just "<Name>"
	%UnlockText.text = (char_name + CHAR_UNLOCK_TEXT).to_upper()

	# Set the self_modulate property for each component to white with alpha zero.
	%UnlockIcon.self_modulate = SELF_MODULATE_COLOR
	%UnlockText.self_modulate = SELF_MODULATE_COLOR
	%PanelTitle.self_modulate = SELF_MODULATE_COLOR

## Tween the panel over time to display it "unlocking".
func unlock() -> void:
	print_debug(%UnlockText.text)
	# Set the pivot_offset to half of the size of the panel and then shrink the rect to zero in the x direction.
	# Then tween the rect to the size of the panel.
	var x_size = custom_minimum_size.x # Capture the original size of the panel.
	pivot_offset = Vector2(size.x / 2, size.y / 2)
	custom_minimum_size.x = 0
	visible = true
	# Tween the size of the panel to the original size over TWEEN_TIME seconds.	
	var tween = create_tween()
	tween.tween_property(self, "custom_minimum_size", Vector2(x_size, custom_minimum_size.y), TWEEN_TIME)
	tween.tween_callback(display_unlock_info)

## Display the unlock text after the tween is complete.
func display_unlock_info() -> void:
	# Tween the info to fade in over TWEEN_TIME seconds.
	pass
	# Tween the PanelTitle text
	var tween = create_tween()
	tween.tween_property(%PanelTitle, "self_modulate", SELF_MODULATE_COLOR_VISIBLE, TWEEN_TIME)
	# Tween the UnlockText text
	tween.tween_property(%UnlockText, "self_modulate", SELF_MODULATE_COLOR_VISIBLE, TWEEN_TIME)
	# Apply the shader property to teleport the character in over TWEEN_TIME seconds.
	tween.tween_property(%UnlockIcon.material, "shader_parameter/progress", 0.0, TWEEN_TIME);
	#tween.tween_property(%UnlockIcon, "self_modulate", SELF_MODULATE_COLOR_VISIBLE, TWEEN_TIME)
	# TODO - unlock shader? Like a teleport effect?
