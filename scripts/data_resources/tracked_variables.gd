extends Resource
class_name  TrackedVariables

enum Type { KILLS, XP, LEVELS, DAMAGE, NONE = -1 }

@export var values: Dictionary = {
    Type.KILLS: 0.0,
    Type.XP: 0.0,
    Type.LEVELS: 0.0,
    Type.DAMAGE: 0.0
}

func add_value(t: Type, amount: int) -> void:
    if values.has(t):
        values[t] += amount

func set_value(t: Type, val: float) -> void: values[t] = val

func get_value(t: Type) -> int:
    return values.get(t, 0.0)