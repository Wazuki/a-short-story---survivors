@tool
extends WeaponData

@export_category("Slam Specifics")
@export var slow_value: float = 0.15
@export var shockwave_strength = 18
@export var weapon_scale: Vector2 = Vector2(2, 2)
@export var weapon_reduction_scale: float = 0.1
@export var weapon_min_scale = Vector2(0.75, 0.75)

@export_category("Mini-Slam Specifics")
@export var mini_slam_offset: float = 25
@export var mini_slam_scale: Vector2 = Vector2(0.65, 0.65)
#@export var mini_slam_damage_modifier: float = 0.5

