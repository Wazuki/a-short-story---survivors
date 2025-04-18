extends CharacterData
class_name PlayerCharacterData

# @export_enum("Health", "Armor", "Speed", "Damage") var stat: int

@export_enum("SLAM", "LIGHT_BLADE", "WALDOS", "ARROW", "CHAIN_LIGHTNING", "HAILSTORM", "SCATTERSTAR", "BLACK_HOLE")
var starting_weapon: int
@export var level_up_text: String
#@export var unlock_quest_path: String
@export var unlock_quest_resource: QuestResource
var unlock_quest: QuestResource = null
var is_unlocked: bool = false

signal unlocked
signal locked

# # Initialize all the starting characters' attributes like stats, weapon, and unlock conditions.
# func set_stats(char_name: String, health: float, armor: float, speed: float) -> void:
# 	character_name = char_name

# 	stats = {
# 		Stat.HEALTH: health,
# 		Stat.MAX_HEALTH: health,
# 		Stat.ARMOR: armor,
# 		Stat.SPEED: speed 
# 	}

# 	#starting_weapon = starting_weap


# 	# print_debug("Unlock variable is " + TrackedVariables.Type.keys()[unlock_variable])

## Unlock the character then notify the UI to update.
func unlock() -> void:
	if is_unlocked: return
	else:
		is_unlocked = true
	unlocked.emit()

## Locks the character (such as if we reset the data)
func lock() -> void:
	if is_unlocked:
		is_unlocked = false
		locked.emit()

## Checks to see if the character is unlocked or not and perform the appropriate call.[br]
## Characters with null quests (from a quest path ==func determine_lock_status(character: Character) -> void:
func determine_lock_status() -> void:
	#if unlock_quest_resource != null: print_debug("Checking quest status for " + unlock_quest_resource.name)
	if unlock_quest == null or unlock_quest.completed: unlock()
	else: lock()
	#print_debug("Lock status for " + character_name + ": " + str(is_unlocked))


#func get_stat_value(stat: Stat) -> float: return stats[stat]
