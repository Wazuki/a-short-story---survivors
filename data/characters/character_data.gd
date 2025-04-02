extends Resource
class_name CharacterData

# Things that are a basis for all characters in game.
@export_category("Descriptive Information")
@export var character_name: String
@export var description: String
@export var spritesheet: SpriteFrames
@export var icon: AtlasTexture

enum Stat {
	HEALTH,
	MAX_HEALTH,
	ARMOR,
	SPEED,
	PHYS,
	MAG
}

@export var stat_map: StatMap
var stats: Dictionary = {}

# @export var stats: Dictionary = {
# 	Stat.HEALTH: 0,
# 	Stat.MAX_HEALTH: 0,
# 	Stat.ARMOR: 0,
# 	Stat.SPEED: 0,
# }

func get_stat(stat: Stat) -> float:
	#return stats.get(stat, 0)
	return stats[stat]

func set_stat(stat: Stat, value: float) -> void:
	stats[stat] = value

# Helper functions to edit stats quickly.
## Add [modifier] to the stat and reassign it to the stat.
func add_to_stat(stat: Stat, modifier) -> void:
	stats[stat].value += modifier

## Subtract [modifier] from the stat and reassign it to the stat.
func subtract_from_stat(stat: Stat, modifier) -> void:
	stats[stat].value -= modifier

## Multiply [modifier] by the stat and reassign it to the stat.
func multiply_stat(stat: Stat, modifier) -> void:
	stats[stat].value *= modifier

## Divide the stat by [modifier] and reassign it to the stat.	
func divide_stat(stat: Stat, modifier) -> void:
	stats[stat].value /= modifier
