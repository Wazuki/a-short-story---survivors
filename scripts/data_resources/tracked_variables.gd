extends Resource
class_name  TrackedVariables

enum Type { KILLS, XP, LEVELS, DAMAGE }

@export var values: Dictionary = {
    Type.KILLS: 0,
    Type.XP: 0,
    Type.LEVELS: 0,
    Type.DAMAGE: 0
}

func add_value(t: Type, amount: int) -> void:
    if values.has(t):
        values[t] += amount

func get_value(t: Type) -> int:
    return values.get(t, 0)