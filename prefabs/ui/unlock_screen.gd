class_name UnlockScreen
extends Control

# The unlock screen that will display when the player completes a quest.
const UNLOCK_PANEL = preload("res://prefabs/ui/completed_unlock_panel.tscn")
@onready var unlock_container = %UnlockContainer

var pending_unlocks: Array[CompletedUnlockPanel] ## The list of pending unlocks that will be displayed.

# Set up the connection to Questify to listen for quest completion events.
func _ready() -> void:
	# if not DataManager.is_node_ready(): await DataManager.ready
	Questify.quest_completed.connect(_on_quest_completed)

## Initialize the unlock panel from the [param quest] that was completed.
func init_unlock_panel(quest: QuestResource) -> void:
	var new_panel = UNLOCK_PANEL.instantiate()
	unlock_container.add_child(new_panel)
	new_panel.initialize(quest)
	# set the new panel as the first child
	unlock_container.move_child(new_panel, 0)
	# Add the new panel to the pending unlocks list.
	pending_unlocks.append(new_panel)

# Displays the unlock screen if there are any pending unlocks.
func _process(_delta: float) -> void:
	# Only display if the current state is game over or unlock screen and only if we have unlocks to display.
	if GameController.current_state == GameController.GameState.GAME_OVER or GameController.current_state == GameController.GameState.UNLOCK_SCREEN: 
		if pending_unlocks.size() > 0:
			# Await a small amount and see if the size has changed. If it has, wait til the next frame.
			var current_size = pending_unlocks.size()
			await get_tree().process_frame
			if pending_unlocks.size() == current_size:
				# If the size hasn't changed, display the unlock screen.
				display_unlock_screen()
			else:
				# If the size has changed, wait til the next frame.
				await get_tree().process_frame

## Displays the unlock screen and animated each unlock panel.
func display_unlock_screen() -> void:
	if not visible: 
		visible = true
		# Animate each unlock screen with a tween, awaiting a small amount of time between each one.
		for child in unlock_container.get_children():
			if child is CompletedUnlockPanel:
				child.unlock()

## Closes the unlcok screen, removes all children and tells the game controller to advance the state.
func close_unlock_screen() -> void:
	visible = false
	# Tell the game controller to transition to teh game over state.
	GameController.show_game_over_screen()# TODO - Change this to directly call the game over UI instead of switching again. Maybe.

	for child in unlock_container.get_children():
		# Destroy the children if they are panels (e.g., unlock panels). Otherwise it's just the button chillin
		if child is CompletedUnlockPanel: child.queue_free() # Free all the children of the unlock container.
	# Clear the pending unlocks list.
	pending_unlocks.clear()

func _on_close_results_button_pressed() -> void:
	#print_debug("goodbye")
	close_unlock_screen()

## Called when a quest is completed. This will be connected to the Questify quest_completed signal.[br]
## [param quest] is the completed quest that will be passed to the Unlock Screen.
func _on_quest_completed(quest: QuestResource) -> void:

	if GameController.current_state == GameController.GameState.GAME_OVER or GameController.current_state == GameController.GameState.UNLOCK_SCREEN: 
		#print_debug("We finished a quest at the end of the game")
		# Tell the game manager to transition to the Unlock character state instead.
		GameController.change_game_state(GameController.GameState.UNLOCK_SCREEN)
		# Tell the unlock screen to display with whatever quests we just fininished.
		#print_debug("Completed " + quest.name)

		init_unlock_panel(quest)
		#display_unlock_screen()
