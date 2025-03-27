class_name ProgressTrackerPanel
extends Panel

var reward_text: String = "[color=ffc857]REWARD: [/color]"
var objective_text: String = "[color=red]OBJECTIVE: [/color]"

var progress: float
var quest_objective_value_key: String
var quest_objective_value: Variant
var quest: QuestResource

# Take in quest object.
# Objective metadata icon_path has path to quest icon
# Objective metadata reward has reward description

# Useful debugging options for extracting data from future quests.
# print_debug("Loading " + selected_quest.name)
# print_debug("Current objective: " + selected_quest.get_active_objectives()[0].description)
# print_debug("Quest metadata[icon_path]: " + selected_quest.get_active_objectives()[0].get_meta("icon_path"))
# print_debug("Quest metadata[reward]: " + selected_quest.get_active_objectives()[0].get_meta("reward"))
# print_debug("Quest variable objective: " + str(selected_quest.get_active_objectives()[0].conditions[0].value))

## Initialize the progress_tracker_panel with a [quest: QuestResource] by extracting metadata from the objectives.[br]
## Quest objective metadata holds the resources required:[br]
## [b]Icon Path:[/b] [icon_path: String][br]
## [b]Quest Reward:[/b] [reward: String][br]
func initialize(selected_quest: QuestResource) -> void:
	# Assign the quest variable and extract the first objective. From there, extract the metadata for the quest information.
	self.quest = selected_quest
	var current_quest_objective = quest.get_active_objectives()[0] # Retrieve the first objective. Our quests should typically only have one.
	var extracted_objective_text = current_quest_objective.description # Extract the quest description.
	var extracted_reward_text = current_quest_objective.get_meta("reward") # Extract the reward text from the metadata.
	#var icon_path = current_quest_objective.get_meta("icon_path") # Extract the icon path to a variable.
	%QuestIcon.texture = load(current_quest_objective.get_meta("icon_path")) # Load the icon for the quest.
	# Combine the base text values and colors with the extracted texts.
	%QuestObjective.text = objective_text + extracted_objective_text
	%QuestReward.text = reward_text + extracted_reward_text
	# Returns the variable from the first condition of the quest - the quest requirement value.
	quest_objective_value = current_quest_objective.conditions[0].value
	quest_objective_value_key = current_quest_objective.conditions[0].key
	# %QuestProgressBar.max_value = quest_objective_value
	# Connect Questify to check for quest completion.
	#DataManager.data_changed.connect(update_progress_bar)
	Questify.quest_completed.connect(quest_completed)
	

## Update the progress bar from the data manager. Progress bar is 0-1.0 and value check is value/objective value
func update_progress_bar() -> void:
	var value = DataManager.get_value(quest_objective_value_key)
	if value == null: value = 0
	%QuestProgressBar.value = value / quest_objective_value

## Mark the quest as completed and set the progress bar to full.
func quest_completed(incoming_quest: QuestResource) -> void:
	if quest == incoming_quest:
		%QuestProgressBar.value = %QuestProgressBar.max_value
		if %QuestIcon.material: %QuestIcon.material = null # Clear the "locked" shader material if applicable.
