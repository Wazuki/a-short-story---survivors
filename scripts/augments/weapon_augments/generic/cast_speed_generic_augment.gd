extends GenericAugment

var cast_speed_multiplier = 0.1 ## The amount of cast speed bonus this augment provides, as a percentage (e.g. 0.1 = 10% damage bonus).

## Applies the augment to the target weapon
func apply_augment(target: Variant) -> void:
	target.cast_speed_multiplier += cast_speed_multiplier


## Must be overridden by subclasses to return the augment's description and reflect the augment's effects (such as damage going from 110% -> 120%) [br]
## Format should be: Level n -> n + 1\n Description of what the augment does \n Mechanical explanation of the augment \n tags
func get_description() -> String: 
	# Returns the description of the augment, which is used in the level up UI.
	description = "Level {0} -> {1}".format([weapon.level, weapon.level + 1])
	description += "\n{0} casts +{1}% faster".format([weapon.name, int(cast_speed_multiplier * 100)])
	# So future me: This converts the cast speed multiplier to be capped at 2 decimal places using double formatted strings.
	# It's a dictionary (thus {} and not []) beacuse it allows us to use more complex formatting such as using fstrings in our fstrings.
	# Yo dawg i herd u like fstrings so i put a fstring in your fstring.
	description += "\nCooldown: {0}s -> {1}s".format({0: "%0.2f" % (weapon.cooldown / weapon.cast_speed_multiplier), 1: "%0.2f" % (weapon.cooldown / (weapon.cast_speed_multiplier + cast_speed_multiplier))})
	return description

## Called when the rarity is updated.
func _on_rarity_update() -> void:
	# Called when the rarity is updated. Will be overridden by subclasses.
	match rarity:
		Rarity.COMMON:
			cast_speed_multiplier = 0.05
		Rarity.UNCOMMON:
			cast_speed_multiplier = 0.1
		Rarity.RARE:
			cast_speed_multiplier = 0.15
		Rarity.EPIC:
			cast_speed_multiplier = 0.2
		Rarity.LEGENDARY:
			cast_speed_multiplier = 0.25
		_:
			cast_speed_multiplier = 0.05 # Default value if rarity is not recognized.
