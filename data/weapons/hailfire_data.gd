@tool
extends WeaponData

@export_category("Hailstorm Specifics")
@export var max_range: float ## The maximum range the bullets will go before disappearing.
@export var fire_angle: float ## The spread angle of the weapon (from [-fire_angle] to [fire_angle])
@export var base_fire_rate: float ## The starting attack speed (bullets fired in a second)
@export var max_fire_rate: float ## THe maximum attack speed (bullets fired in a second)
@export var ramp_speed: float ## How quickly the attack speed ramps up
@export var shots_per_attack: int ## The number of projectiles fired per attack cycle
@export var bounce_value: float ## The strength of the bounce
@export var knockback_status: Knockback ## The knockback that will affect targets hit by the projectiles