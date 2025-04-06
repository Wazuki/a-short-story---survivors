class_name AdditiveDamageAugment
extends WeaponAugment

@export var damage_increase: float ## The amount of damage that will be [b]added[/b] to the weapon.

## Apply a damage increase to the target weapon.
func apply_augment(target: Variant) -> void:
	target.damage += damage_increase
