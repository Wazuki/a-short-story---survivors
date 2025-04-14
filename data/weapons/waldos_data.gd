@tool
extends WeaponData

@export_category("Waldos Specifics")
@export var inner_ring_scale: Vector2 = Vector2(0.65, 0.65)
@export var max_inner_ring_scale = Vector2(1.15, 1.15)
@export var overhaul_growth_rate = Vector2(0.3, 0.3)
@export var max_scale = Vector2(3, 3)
@export var shield_cooldown:float  = 1.0
@export var slow_status: Slow ## THe slow status that will affect enemies
@export var shield_status: Shield  ## The shield status that will affect the player.