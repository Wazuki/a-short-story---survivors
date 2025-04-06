class_name ProgressTracker
extends Control

enum QuestType { CHARACTER, WEAPON } ## enum for tracking quest types, used for sorting quest visibility.

@export var main_menu: MainMenu
@export var locked_shader: ShaderMaterial
# var progress_panels: Array[ProgressTrackerPanel]
var progress_tracker_panel = preload("res://prefabs/ui/progress_tracker_panel.tscn")

signal progress_updated # Signals should always be past tense

func _ready() -> void:
	main_menu.connect_progress_tracked_button(toggle_visibility)
	DataManager.updated_quests.connect(update_progress_bars)
	DataManager.data_reset.connect(clear_progress_panels)
	update_progress_bars()

func update_progress_bars() -> void:
	# print_debug("update signal called")
	progress_updated.emit()

# Take in quest object.
# Objective metadata icon_path has path to quest icon
# Objective metadata reward has reward description
func create_progress_tracker_panel(quest: QuestResource) -> void:
	var prog_panel := progress_tracker_panel.instantiate()
	prog_panel.initialize(quest)
	%ProgressContainer.add_child(prog_panel)
	# progress_panels.append(prog_panel)
	progress_updated.connect(prog_panel.update_progress_bar)

## Removes all progress panels for when quests are reset.
func clear_progress_panels() -> void:
	for child in %ProgressContainer.get_children():
		if child is ProgressTrackerPanel:
			child.queue_free()

## Flips the visibility of the main menu and the progress tracker window.[br]
## [b]Note:[/b] They typically will have oppposite visiblities.
func toggle_visibility(state: bool) -> void: 
	visible = state
	main_menu.visible = !state

func _on_back_button_pressed() -> void:
	toggle_visibility(false)

## Sort the quest panels by type and name, hiding any that do not meet the [QuestType] enum.[br]
## [b]Note:[/b] Because the "all" tab is our zeroth tab, the [QuestType] enum will be 1-indexed.
func _on_tab_bar_tab_selected(tab_selected:int) -> void:
	# "ALL" tab selection:
	if tab_selected == 0:
		for child in %ProgressContainer.get_children():
			if child is ProgressTrackerPanel:
				child.visible = true
	else:
		for child in %ProgressContainer.get_children():
			# Hide all panels that are not of the selected type and show the ones that are.
			if child is ProgressTrackerPanel:
				if child.quest_type == tab_selected - 1:
					child.visible = true
				else: child.visible = false

	####### TWEEN THEM ########

