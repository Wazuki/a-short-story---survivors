@tool
extends WeaponData

@export_category("Hailstorm Specifics")
@export var shots_per_cooldown: int ## How many shots can be fired before the weapon goes on cooldown.
@export var disorient_chance: float ## The chance for the weapon to disorient once unlocked.
@export var disorient_duration: float ## How long a target is disoriented for.
@export var knockback_strength: float ## The strength of the weapon's knockback
@export var heal_per_hit: float ## How much is healed per enemy hit by the Nano-Infused Shells passive.