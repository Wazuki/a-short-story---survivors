class_name AdditiveCritModAugment
extends WeaponAugment

@export var crit_mod_increase: float ## The amount that will be [b]added[/b] to the weapon's critical hit modifier.

## Apply a critical hit modifier increase to the target weapon.
func apply_augment(target: Variant) -> void:
	target.crit_mod += crit_mod_increase
