class_name CharacterSelectPanel extends Panel

@export var icon: TextureRect 
@export var name_text: RichTextLabel 

var character: Character
var clickable = false
var selected = false
signal activate_panel(panel)

func initialize(c: Character) -> void:
	character = c
	icon.texture = c.icon
	name_text.text = c.character_name

func _process(delta: float) -> void:
	# If the character isn't unlocked yet, animate the glitching text shader and swap out the character to the next one.
	if not character.is_unlocked:
		# Shader material holds the shader as well as its data.
		var shader_material = %CharacerNameText.material as ShaderMaterial
		var new_time = clampf(shader_material.get_shader_parameter("time") + delta, 0.0, 1.0)
		shader_material.set_shader_parameter("time", new_time)
		
		# If we've passed the 1.0, shuffle the letters of the name strings.
		if new_time >= 1.0:
			new_time = 0.0

func _on_scramble_text_timer_timeout() -> void:
	%CharacerNameText.text = scramble_string()
	%ScrambleTextTimer.start()

func start_scramble_timer() -> void:
	if not character.is_unlocked: %ScrambleTextTimer.start()

# Shuffle the string randomly.
func scramble_string() -> String:
	var base_string: String = %CharacerNameText.text
	var shuffled_string: String = ""
	# Iterate through the string, picking a random char and moving it from the base string to the shuffled string
	while not base_string.is_empty():
		var random_index = randi_range(0, base_string.length() -1 ) # randi_range is inclusive
		var new_char = base_string[random_index]
		base_string = base_string.erase(random_index)
		shuffled_string += new_char


	# var last_char = shuffled_string[shuffled_string.length() - 1]
	# shuffled_string = shuffled_string.erase(shuffled_string.length() - 1)
	# shuffled_string = shuffled_string.insert(0, last_char)
	# shuffled_string = shuffled_string.to_lower().capitalize()
	return shuffled_string

# When clicking the panel, activate the neighboring panels in the char_select_ui
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and clickable:
		# "Select" the panel, modulate it to indicate it, and tell the UI. 
		if not selected:
			selected = true
			# modulate = Color.GRAY
			material = preload("res://shaders/scanline_material.tres")

			# possible TODO - maybe Set the pivot offset and then tween the panel so it grows ever so slightly
			# For whatever reason, tweening the scale doesn't seem to work - most likely a result of the container. May have to revisit other ideas.
			pivot_offset = Vector2(size.x / 2, size.y / 2)
			var tween = get_tree().create_tween()
			tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

			# print("Panel selected")
			activate_panel.emit(self)

func deactivate_panel() -> void:
	# Clear the shader material and deselect the panel.
	selected = false
	material = null

# Remove the black shader from an unlocked character.
func unlock_char() -> void:
	if icon.material: icon.material = null
	clickable = true
	if %CharacerNameText.material: %CharacerNameText.material = null
	%CharacerNameText.text = character.character_name
	%ScrambleTextTimer.stop()
	# print_debug("Unlocked " + character.character_name)
