class_name HealthLevelUpAugment
extends Augment
# An augment that adds to health when the player levels up.

@export var health_increase: float = 0.0 ## The amount that is [b]added[/b] to the health of the player when they level up.

## Applies the health increase to the player.
func apply_augment(player: Variant) -> void:
	player.health += health_increase
	player.max_health += health_increase


