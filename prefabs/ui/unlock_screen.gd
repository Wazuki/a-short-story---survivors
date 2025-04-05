class_name UnlockScreen
extends Control

# The unlock screen that will display when the player completes a quest.
const UNLOCK_PANEL = preload("res://prefabs/ui/completed_unlock_panel.tscn")
@onready var unlock_container = %UnlockContainer

# Set up the connection to the DataManager to listen for the quest complete signal.
func _ready() -> void:
	if not DataManager.is_node_ready(): await DataManager.ready

## Initialize the unlock panel from the [param quest] that was completed.
func init_unlock_panel(quest: QuestResource) -> void:
	var new_panel = UNLOCK_PANEL.instantiate()
	unlock_container.add_child(new_panel)
	new_panel.initialize(quest)
	# set the new panel as the first child
	unlock_container.move_child(new_panel, 0)


func display_unlock_screen() -> void:
	if not visible: visible = true

func close_unlock_screen() -> void:
	visible = false
	# Tell the game controller to transition to teh game over state.
	GameController.show_game_over_screen()# TODO - Change this to directly call the game over UI instead of switching again. Maybe.

	for child in unlock_container.get_children():
		# Destroy the children if they are panels (e.g., unlock panels). Otherwise it's just the button chillin
		if child is Panel: child.queue_free() # Free all the children of the unlock container.

func _on_close_results_button_pressed() -> void:
	print_debug("goodbye")
	close_unlock_screen()
