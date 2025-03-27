extends Resource
class_name CharacterStats

# Things that are a basis for all characters in game.
@export var character_name: String
@export var description: String
@export var spritesheet: SpriteFrames
@export var icon: AtlasTexture

enum Stat {
	HEALTH,
	MAX_HEALTH,
	ARMOR,
	SPEED
}

@export var stats: Dictionary = {
	Stat.HEALTH: 0,
	Stat.MAX_HEALTH: 0,
	Stat.ARMOR: 0,
	Stat.SPEED: 0,
}

func get_stat(stat: Stat) -> float:
	return stats.get(stat, 0)

func set_stat(stat: Stat, value: float) -> void:
	stats[stat] = value

# Helper functions to edit stats quickly.
## Add [modifier] to the stat and reassign it to the stat.
func add_to_stat(stat: Stat, modifier) -> void:
	stats[stat] += modifier

## Subtract [modifier] from the stat and reassign it to the stat.
func subtract_from_stat(stat: Stat, modifier) -> void:
	stats[stat] -= modifier

## Multiply [modifier] by the stat and reassign it to the stat.
func multiply_stat(stat: Stat, modifier) -> void:
	stats[stat] *= modifier

## Divide the stat by [modifier] and reassign it to the stat.	
func divide_stat(stat: Stat, modifier) -> void:
	stats[stat] /= modifier