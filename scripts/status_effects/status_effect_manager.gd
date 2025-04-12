class_name StatusEffectManager
extends Node
# Manager for tracking each status effect currently active on a character.

@export var target: Node2D ## The owner of this effectt manager that will be targetted for effects.

var active_effects: Dictionary = {} ## Dictionary [<StatusEffect, instance of effect>] of active status effects currently on the character. 

# Check for updating each effect on process.
func _process(delta: float) -> void:
	update_effects(delta)

## Apply the status effect to the target. If currently affected, set the duration to the higher of the two.
func apply_effect(new_effect: StatusEffect) -> void:
	#print_debug("Applying " + str(typeof(new_effect)))
	var effect = new_effect.duplicate() # Make sure to copy teh effect so we don't affect the original resource!
	effect.copy(new_effect) # Copy the effect values from the incoming effect to the new effect.
	
	var effect_type = typeof(effect)
	# If we don't have the effect, apply it and add it to the active_effects collection.
	if not has_effect(effect):
		effect.apply(target) # Apply the effect's effects to the target.
		active_effects.set(effect_type, effect)
	else:
		match effect_type:
			Knockback: # We need to apply the affect again for knockback because of the way it adds its own velocity.
				effect.apply(target) # No need to duplicate duration since the state machine handles the KB logic.
			_: # Default option if we don't have a matching effect type.
				# Compare the duration of the effect we already have to the new one and set it to the higher value.
				if effect.duration > active_effects.get(effect_type).duration: active_effects.get(effect_type).duration = effect.duration
				# Otherwise don't do anything, because we're already effected longer than we would be right now.

## Iterate through the effects backwards, removing any that have expired
func update_effects(delta: float) -> void:
	if active_effects.is_empty(): return # Skip updating if we don't have any effects.

	# Iterate through the ditcionary, removing any effects that have ended.
	for key in active_effects:
		var result = active_effects[key].update(delta)
		if result: # If the target's duration has ended, remove it and queue it for deleting.
			active_effects.get(key).remove(target)
			active_effects.erase(key)

## Remove the effect from the target based on the effect type.[br]
func remove_effect(t: Variant) -> bool:
	if active_effects.is_empty(): return false # If we don't have any effects then just return false.
	if has_effect_type(t):
		# Remove the effect from the Dictionary.
		active_effects.get(t).remove(target) # Call the remove function on the effect!
		active_effects.erase(t)
		return true
	return false

## Checks the effect Dict to see if the current effect is affecting the entity.[br]
func has_effect(effect: StatusEffect) -> bool:
	if active_effects.is_empty(): return false
	if active_effects.has(typeof(effect)): return true
	return false

## Accepts [typeof] to see if we are currently affected by an effect.
func has_effect_type(t: Variant) -> bool:
	if active_effects.is_empty(): return false
	if active_effects.has(t): return true
	return false

## Connects a signal from the effect to the target. If the effect is not active, return false.[br]
## [param t] is [typeof] effect, [param sig_string] is the string of the signal to connect, [param callback] is the callable to connect to the signal.[br]
## Returns true if the signal was connected, false if not.[br]
func connect_signal(t: Variant, sig_string: String, callback: Callable) -> bool:
	if active_effects.is_empty(): return false
	if active_effects.has(t) and active_effects.get(t).has_signal(sig_string): # Check if we have the effect AND that we have the signal.
		active_effects.get(t).connect(sig_string, callback)
		return true
	push_warning("Effect " + str(t) + " not found in active effects or signal " + sig_string + " not found.")
	return false
