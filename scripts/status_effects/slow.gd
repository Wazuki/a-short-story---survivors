class_name Slow
extends StatusEffect

const SLOW_COLOR = Color.AZURE
# const SLOW_PARTICLES = preload("res://prefabs/effects/slow_particles.tscn")

## Apply a slow to the target where [intsenity] is a float percent reduction[br]
## i.e., 0.15 = 15% speed reduction.
func apply(target) -> void:
	# Reduce the speed of the target
	target.stats[CharacterData.Stat.SPEED] *= (1.0 - intensity) # Invert the intensity (so 0.15 reduction becomes 0.85 total speed)
	# Modulate the target a little for now to show they're slowed.
	target.modulate = SLOW_COLOR
	#print("Slowed " + target.name + " for " + str(duration) + "s; speed is now " + str(target.stats[CharacterData.Stat.SPEED]))

## When removing, restore the target's original color and original speed.
func remove(target) -> void:
	super.remove(target)
	target.modulate = Color.WHITE
	target.reset_speed()
	#print(target.name + " Is no longer slowed! Speed is " + str(target.stats[CharacterData.Stat.SPEED]))
