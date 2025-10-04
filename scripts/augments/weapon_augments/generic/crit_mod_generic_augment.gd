extends GenericAugment

var crit_mod_bonus = 0.1 ## The amount of critical damage modifier this augment provides, as a percentage (e.g. 0.1 = 10% critical damage modifier).

## Applies the augment to the target weapon
func apply_augment(target: Variant) -> void:
	target.crit_mod += crit_mod_bonus


## Must be overridden by subclasses to return the augment's description and reflect the augment's effects (such as damage going from 110% -> 120%) [br]
## Format should be: Level n -> n + 1\n Description of what the augment does \n Mechanical explanation of the augment \n tags
func get_description() -> String: 
	# Returns the description of the augment, which is used in the level up UI.
	description = "Level {0} -> {1}".format([weapon.level, weapon.level + 1])
	description += "\n{0} gains +{1}% critical hit damage".format([weapon.name, int(crit_mod_bonus * 100)])
	description += "\nCritical Damage Modifier: {0}% -> {1}%".format([(weapon.crit_mod) * 100, (weapon.crit_mod + crit_mod_bonus) * 100])
	return description

## Called when the rarity is updated.
func _on_rarity_update() -> void:
	# Called when the rarity is updated. Will be overridden by subclasses.
	match rarity:
		Rarity.COMMON:
			crit_mod_bonus = 0.25
		Rarity.UNCOMMON:
			crit_mod_bonus = 0.5
		Rarity.RARE:
			crit_mod_bonus = 0.75
		Rarity.EPIC:
			crit_mod_bonus = 1.0
		Rarity.LEGENDARY:
			crit_mod_bonus = 1.25
		_:
			crit_mod_bonus = 0.1 # Default value if rarity is not recognized.