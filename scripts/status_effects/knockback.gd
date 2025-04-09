class_name Knockback
extends StatusEffect

var origin: Vector2 ## The origin of the knockback

## Sets the origin of the knockback to [param pos].[br]
func set_origin(pos: Vector2) -> void:
	origin = pos

## Copies the effects of another effect onto the new effect.
func copy(other: StatusEffect) -> void:
	super.copy(other)
	origin = other.origin

## Apply a knockback to the target where [intensity] is the strength of the knockback.
func apply(target) -> void:
	# Make sure we have an origin - otherwise our knockback isn't going to work.
	assert(origin != null, "Knockback origin not set! Cannot apply knockback.")

	# Move the target away from the source of the knockback.
	var direction = (target.global_position - origin).normalized()
	#print("Origin: ", str(origin), " Target: ", str(target.global_position))
	#print("Direction: ", str(direction))
	#print_debug("Direction vector: " + str(direction))
	target.state_machine.change_state(AnimationNames.KNOCKBACK, {
		"velocity": direction * intensity * duration # Set the velocity to the knockback velocity (direction * intensity)
		# "duration": duration
	})	
