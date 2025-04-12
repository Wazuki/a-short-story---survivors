class_name MultiplicativeCooldownAugment
extends WeaponAugment

@export var cooldown_modifier: float ## That the cooldown of the weapon will be [b]multiplied[/b] by.

## Apply a cooldown reduction to the target weapon.
func apply_augment(target: Variant) -> void:
	target.cooldown *= cooldown_modifier
	target.cooldown = max(target.cooldown, 0.1) # Ensure cooldown is not less than 0.1 seconds
