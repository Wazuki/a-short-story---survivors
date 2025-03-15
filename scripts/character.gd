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
var unlock_variable: TrackedVariables.Type
var unlock_value = 0
var is_unlocked: bool = false
signal unlocked

# Initialize all the starting characters' attributes like stats, weapon, and unlock conditions.
func set_stats(char_name: String, health: float, armor: float, speed: float, starting_weap: Weapon.Type, unlock_var: TrackedVariables.Type = TrackedVariables.Type.NONE, unlock_val = 0) -> void:
    character_name = char_name

    stats = {
        Stat.HEALTH: health,
        Stat.MAX_HEALTH: health,
        Stat.ARMOR: armor,
        Stat.SPEED: speed 
    }

    starting_weapon = starting_weap

    unlock_variable = unlock_var
    unlock_value = unlock_val

    # print_debug("Unlock variable is " + TrackedVariables.Type.keys()[unlock_variable])

# Unlock the character then notify the UI to update.
func unlock() -> void:
    if is_unlocked: return
    else:
        is_unlocked = true
    unlocked.emit()

func get_stat_value(stat: Stat) -> float: return stats.get(stat)