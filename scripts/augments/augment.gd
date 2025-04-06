class_name Augment
extends Resource
# Base class for "augments" - upgrades that will apply to anything.

## Base function for augments that will be overridden.
func apply_augment(_target: Variant) -> void:
	# This function will be overridden by subclasses
	pass
