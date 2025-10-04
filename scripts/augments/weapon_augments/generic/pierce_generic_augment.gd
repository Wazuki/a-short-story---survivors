extends GenericAugment

var pierce = 1 ## The amount of pierce bonus this augment provides, as a fix bonus

## Applies the augment to the target weapon
func apply_augment(target: Variant) -> void:
	target.pierce += pierce


## Must be overridden by subclasses to return the augment's description and reflect the augment's effects (such as damage going from 110% -> 120%) [br]
## Format should be: Level n -> n + 1\n Description of what the augment does \n Mechanical explanation of the augment \n tags
func get_description() -> String: 
	# Returns the description of the augment, which is used in the level up UI.
	description = "Level {0} -> {1}".format([weapon.level, weapon.level + 1])
	description += "\n{0} pierces +{1} more enemies".format([weapon.name, pierce])
	# So future me: This converts the cast speed multiplier to be capped at 2 decimal places using double formatted strings.
	# It's a dictionary (thus {} and not []) beacuse it allows us to use more complex formatting such as using fstrings in our fstrings.
	# Yo dawg i herd u like fstrings so i put a fstring in your fstring.
	description += "\nPierce: {0} -> {1}".format([weapon.pierce, weapon.pierce + pierce])
	return description

## Called when the rarity is updated.
func _on_rarity_update() -> void:
	# Called when the rarity is updated. Will be overridden by subclasses.
	match rarity:
		Rarity.COMMON:
			pierce = 1
		Rarity.UNCOMMON:
			pierce = 1
		Rarity.RARE:
			pierce = 2
		Rarity.EPIC:
			pierce = 3
		Rarity.LEGENDARY:
			pierce = 4
		_:
			pierce = 1 # Default value if rarity is not recognized.
