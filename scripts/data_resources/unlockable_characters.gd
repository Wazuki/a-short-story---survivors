extends Resource
class_name Unlockable_Characters

# A list of unlockable characters in the game

@export var valkyrie: Character = Character.new()
@export var tank: Character = Character.new()
@export var huntress: Character = Character.new()
@export var technician: Character = Character.new()

# Health, Armor, Speed for new characters
func _init() -> void:
    valkyrie.set_stats(100, 1.0, 150)
    tank.set_stats(200, 5.0, 100)
    huntress.set_stats(75, 0.1, 200)
    technician.set_stats(150, 3.0, 110)
