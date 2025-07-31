class_name EventBus
extends Node
## A singleton class for decoupled signal distribution to all nodes

# Game Signals
signal spawn_experience(global_pos: Vector2, value: float)

# UI Signals
signal ui_update_hp(current_hp: float, max_hp: float)
signal ui_update_xp(current_xp: float, max_xp: float)
signal ui_update_level(level: int)

# Player signals
signal player_gained_xp(xp: float)
signal player_gained_level
signal player_damaged(damage: float)
signal player_defeated

# Enemy Signals
signal enemy_damaged(damage: float)
signal enemy_defeated(enemy)