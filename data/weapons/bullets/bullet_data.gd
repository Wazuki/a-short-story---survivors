class_name BulletData
extends Resource

@export var name: String ## The name of the bullet
@export_category("Starting Stats")
@export var damage_modifier: float = 1.0 ## The damage modifier for this bullet. Used for scaling damage with a variety of effects.
@export var damage_cooldown: float = 0.0 ## How often the bullet will deal damage to the target if applicable.
@export var speed: float ## The speed of the weapon.
@export var lifetime: float = 0.0 ## Tracks lifetime of a projectile (if applicable). 0 = no lifetime dependency

@export_category("Packed Scenes")
@export var bullet_scene: PackedScene ## The scene that will be instantiated by the bullet.