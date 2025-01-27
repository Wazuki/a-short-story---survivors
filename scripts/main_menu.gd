extends CanvasLayer

func _on_start_button_pressed() -> void:
	visible = false
	GameController.start_game()

# TODO
func _on_options_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	GameController.quit_game()
