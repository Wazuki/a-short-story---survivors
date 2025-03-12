extends Sprite2D

func interpolate(length, duration = 0.1):
	var tween_offset = get_tree().create_tween()
	var tween_rect_w = get_tree().create_tween()

	tween_offset.tween_property(self, "offset", Vector2(length/2.0, 0), duration)
	tween_rect_w.tween_property(self, "region_rect", Rect2(0, 0, length, 12), duration)

func animate_lightning(start_pos: Vector2, target_pos: Vector2, duration: float):
	# Tween towards the target, then shrink the width while moving the rect forward.
	var distance = start_pos.distance_to(target_pos)

	self.global_position = start_pos

	var tween = get_tree().create_tween()
	# Animate the lightning stretching -> animate the pos back while shrinking the lightning
	# Rect2: (x (repeats texture horizontal), y (repeats texture vertical), w (controls width), h (controls height))
	tween.tween_property(self, "region_rect", Rect2(0, 0, distance, 12), duration).set_ease(Tween.EASE_OUT) # Animates the rect, stretching the lightnig out
	tween.tween_property(self, "global_position", target_pos, duration).set_ease(Tween.EASE_OUT) # Animates the global pos shift
	tween.set_parallel(true) # The tween right BEFORE set_parallel() also becomes parallel!
	tween.tween_property(self, "region_rect", Rect2(0, 0, 0, 12), duration).set_ease(Tween.EASE_OUT) # Animates the rect to shrink the lightning
	#await get_tree().create_timer(duration).timeout

	tween.chain().tween_callback(get_parent().jump_next_target) # Jump to the next lightning target (if possible)



func spark(distance = 900):
	interpolate(distance, 0.2)
	await get_tree().create_timer(0.3).timeout
	interpolate(0, 0.1)
