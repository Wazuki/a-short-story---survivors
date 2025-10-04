extends GenericAugment

var damage_multiplier = 0.1 ## The amount of damage bonus this augment provides, as a percentage (e.g. 0.1 = 10% damage bonus).

## Applies the augment to the target weapon
func apply_augment(target: Variant) -> void:
	target.damage_multiplier += damage_multiplier


## Must be overridden by subclasses to return the augment's description and reflect the augment's effects (such as damage going from 110% -> 120%) [br]
## Format should be: Level n -> n + 1\n Description of what the augment does \n Mechanical explanation of the augment \n tags
func get_description() -> String: 
	# Returns the description of the augment, which is used in the level up UI.
	description = "Level {0} -> {1}".format([weapon.level, weapon.level + 1])
	description += "\n{0} deals +{1}% extra damage".format([weapon.name, int(damage_multiplier * 100)])
	description += "\nDamage: {0}% -> {1}%".format([(weapon.damage_multiplier) * 100, (weapon.damage_multiplier + damage_multiplier) * 100])
	return description

## Called when the rarity is updated.
func _on_rarity_update() -> void:
	# Called when the rarity is updated. Will be overridden by subclasses.
	match rarity:
		Rarity.COMMON:
			damage_multiplier = 0.1
		Rarity.UNCOMMON:
			damage_multiplier = 0.2
		Rarity.RARE:
			damage_multiplier = 0.3
		Rarity.EPIC:
			damage_multiplier = 0.4
		Rarity.LEGENDARY:
			damage_multiplier = 0.5
		_:
			damage_multiplier = 0.1 # Default value if rarity is not recognized.