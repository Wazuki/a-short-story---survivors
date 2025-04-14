class_name Shield
extends StatusEffect
# A shield that prevents the character from taking damage once.
const SHIELD_FADE_TIME = 0.25 ## The time it takes for the shield to fade in or out
# const SPRITE_SIZE_MODIFIER = 0.65 ## The size of the shield sprite relative to the target. - DUMMIED OUT, due to parenting. Shield inherits parent scale.
const SHIELD_SPRITE = preload("res://prefabs/effects/shield.tscn") ## The shield sprite to instantiate when a target gains a shield.
var shield_sprite ## The shield sprite instance attached to the target
signal shield_destroyed ## Signal to emit when the shield is destroyed to notify listeners.

## When applied to the target, create a new shield sprite and attach it to the target.
func apply(target) -> void:
	shield_sprite = SHIELD_SPRITE.instantiate()
	# Attach the shield to the target at 0.0 local and adjust the sprite's scale relative to the target's.
	target.add_child(shield_sprite)
	shield_sprite.position = Vector2.ZERO
	# shield_sprite.scale = target.scale / SPRITE_SIZE_MODIFIER 
	Utils.create_tween(shield_sprite, "self_modulate", Color.WHITE, SHIELD_FADE_TIME) # Tweens the shield sprite to fade in over 0.25 seconds.

## TODO - used for cleansing effects?
func remove(_target) -> void:
	#var debug = get_signal_connection_list("shield_destroyed")
	#print_debug("Shield connection: " + str(debug))
	super.remove(_target)
	shield_destroyed.emit() # Tell our listeners our shield was destroyed.
	#shield_sprite.call_deferred("queue_free") # Remove the shield sprite from the target.
	Utils.create_tween(shield_sprite, "self_modulate", Color(1.0, 1.0, 1.0, 0.0), SHIELD_FADE_TIME, shield_sprite.queue_free) # Tweens the shield sprite to fade out over 0.25 seconds and then destroy the shield.

