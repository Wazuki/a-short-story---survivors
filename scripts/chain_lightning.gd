extends Weapon

const BASE_DAMAGE = 10
const BASE_COOLDOWN = 2.0
const LIGHTNING_DURATION = 0.125
const STUN_DURATION = 0.2
const ARC_SPLIT_CHANCE = 0.25
const INITIAL_MAX_CHAINS = 2

# Level up consts
const APPLY_STUN_LEVEL = 4
const ARC_SPLIT_LEVEL = 5
const FINAL_CHAIN_FULL_DAMAGE_LEVEL = 6
# OVERHAUL_ENABLED = 7 const in base class

# @onready var lightning = %Lightning
var lightning_bullet
var icon = preload("res://sprites/wenrexa/Skill Icons (Rounded)/chain_lightning.tres")

var jump_speed = LIGHTNING_DURATION
# var current_chain = 0
var max_chains = INITIAL_MAX_CHAINS

var chain_modifiers = {
	2: 0.8,
	3: 0.75,
	5: 0.7,
	7: 0.65,
	10: 0.6,
	13: 0.55,
	16: 0.5
}

# var hit_targets: Array

func _ready() -> void:
	super._ready()
	name = "Chain Lightning"
	weapon_type = Weapon.Type.CHAIN_LIGHTNING
	description = "A chaining electrical blast."
	# reset()
	lightning_bullet = preload("res://prefabs/chain_lightning_bullet.tscn")

func reset() -> void:
	# current_chain = 0
	max_chains = INITIAL_MAX_CHAINS
	set_stats(BASE_DAMAGE, 1.0, BASE_COOLDOWN)
	first_level_up = true
	reset_timer()
	# Disconnect the critial hit signal if it's connected.
	if critical_hit.is_connected(critical_hit_cooldown_reset): critical_hit.disconnect(critical_hit_cooldown_reset)


# Attack process:
# 1. Find a random enemy in range.
# 2. If the enemy is in range, launch the lightning at it.
# 3. Once the tween ends (the enemy is hit), find the next closest enemy and repeat.

func _physics_process(_delta: float) -> void:
	fire_lightning()

func fire_lightning() -> void:
	# Check if an enemy is in range. If so, fire the lightning.
	if ready_to_fire and has_overlapping_bodies():
		begin_attack_sequence.emit() # Tell the listeners (Cooldown Panel et al) that we have started attacking.
		ready_to_fire = false
		%LightningSounds.play()
		# Spawn a new lightning bullet, set the position to ours, then jump to a random enemy to start the sequence.
		var target = get_overlapping_bodies().pick_random()
		spawn_new_lightning_bolt(target)

# TODO - refactor this to be more concise. This lightning spawning logic is rough.
func spawn_new_lightning_bolt(target: Node2D) -> void:
	var new_lightning = lightning_bullet.instantiate()
	add_child(new_lightning)
	new_lightning.global_position = global_position
	new_lightning.initiailize(jump_speed, max_chains, 1, is_splittable())
	new_lightning.jump_first_target(target)
	new_lightning.jumping_ended.connect(fire_weapon)

func spawn_chained_lightning_bolt(target: Node2D, chain_count: int, start_pos: Vector2) -> void:
	var new_lightning = lightning_bullet.instantiate()
	add_child(new_lightning)
	new_lightning.global_position = start_pos
	new_lightning.initiailize(jump_speed, max_chains, chain_count, false)
	new_lightning.jump_first_target(target)
	new_lightning.jumping_ended.connect(fire_weapon)

# Moved to lightning_bullet.gd
# func jump_next_target() -> void:
# 	# Check if we have any enemies in range of the target we just hit and tween to the next one. Otherwise reset the jump count.
# 	if %JumpRange.has_overlapping_bodies() and current_chain < max_chains:
# 		current_chain += 1
		
# 		# Get a new target randomly based on the overlapping bodies in the jump collider, but make sure we don't hit the same target(s)
# 		var target = null
# 		var bodies_in_range: Array = %JumpRange.get_overlapping_bodies()
# 		bodies_in_range.shuffle()

# 		# Cycle through the (now randomized) set of bodies we found until we find one we haevn't hit yet and make it a new target.
# 		for b in bodies_in_range:
# 			if hit_targets.has(b):
# 				continue
# 			else:
# 				target = b
# 				break

# 		# If we still don't have a target it means there aren't any valid targets in range and we should reset the weapon cooldown and leave.
# 		if target == null: 
# 			fire_weapon()
# 			return

# 		# Now that we have a target, add it to the array so we don't hit it again this cycle.
# 		hit_targets.append(target)

# 		# print("Jump! " + str(current_chain))
# 		lightning.look_at(target.global_position)
# 		lightning.animate_lightning(lightning.global_position, target.global_position, j_speed)
# 		damage_target(target)

# 	else: # Reset the cooldown if we don't have anyone in range OR we ran out of current_chain
# 		fire_weapon()

# Check if we've reached the level allowing for a variety of bonus level-based effects.
func is_final_chain_full_damage() -> bool: return level >= FINAL_CHAIN_FULL_DAMAGE_LEVEL
func is_splittable() -> bool: return level >= ARC_SPLIT_LEVEL
func is_splitting_this_attack() -> bool: return true if randf() <= ARC_SPLIT_CHANCE else false # Check to see if we actually arced
func is_stun_enabled() -> bool: return level >= APPLY_STUN_LEVEL

# If the weapon isn't currently charging then reset the cooldown.
func critical_hit_cooldown_reset() -> void:
	if cooldown_timer.is_stopped(): fire_weapon()
	# print_debug("Scored a crit! Cooldown reset!")

# Get the chain modifier from the array for modifying our damage.
func get_chain_modifier(chain: int) -> float:
	var mod_index = 0
	for key in chain_modifiers.keys():
		if chain >= key:
			mod_index = key
	return chain_modifiers.get(mod_index, 1.0)

# Level 2 Critical hits may reset cooldown.
# Level 3 "Faster chaining speed"
# Level 5 needs arc split to extra target (maybe)
# Level 7 (Overhaul) Last jump explodes in aoe
# Range increase?

func level_up() -> void:
	if first_level_up:
		first_level_up = false
	else:
		level += 1
		match level:
			2:
				# Critical hits may reset cooldown. - DONE
				max_chains = 3
				crit_chance = 0.05
				crit_mod = 1.25
				critical_hit.connect(critical_hit_cooldown_reset)
			3:
				# Faster chaining speed. - DONE
				max_chains = 5
				jump_speed *= 0.75
				crit_chance += 0.05
			4:
				# Apply a slight stun (0.2?) on hit. - DONE
				max_chains = 7
				crit_chance += 0.05
			5:
				# Arcs split to 2 enemies if close enough. - DONE
				max_chains = 10
			6: 
				# Final Chain deals full damage. - DONE
				max_chains = 13
			7: 
				# Last jump explodes
				# This level is handled by the OVERHAUL_ENABLED const rather than a bool
				# var overhaul_enabled = true
				max_chains = 16
				crit_chance += 0.05
	super.level_up()
	fire_weapon()

func get_level_up_text() -> String:
	if first_level_up: return description
	else:
		match level + 1:
			2: return "\nCritical hits may reset cooldown.\nIncreased crit chance.\n\nMax Chains: 3"
			3: return "\nFaster chaining speed.\nIncreased crit chance.\n\nMax Chains: 5"
			4: return "\nApply stun on hit.\nIncreased crit chance.\n\nMax Chains: 7"
			5: return "\nArcs occasionally split to two enemies.\n\nMax Chains: 10"
			6: return "\nFinal chain deals full damage.\n\nMax Chains: 13"
			7: return "\nSignature: Last jump explodes.\nIncreased crit chance.\n\nMax Chains: 16"
	return "Error! get_level_text() of Chain Lightning dropped out of switch!"


func _on_body_entered(_body: Node2D) -> void:
	fire_lightning()
