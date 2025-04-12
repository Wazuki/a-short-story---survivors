class_name AdditiveRangeAugment
extends WeaponAugment

@export var range_modifier: float ## The amount of range that will be [b]added[/b] to the weapon.

## Apply a range increase to the target weapon.
func apply_augment(target: Variant) -> void:
	target.weapon_range += range_modifier
	target.update_weapon_range()
