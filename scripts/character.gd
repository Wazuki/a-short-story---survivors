extends Resource
class_name Character

# @export_enum("Health", "Armor", "Speed", "Damage") var stat: int


enum Stat
{
	HEALTH, MAX_HEALTH, ARMOR, SPEED
}

@export var stats: Dictionary = {
	Stat.HEALTH: 0,
	Stat.MAX_HEALTH: 0,
	Stat.ARMOR: 0,
	Stat.SPEED: 0,
}

var character_name: String
var description: String
var spritesheet
var icon
var starting_weapon: Weapon.Type
var is_unlocked: bool = false
var unlock_quest_path: String
var unlock_quest: QuestResource

signal unlocked
signal locked

# Initialize all the starting characters' attributes like stats, weapon, and unlock conditions.
func set_stats(char_name: String, health: float, armor: float, speed: float, starting_weap: Weapon.Type) -> void:
	character_name = char_name

	stats = {
		Stat.HEALTH: health,
		Stat.MAX_HEALTH: health,
		Stat.ARMOR: armor,
		Stat.SPEED: speed 
	}

	starting_weapon = starting_weap


	# print_debug("Unlock variable is " + TrackedVariables.Type.keys()[unlock_variable])

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
	if unlock_quest == null or unlock_quest.completed: unlock()
	else: lock()


func get_stat_value(stat: Stat) -> float: return stats.get(stat)
