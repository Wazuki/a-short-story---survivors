class_name ChainLightning
extends Weapon

# Level up consts
const APPLY_STUN_LEVEL = 4
const ARC_SPLIT_LEVEL = 5
const FINAL_CHAIN_FULL_DAMAGE_LEVEL = 6

# Chain lightning specific modifiers.
var chain_modifiers = {} ## Dictionary of chain modifiers for each chain. The key is the number of chains, and the value is the damage modifier.
var max_chains: int ## Number of maximum times chain lightning can chain.
var jump_speed: float ## How long it takes each lightning bolt to travel.

# Modifiers that are level-dependent
var stun_duration: float
var arc_chance: float
var strike_modulus: int ## The number of chains before a lightning strike is spawned.

var stun_effect: Stun

## Initialize the weapon statistics before being added to the scene tree.
func initialize(data: WeaponData) -> void:
	super.initialize(data)
	# Call any remaining specific intialization below.
	chain_modifiers = data.chain_modifiers
	max_chains = data.initial_max_chains
	jump_speed = data.initial_jump_speed
	stun_duration = data.initial_stun_duration
	arc_chance = data.initial_arc_split_chance
	strike_modulus = data.lightning_strike_modulus
	# Create the stun status effect
	stun_effect = Stun.new(stun_duration)


# func reset() -> void:
# 	# current_chain = 0
# 	max_chains = INITIAL_MAX_CHAINS
# 	set_stats(BASE_DAMAGE, 1.0, BASE_COOLDOWN)
# 	first_level_up = true
# 	reset_timer()
# 	# Disconnect the critial hit signal if it's connected.
# 	if critical_hit.is_connected(critical_hit_cooldown_reset): critical_hit.disconnect(critical_hit_cooldown_reset)


# Attack process:
# 1. Find a random enemy in range.
# 2. If the enemy is in range, launch the lightning at it.
# 3. Once the tween ends (the enemy is hit), find the next closest enemy and repeat.

func _physics_process(_delta: float) -> void:
	if ready_to_fire and not enemies_in_range.is_empty():
		fire_lightning()

func fire_lightning() -> void:
	begin_attack_sequence.emit() # Tell the listeners (Cooldown Panel et al) that we have started attacking.
	ready_to_fire = false
	%LightningSounds.play()
	# Spawn a new lightning bullet, set the position to ours, then jump to a random enemy to start the sequence.
	var target = enemies_in_range.values().pick_random()
	spawn_new_lightning_bolt(target)

# TODO - refactor this to be more concise. This lightning spawning logic is rough.
func spawn_new_lightning_bolt(target: Node2D) -> void:
	var new_lightning = instantiate_bullet_by_key(SceneKey.BULLET, global_position, SpriteConstants.Z_INDEX.CHAIN_LIGHTNING, target) as LightningBullet
	new_lightning.set_spawn_state(jump_speed, max_chains, 1, is_splittable())
	add_child(new_lightning)
	new_lightning.global_position = global_position
	#new_lightning.initiailize(jump_speed, max_chains, 1, is_splittable())
	new_lightning.jump_first_target(target)
	new_lightning.jumping_ended.connect(fire_weapon)

func spawn_chained_lightning_bolt(target: Node2D, chain_count: int, start_pos: Vector2) -> void:
	var new_lightning = instantiate_bullet_by_key(SceneKey.BULLET, global_position, SpriteConstants.Z_INDEX.CHAIN_LIGHTNING, target) as LightningBullet
	new_lightning.set_spawn_state(jump_speed, max_chains, chain_count, false)
	add_child(new_lightning)
	new_lightning.global_position = start_pos

	new_lightning.jump_first_target(target)
	new_lightning.jumping_ended.connect(fire_weapon)

## Spawns a lightning strike, an area that deals damage over time.
## [b]Parameters:[/b]: spawn position (Vector2)
func spawn_lightning_stike(spawn_pos: Vector2) -> void:
	# Before spawning, make sure we don't overlap a damage field that's already on the board to reduce clutter.
	if LightningStrike.can_spawn_strike_at_pos(spawn_pos, get_tree()):
		var new_strike = instantiate_bullet_by_key(SceneKey.SECONDARY_BULLET, spawn_pos, SpriteConstants.Z_INDEX.LIGHTNING_STRIKE) as LightningStrike
		# Add it to the scene tree so everything hopefully instantiates properly.
		get_tree().root.add_child(new_strike)
		# get_node("/root/GameScene").add_child(new_strike)


# Check if we've reached the level allowing for a variety of bonus level-based effects.
func is_final_chain_full_damage() -> bool: return level >= FINAL_CHAIN_FULL_DAMAGE_LEVEL
func is_splittable() -> bool: return level >= ARC_SPLIT_LEVEL
func is_splitting_this_attack() -> bool: return true if randf() <= arc_chance else false # Check to see if we actually arced
func get_stun_effect() -> StatusEffect: ## Returns the stun status effect if unlocked, otherwise returns null.
	if level >= APPLY_STUN_LEVEL: return stun_effect
	return null

# If the weapon isn't currently charging then reset the cooldown.
func critical_hit_cooldown_reset() -> void:
	if cooldown_timer.is_stopped(): fire_weapon()
	# print_debug("Scored a crit! Cooldown reset!")

## Returns the appropriate chain damage [b]modifier[/b] based on the current chain.
func calculcate_chain_modifier(chain_num: int) -> float:
	if chain_num == 1 or (is_final_chain_full_damage() and chain_num == max_chains): return 1.0
	else:
		return get_chain_modifier(chain_num)

## Get the chain modifier from the array for modifying our damage.
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

## Level up the weapon and apply its appropriate level up effects.
func level_up() -> void:
	super.level_up()
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
			# Last jump explodes - DONE!!
			# This level is handled by the OVERHAUL_ENABLED const rather than a bool
			# var overhaul_enabled = true
			max_chains = 16
			crit_chance += 0.05
	fire_weapon()

# Moved to base weapon
# func get_level_up_text() -> String:
# 	if first_level_up: return description
# 	else:
# 		match level + 1:
# 			2: return "Critical hits may reset cooldown.\n\nIncreased crit chance.\n\nMax Chains: 3"
# 			3: return "Faster chaining speed.\n\nIncreased crit chance.\n\nMax Chains: 5"
# 			4: return "Apply stun on hit.\n\nIncreased crit chance.\n\nMax Chains: 7"
# 			5: return "Arcs occasionally split to two enemies.\n\nMax Chains: 10"
# 			6: return "Final chain deals full damage.\n\nMax Chains: 13"
# 			7: return "Signature: Every fourth jump creates a damage field if possible.\n\nIncreased crit chance.\n\nMax Chains: 16"
# 	return "Error! get_level_text() of Chain Lightning dropped out of switch!"


# TODO - rewrite damage_calc() for chain_lightning to include chain modifiers etc.
# damage * lightning_strike_damage_modifier
