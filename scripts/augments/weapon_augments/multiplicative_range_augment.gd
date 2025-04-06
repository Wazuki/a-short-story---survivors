class_name MultiplicativeRangeAugment
extends WeaponAugment

@export var range_modifier: float ## The amount that the range will be [b]multiplied[/b] by.

## Apply a range increase to the target weapon.
func apply_augment(target: Variant) -> void:
	target.weapon_range *= range_modifier
	target.update_weapon_range()