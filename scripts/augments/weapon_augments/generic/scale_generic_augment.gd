extends GenericAugment

var scale_multiplier = 0.1 ## The amount of cast speed bonus this augment provides, as a percentage (e.g. 0.1 = 10% damage bonus).

## Applies the augment to the target weapon
func apply_augment(target: Variant) -> void:
	target.scale_multiplier += scale_multiplier


## Must be overridden by subclasses to return the augment's description and reflect the augment's effects (such as damage going from 110% -> 120%) [br]
## Format should be: Level n -> n + 1\n Description of what the augment does \n Mechanical explanation of the augment \n tags
func get_description() -> String: 
	# Returns the description of the augment, which is used in the level up UI.
	description = "Level {0} -> {1}".format([weapon.level, weapon.level + 1])
	description += "\n{0}'s scale increases by +{1}%".format([weapon.name, int(scale_multiplier * 100)])
	description += "\nScale: {0}% -> {1}%".format([(weapon.scale.x * weapon.scale_multiplier) * 100, (weapon.scale.x * (weapon.scale_multiplier + scale_multiplier)) * 100])
	return description

## Called when the rarity is updated.
func _on_rarity_update() -> void:
	# Called when the rarity is updated. Will be overridden by subclasses.
	match rarity:
		Rarity.COMMON:
			scale_multiplier = 0.05
		Rarity.UNCOMMON:
			scale_multiplier = 0.1
		Rarity.RARE:
			scale_multiplier = 0.15
		Rarity.EPIC:
			scale_multiplier = 0.2
		Rarity.LEGENDARY:
			scale_multiplier = 0.25
		_:
			scale_multiplier = 0.05 # Default value if rarity is not recognized.