class_name GenericAugment
extends Augment

const Rarity = Utils.Rarity # Assigns the Utils.Rarity enum for quick access.
## The description of the augment, used in the level up UI. Please use use fstrigns for proper formatted text (see example in [method get_description()]).
var description: String = "{0} deals +{1}% damage" 

# Base class for "augments" - upgrades that will apply to anything.
var rarity: Rarity = Rarity.COMMON: ## The rarity of the augment, used for determining its effectiveness and availability.
	set(new_rarity):
		rarity = new_rarity
		_on_rarity_update() # Call the update function when the rarity is set.

var weapon: Weapon = null ## The weapon that this augment is applied to.
## Base function for augments that will be overridden.
func apply_augment(_target: Variant) -> void:
	# This function will be overridden by subclasses
	pass

## Must be overridden by subclasses to return the augment's description and reflect the augment's effects (such as damage going from 110% -> 120%) [br]
## Format should be: Level n -> n + 1\n Description of what the augment does \n Mechanical explanation of the augment \n tags
func get_description() -> String: 
	# Returns the description of the augment, which is used in the level up UI.
	return ""

func _on_rarity_update() -> void:
	# Called when the rarity is updated. Will be overridden by subclasses.
	pass

func get_rarity() -> Rarity: return rarity