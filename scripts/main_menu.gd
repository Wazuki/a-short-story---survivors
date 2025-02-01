extends CanvasLayer

var main_audio_bus_name := "Master"
var music_audio_bus_name := "Music"

# These are ints that store the index of the audio bus in the AudioServer
@onready var master_audio_bus := AudioServer.get_bus_index(main_audio_bus_name)
@onready var music_audio_bus := AudioServer.get_bus_index(music_audio_bus_name)

func _ready() -> void:
	%SoundSlider.value = db_to_linear(AudioServer.get_bus_volume_db(master_audio_bus))
	%MusicSlider.value = db_to_linear(AudioServer.get_bus_volume_db(music_audio_bus))

func _on_start_button_pressed() -> void:
	visible = false
	GameController.start_game()

# TODO
func _on_options_button_pressed() -> void:
	%OptionsMenu.visible = true


func _on_quit_button_pressed() -> void:
	GameController.quit_game()


func _on_sound_slider_drag_ended(_value_changed:bool) -> void:
	# Requires calling to the audio server to set the volume of the bus
	AudioServer.set_bus_volume_db(master_audio_bus, linear_to_db(%SoundSlider.value))
	# print_debug("Sound volume set to: " + str(%SoundSlider.value))


func _on_music_slider_drag_ended(_value_changed:bool) -> void:
	pass # Replace with function body.
	AudioServer.set_bus_volume_db(music_audio_bus, linear_to_db(%MusicSlider.value))


func _on_close_options_window_button_pressed() -> void:
	%OptionsMenu.visible = false



func _on_pause_button_toggled(toggled_on:bool) -> void:
	if toggled_on and GameController.game_started:
		GameController.pause_game()
	elif GameController.game_started:
		GameController.unpause_game()
	# 	%PauseButton.pressed = false


func _on_reset_stats_button_pressed() -> void:
	GameController.reset_game()


func _on_touch_input_button_toggled(toggled_on:bool) -> void:
	GameController.touch_input_enabled = toggled_on
	# print_debug("Touch input enabled: " + str(toggled_on))

func set_touch_input_button_state(state: bool) -> void:
	%TouchInputButton.set_pressed(state)
