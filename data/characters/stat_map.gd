class_name StatMap
extends Resource

## Scene definitions (human-readable fields mapped to enum internally)
@export var health: float
@export var armor: float
@export var speed: float
@export var phys: float
@export var mag: float

## Optional helper to return the dictionary if needed
func to_dict() -> Dictionary:
	return {
		CharacterData.Stat.HEALTH: health,
		CharacterData.Stat.MAX_HEALTH: health,
		CharacterData.Stat.ARMOR: armor,
		CharacterData.Stat.SPEED: speed,
		CharacterData.Stat.PHYS: phys,
		CharacterData.Stat.MAG: mag,
	}