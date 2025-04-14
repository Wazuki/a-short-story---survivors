extends Bullet

## Damage all entities in the area if we have any targets. 
func damage_area() -> void:
	weapon.knockback_status.set_origin(global_position)
	if has_overlapping_areas():
		#print_debug("Damaging " + str(get_overlapping_areas().size()) + " targets")
		for e in get_overlapping_areas():
			if e is Enemy:
				damage_target(e, weapon.knockback_status)

# Free the bullet once the animation finishes.
func _on_animated_sprite_2d_animation_finished() -> void:
	damage_area()
	call_deferred("queue_free")
