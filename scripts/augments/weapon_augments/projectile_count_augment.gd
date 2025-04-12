class_name ProjectileCountAugment
extends WeaponAugment

@export var projectile_adjustment: int ## The amount of bullets that will be [b]added[/b] to the weapon. Can be negative.

## Apply a bullet adjustment to the target weapon.
func apply_augment(target: Variant) -> void:
	target.projectile_count += projectile_adjustment
