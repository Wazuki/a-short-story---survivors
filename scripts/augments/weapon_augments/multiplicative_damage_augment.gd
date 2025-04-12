class_name MultiplicativeDamageAugment
extends WeaponAugment

@export var damage_modifier: float ## The amount that the damage of the weapon will be [b]multiplied[/b] by.

## Apply a damage increase to the target weapon.
func apply_augment(target: Variant) -> void:
	target.damage *= damage_modifier
