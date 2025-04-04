class_name Stun
extends StatusEffect

const STUN_COLOR = Color.CYAN

## Stun the target, preventing moving and attacking.
func apply(target) -> void:
	# Set the speed of the target to 0.
	target.stats[CharacterData.Stat.SPEED] = 0 # Invert the intensity (so 0.15 reduction becomes 0.85 total speed)
	# Modulate the target a little for now to show they're slowed.
	target.modulate = STUN_COLOR
	target.stunned = true
	#print("Slowed " + target.name + " for " + str(duration) + "s; speed is now " + str(target.stats[CharacterData.Stat.SPEED]))

## When removing, restore the target's original color and original speed.
func remove(target) -> void:
	super.remove(target)
	target.modulate = Color.WHITE
	target.reset_speed()
	target.stunned = false
	#print(target.name + " Is no longer slowed! Speed is " + str(target.stats[CharacterData.Stat.SPEED]))
