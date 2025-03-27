class_name MainMenu
extends CanvasLayer

var main_audio_bus_name := "Master"
var music_audio_bus_name := "Music"

# These are ints that store the index of the audio bus in the AudioServer
@onready var master_audio_bus := AudioServer.get_bus_index(main_audio_bus_name)
@onready var music_audio_bus := AudioServer.get_bus_index(music_audio_bus_name)

@onready var pause_button: Button = get_node("/root/GameScene/UI/PauseButton")

func _ready() -> void:
	%SoundSlider.value = db_to_linear(AudioServer.get_bus_volume_db(master_audio_bus))
	%MusicSlider.value = db_to_linear(AudioServer.get_bus_volume_db(music_audio_bus))

	pause_button.pressed.connect(_on_pause_button_pressed)

func _on_start_button_pressed() -> void:
	%MainMenu.visible = false
	GameController.start_game()

func _on_options_button_pressed() -> void:
	if GameController.game_started:
		%PauseMenu.visible = false
	else:
		%MainMenu.visible = false

	%OptionsMenu.visible = true


func _on_quit_button_pressed() -> void:
	GameController.quit_game()


func _on_sound_slider_drag_ended(_value_changed:bool) -> void:
	# Requires calling to the audio server to set the volume of the bus
	AudioServer.set_bus_volume_db(master_audio_bus, linear_to_db(%SoundSlider.value))
	# print_debug("Sound volume set to: " + str(%SoundSlider.value))


func _on_music_slider_drag_ended(_value_changed:bool) -> void:
	AudioServer.set_bus_volume_db(music_audio_bus, linear_to_db(%MusicSlider.value))


func _on_close_options_window_button_pressed() -> void:
	%OptionsMenu.visible = false

	if GameController.game_started:
		%PauseMenu.visible = true
	else:
		%MainMenu.visible = true



func _on_pause_button_pressed() -> void:
	%PauseMenu.visible = true
	# print("Pause Menu is visible: " + str(%PauseMenu.visible))
	GameController.pause_game()


func _on_reset_stats_button_pressed() -> void:
	GameController.reset_game()


func _on_touch_input_button_toggled(toggled_on:bool) -> void:
	GameController.touch_input_enabled = toggled_on
	# print_debug("Touch input enabled: " + str(toggled_on))

func set_touch_input_button_state(state: bool) -> void:
	%TouchInputButton.set_pressed(state)


func _on_resume_button_pressed() -> void:
	%PauseMenu.visible = false
	GameController.unpause_game()


func _on_end_run_button_pressed() -> void:
	%PauseMenu.visible = false
	GameController.game_over()

func connect_progress_tracked_button(callable: Callable) -> void:
	%ProgressTrackerButton.pressed.connect(callable.bind(true))
