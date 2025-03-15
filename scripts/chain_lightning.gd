extends Weapon

const BASE_DAMAGE = 10
const BASE_COOLDOWN = 2.0
const LIGHTNING_DURATION = 0.125
const STUN_DURATION = 0.2
const INITIAL_MAX_CHAINS = 2

# Level up consts
const APPLY_STUN_LEVEL = 4
const ARC_SPLIT_LEVEL = 5
const FINAL_CHAIN_FULL_DAMAGE_LEVEL = 6
# OVERHAUL_ENABLED = 7 const in base class

@onready var lightning = %Lightning
var icon = preload("res://sprites/wenrexa/Skill Icons (Rounded)/chain_lightning.tres")

var current_chain = 0
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

var hit_targets: Array

func _ready() -> void:
	super._ready()
	description = "A chaining electrical blast."
	reset()

func reset() -> void:
	current_chain = 0
	max_chains = INITIAL_MAX_CHAINS
	cooldown_timer.wait_time = BASE_COOLDOWN
	damage = BASE_DAMAGE
	level = 1
	ready_to_fire = false



# Attack process:
# 1. Find a random enemy in range.
# 2. If the enemy is in range, launch the lightning at it.
# 3. Once the tween ends (the enemy is hit), find the next closest enemy and repeat.

func _physics_process(_delta: float) -> void:
	fire_lightning()

func fire_lightning() -> void:
	# Check if an enemy is in range. If so, fire the lightning.
	if ready_to_fire:
		# Reset the global position of the lightning to our pos.
		%Lightning.global_position = global_position
		# Reset the targets we've hit and the current chain count, then fire the weapon.
		hit_targets.clear()
		current_chain = 0

		if has_overlapping_bodies():
			# print_debug("zap")
			%LightningSounds.play()
			ready_to_fire = false
			current_chain += 1
			hit_targets.append(get_overlapping_bodies().pick_random())
			var target = hit_targets.front()

			lightning.look_at(target.global_position)
			lightning.animate_lightning(lightning.global_position, target.global_position, LIGHTNING_DURATION)
			damage_target(target)
			# await(get_tree().create_timer(0.3).timeout)


func jump_next_target() -> void:
	# Check if we have any enemies in range of the target we just hit and tween to the next one. Otherwise reset the jump count.
	if %JumpRange.has_overlapping_bodies() and current_chain < max_chains:
		current_chain += 1
		
		# Get a new target randomly based on the overlapping bodies in the jump collider, but make sure we don't hit the same target(s)
		var target = null
		var bodies_in_range: Array = %JumpRange.get_overlapping_bodies()
		bodies_in_range.shuffle()

		# Cycle through the (now randomized) set of bodies we found until we find one we haevn't hit yet and make it a new target.
		for b in bodies_in_range:
			if hit_targets.has(b):
				continue
			else:
				target = b
				break

		# If we still don't have a target it means there aren't any valid targets in range and we should reset the weapon cooldown and leave.
		if target == null: 
			fire_weapon()
			return

		# Now that we have a target, add it to the array so we don't hit it again this cycle.
		hit_targets.append(target)

		# print("Jump! " + str(current_chain))
		lightning.look_at(target.global_position)
		lightning.animate_lightning(lightning.global_position, target.global_position, LIGHTNING_DURATION)
		damage_target(target)

	else: # Reset the cooldown if we don't have anyone in range OR we ran out of current_chain
		fire_weapon()

# Through masking, we should only hit enemies with our abilities.
func damage_target(enemy: Node2D) -> void:
	var damage_mod
	var mod_index = null

	# If we've reached the right level and we are on the final chain, it should deal full damage instead.
	if (level >= FINAL_CHAIN_FULL_DAMAGE_LEVEL and current_chain == max_chains) or current_chain == 1: # The first strike should also deal full damage.
		damage_mod = 1.0
	else:
		# Iterate through the chain modifiers until we find the damage for our current chain.
		for key in chain_modifiers.keys():
			if current_chain >= key:
				mod_index = key

		# Retrieve the proper modifier (defaulting to 1.0 if the key wasn't found) and apply damage to the target with the modifier
		damage_mod = chain_modifiers.get(mod_index, 1.0)


	enemy.take_damage(damage * damage_mod)
	if level >= APPLY_STUN_LEVEL: enemy.apply_stun(STUN_DURATION)

# TODO - Finish implementing entire level up schema (mostly levle up text)
# Level 2 "Sparks linger briefly on hit"
# Level 3 "Faster chaining speed"
# Level 5 needs arc split to extra target (maybe)
# Level 7 (Overhaul) Last jump explodes in aoe
# Range increase?

# DONE
# All max chain counts
# Level 4: Stun
# Level 6: Final chain does full damage
func level_up() -> void:
	if first_level_up:
		first_level_up = false
		fire_weapon()
		return
	else:
		level += 1
		match level:
			2:
				max_chains = 3
			3:
				max_chains = 5
			4:
				# Apply a slight stun (0.2?) on hit.
				max_chains = 7
			5:
				# Arcs split to 2 enemies if close enough.
				max_chains = 10
			6: 
				# Final Chain deals full damage.
				max_chains = 13
			7: 
				# This level is handled by the OVERHAUL_ENABLED const rather than a bool
				# var overhaul_enabled = true
				max_chains = 16

	fire_weapon()

func get_level_up_text() -> String:
	if first_level_up: return description
	else:
		match level + 1:
			2: return "Max Chains: 3\nSpark linger on hit.\n(TODO)"
			3: return "Max Chains: 5\nFaster chaining speed.\n(TODO)"
			4: return "Max Chains: 7\nApply stun on hit."
			5: return "Max Chains: 10\nArcs split to two enemies.\n(TODO)"
			6: return "Max Chains: 13\nFinal chain deals full damage."
			7: return "Max Chains: 16\nLast jump explodes.\n(TODO)"
	return "Error! get_level_text() of Chain Lightning dropped out of switch!"


func _on_body_entered(_body: Node2D) -> void:
	fire_lightning()
