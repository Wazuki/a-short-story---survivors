@tool
extends WeaponData

@export_category("Black Hole Specifics")
@export var start_size: Vector2 ## The starting size of the projectile when the player fires it
@export var max_size: Vector2 ## The max size of the projectile
@export var grow_time: float ## How long it takes the projectile to grow from [start_size] to [max_size]
@export var vortex_status: StatusEffect ## TODO - define this as a Vortex [StatusEffect] that will determine enemies trapped in the vortex.