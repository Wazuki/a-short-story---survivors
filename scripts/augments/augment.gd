class_name Augment
extends Resource
# Base class for "augments" - upgrades that will apply to anything.
@export var name: String
@export var tags: Array[WeaponEnums.Tag] = [] ## Tags that describe the augment's characteristics, used for filtering in the level up UI and determining what upgrades it can receive from the random pool.
## Base function for augments that will be overridden.
func apply_augment(_target: Variant) -> void:
	# This function will be overridden by subclasses
	pass