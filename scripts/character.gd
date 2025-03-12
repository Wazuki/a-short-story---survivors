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

func set_stats(health: float, armor: float, speed: float) -> void:
    stats = {
        Stat.HEALTH: health,
        Stat.MAX_HEALTH: health,
        Stat.ARMOR: armor,
        Stat.SPEED: speed 
    }