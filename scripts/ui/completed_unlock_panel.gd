extends Panel

const CHAR_UNLOCK_TEXT = " HAS BEEN MOBILIZED"

## Initialize the unlock panel from the [param quest] that was completed.
func initialize(quest: QuestResource) -> void:
	quest.start_node
	%UnlockIcon.texture = load(quest.start_node.get_meta("icon_path"))
	var char_name = quest.start_node.get_meta("reward")
	char_name = char_name.split(" ")[1] # Split the string from "Mobilize <Name>" to just "<Name>"
	%UnlockText.text = char_name + CHAR_UNLOCK_TEXT
