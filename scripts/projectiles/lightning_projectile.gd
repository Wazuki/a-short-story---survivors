class_name LightningBullet
extends Projectile

# var damage: float
var jump_speed: float
var current_chain: int
var max_chains: int
var can_split: bool = false

var hit_targets: Array[Node2D]
var current_jump_target: BaseEnemy

signal jumping_ended

func set_spawn_state(chain_speed: float, max_jumps: int, cur_chain:int = 1, splittable: bool = false) -> void:
	current_chain = cur_chain
	can_split = splittable
	jump_speed = chain_speed
	max_chains = max_jumps

func interpolate(length, duration = 0.1):
	var tween_offset = get_tree().create_tween()
	var tween_rect_w = get_tree().create_tween()

	tween_offset.tween_property(self, "offset", Vector2(length/2.0, 0), duration)
	tween_rect_w.tween_property(self, "region_rect", Rect2(0, 0, length, 12), duration)

## Animates the lightning bolt to stretch out to the target and then shrink into it by tweening its position against the target's and shrinking the rect.[br]
## Takes a [start_pos: Vector2], [target: Node2D], [duration: float]
func animate_lightning(start_pos: Vector2, target: Node2D, duration: float):
	# Tween towards the target, then shrink the width while moving the rect forward.
	var distance = start_pos.distance_to(target.global_position)
	var jump_pos = target.global_position
	self.global_position = start_pos

	var tween = get_tree().create_tween()
	# Animate the lightning stretching -> animate the pos back while shrinking the lightning
	# Rect2: (x (repeats texture horizontal), y (repeats texture vertical), w (controls width), h (controls height))
	tween.tween_property(%LightningSprite, "region_rect", Rect2(0, 0, distance, 12), duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD) # Animates the rect, stretching the lightnig out
	tween.tween_property(self, "global_position", jump_pos, duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD) # Animates the global pos shift
	tween.set_parallel(true) # The tween right BEFORE set_parallel() also becomes parallel!
	tween.tween_property(%LightningSprite, "region_rect", Rect2(0, 0, 0, 12), duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD) # Animates the rect to shrink the lightning
	#await get_tree().create_timer(duration).timeout
	
	tween.finished.connect(deal_chain_damage) # Damage the target then jump to the next one

func jump_first_target(target: Node2D) -> void:
	current_jump_target = target
	hit_targets.append(current_jump_target) # Make sure we don't the same target again

	look_at(target.global_position)
	animate_lightning(global_position, target, jump_speed)

func jump_to_next_target() -> void:
	if has_overlapping_areas() and current_chain < max_chains:
		current_chain += 1
		
		# Get a new target randomly based on the overlapping bodies in the jump collider, but make sure we don't hit the same target(s)
		var target = null
		var areas_in_range: Array = get_overlapping_areas()
		# Check if we've hit any targets yet - they might be dead. If we haven't, just pick a random target. Otherwise, iterate.
		if hit_targets.is_empty():
			# Before picking a random target we should make sure the target that we pick is valid.
			while target == null and not areas_in_range.is_empty():
				target = areas_in_range.pick_random()
				if is_instance_valid(target): break # If our target is valid then we found one, jump out of the loop.
				else: areas_in_range.erase(target) # Remove the dead reference from our collection and try again.
		else:
			areas_in_range.shuffle()

			# Cycle through the (now randomized) set of bodies we found until we find one we haevn't hit yet and make it a new target.
			for b in areas_in_range:
				if hit_targets.has(b):
					continue
				else:
					target = b
					break

		# If we still don't have a target it means there aren't any valid targets in range and we should reset the weapon cooldown and leave.
		if target == null: 
			end_lightning_sequence()
			return

		# Now that we have a target, add it to the array so we don't hit it again this cycle.
		hit_targets.append(target)

		current_jump_target = target
		# print("Jump! " + str(current_chain))
		look_at(target.global_position)
		animate_lightning(global_position, target, jump_speed)

		# Now that we've done all that, if we are of the level where we can arc, try to arc.
		# Make sure this bullet is: able to split and that this is an attack we should split on.
		if can_split and weapon.is_splitting_this_attack():
			# print_debug("Attempting to arc!")
			weapon.spawn_chained_lightning_bolt(areas_in_range.pick_random(), current_chain - 1, global_position) # Subtract 1 from the chain to account for the first jump
			can_split = false
			# print_debug("Arced!")

		# Finally, if the overhaul is enabled and we are on a chain that is a multiple of 4, spawn a strike.
		var modulus = weapon.strike_modulus	
		if weapon.is_overhaul_enabled() and current_chain % modulus == 0: 
			weapon.spawn_lightning_stike(target.global_position)
			# print_debug("Spawned lightning aoe!")


	else:
		end_lightning_sequence()

## Deal damage to the target if it has not already been freed. Then t ry to jump to the next target.
func deal_chain_damage() -> void:
	#var enemy = current_jump_target as Enemy
	damage_modifier = weapon.calculcate_chain_modifier(current_chain)
	damage_target(current_jump_target, weapon.get_stun_effect())
	# if is_instance_valid(current_jump_target):
	# 	var enemy = current_jump_target as Enemy

	# 	# If we've reached the right level and we are on the final chain, it should deal full damage instead.
	# 	if (weapon.is_final_chain_full_damage() and current_chain == max_chains) or current_chain == 1: # The first strike should also deal full damage.
	# 		damage_mod = 1.0
	# 	else:
	# 		# Retrieve the proper modifier (defaulting to 1.0 if the key wasn't found) and apply damage to the target with the modifier
	# 		damage_mod = weapon.get_chain_modifier(current_chain)

	# 	var damage_result = weapon.damage_calc()

	# 	# Before we deal damage we should make sure the target isn't dead!
	# 	if not enemy.dead: enemy.take_damage(damage_result * damage_mod)
	#if weapon.is_stun_enabled() and is_instance_valid(current_jump_target): current_jump_target.apply_stun(weapon.stun_duration)
	# After dealing damage, try to jump to the next target.
	jump_to_next_target()

func end_lightning_sequence() -> void:
	jumping_ended.emit()
	# print_debug("Lighting ended after " + str(current_chain) + " jumps")
	call_deferred("queue_free")
	# print_debug("queue lightning for delete")
	
	
# func spark(distance = 900):
# 	interpolate(distance, 0.2)
# 	await get_tree().create_timer(0.3).timeout
# 	interpolate(0, 0.1)
