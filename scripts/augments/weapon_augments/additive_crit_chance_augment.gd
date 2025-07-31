class_name AdditiveCritChanceAugment
extends WeaponAugment

@export var crit_chance_increase: float ## The amount of critical hit chance that will be [b]added[/b] to the weapon. 1.0 = 100% chance.

## Apply a critical hit chance increase to the target weapon.
func apply_augment(target: Variant) -> void:
	target.crit_chance += crit_chance_increase
