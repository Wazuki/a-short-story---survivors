extends Node
# A class that handles the generic weapon augmentations and their associated tags. Informs the Level Up UI of the available augments and their effects.
const Tag = WeaponEnums.Tag # Assigns the WeaponEnums enum for quick access.

@export var generic_augments: Array[GenericAugment] = [] ## The generic augments that can be applied to the player weapons during level up

func _ready() -> void:
	# Called when added to the scene tree to initialize the augment manager.
	if generic_augments.size() == 0:
		var augment_data = preload("res://scripts/augments/generic_augment_collection.tres")
		generic_augments = augment_data.collection

## Iterate through the generic augments and return ones that match the given [weapon]
func get_generic_weapon_augments_by_weapon(weapon: Weapon) -> Array[GenericAugment]:
	var matching_augments: Array[GenericAugment] = []
	for augment in generic_augments:
		if Tag.ANY in augment.tags: # If the augment has the ANY tag, it applies to all weapons
			matching_augments.append(augment)
		else:
			for tag in augment.tags:
				if tag in weapon.tags:
					matching_augments.append(augment)
					break # No need to check other tags if one matches

	# print_debug("Matching augments for weapon " + weapon.name + ": " + str(matching_augments.size()))
	return matching_augments

## Returns the generic weapon augments that match the given [tag]. 
func get_generic_weapon_augments_by_tag(tag: Tag) -> Array[GenericAugment]:
	# Returns the generic weapon augments that match the given tag.
	var matching_augments = []
	for augment in generic_augments:
		if tag in augment.tags:
			matching_augments.append(augment)
	return matching_augments
