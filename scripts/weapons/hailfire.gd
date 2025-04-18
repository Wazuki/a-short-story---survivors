class_name Hailfire
extends Weapon
# A rapid-fire submachinegun that fires a torrent of rounds, bounces, and knocks back.
const BOUNCE_LEVEL = 4
const PIERCE_LEVEL = 6

### Hailfire specific variables. ###
# Statistics
var max_range: float ## How far the bullets should travel before queue_free()
var fire_angle: float ## The angle variance that the bullets will have, from (-fire_angle, fire_angle)
var base_fire_rate: float ## How maybe bullets should be fired each second.
var current_fire_rate: float ## The current adjusted rate of fire.
var max_fire_rate: float ## The maximum rate of fire per second.
var projectiles_per_attack: int ## How maybe bullets to spawn before reloading (e.g., goes on cooldown)
var bounce_value: float ## The bounce value for the weapon.

# Attack Sequence Properties
var current_target: Node2D
var last_target_pos: Vector2
var projectiles_fired: int
var firing: bool = false ## Used to handle the current weapon state.
var fire_timer: float = 0.0
var ramp_speed: float = 3.0
var knockback_status: Knockback ## The knockback status that affects every bullet

## Initializes the weapon from the data. Accepts [data: WeaponData]
func initialize(data: WeaponData) -> void:
	super.initialize(data)
	# Initialize any weapon-specific attributes.
	max_range = data.max_range
	fire_angle = data.fire_angle
	base_fire_rate = data.base_fire_rate
	ramp_speed = data.ramp_speed
	max_fire_rate = data.max_fire_rate
	projectiles_per_attack = data.projectiles_per_attack
	bounce_value = data.bounce_value

	# Copy the knockback status from the data
	knockback_status = data.knockback_status

## Determine the weapon firing logic.
func _physics_process(delta: float) -> void:
	fire_sequence(delta)

## Handles the firing sequence for the weapon.
func fire_sequence(delta: float) -> void:
	# Make sure we're allowed to fire and there are enemies in range.
	if ready_to_fire and not firing and not enemies_in_range.is_empty(): 
		firing = true
		begin_attack_sequence.emit()
		#print_debug("Attempting to fire.")
 	# If we're ARE firing, we should enter the attack sequence.
	if firing:
		#print_debug("Enter fire sequence")
		# Increment the fire timer. If it's above the current fire rate, then we should fire, and reset the fire rate.
		fire_timer += delta
		if fire_timer >= (1.0 / current_fire_rate):
			fire_bullet()
			# Reset the fire timer now that we've fired.
			fire_timer -= (1.0 / current_fire_rate) # Subtract, instead of resetting, to account for drift and precision.
		# After checking to see if we can fire, ramp the fire speed clamped by base and max.
		current_fire_rate = clamp(current_fire_rate + (ramp_speed * delta), base_fire_rate, max_fire_rate)


## Spawn the bullet facing our current target.
func fire_bullet() -> void:
	# Pick a random target. If we don't have one, target the last pos.
	if current_target == null: 
		current_target = get_random_target_in_range()
		if current_target != null: last_target_pos = current_target.global_position
	#look_at(last_target_pos) # Turn to face the last target pos since this will ALWAYS be both our current and last target.
	#rotation_degrees += randf_range(-fire_angle, fire_angle) # Adjust the angle somewhat to compensate for "spread" from the fire angle.

	# Instantiate the bullet based on our data and our target and position.
	var new_projectile = instantiate_projectile_by_key(SceneKey.PROJECTILE, global_position, SpriteConstants.Z_INDEX.HAILFIRE, current_target)
	WeaponManager.call_deferred("add_child", new_projectile)
	new_projectile.call_deferred("apply_firing_angle_variance", randf_range(-fire_angle, fire_angle)) # Adjust the angle of the bullet to compensate for the spread.
	#new_bullet.set_deferred("top_level", true)
	
	# Increment the bullet counter. If it's the first bullet, play the firstt sound. Otherwise play the audio from each bullet.
	projectiles_fired +=1
	if projectiles_fired == 1: %HailfireFirstShot.play()
	else: new_projectile.play_attack_sound()

	# Check if we've fired all our bullets. If so we should go on cooldown, end the firing sequence, and reset the fire rate.
	if projectiles_fired >= projectiles_per_attack:
		# Play the tail shot.
		%HailfireLastShotTail.play()
		# Reset all the variables used for shooting.
		projectiles_fired = 0
		current_fire_rate = base_fire_rate
		current_target = null
		fire_timer = 0
		firing = false
		fire_weapon()
		# Set the weapon on cooldown, disable the firing state.


## Return the total number of bounces our projectile can make:[br]
## Level 4: 1; Level 7: 2; otherwise, 0
func get_bounce_amount() -> int:
	if level < BOUNCE_LEVEL: return 0
	if level >= OVERHAUL_LEVEL: return 2
	if level >= BOUNCE_LEVEL: return 1
	return 0

## Return the total number of times our projectile can pierce:[br]
## Level 6: 1
func get_pierce_amount() -> int:
	if level >= PIERCE_LEVEL: return 1
	return 0

func level_up() -> void:
	# Call the weapon's level up function, then finalize any others that aren't in weapon (projectiles, lifetime, etc)
	super.level_up()
	level += 1
	match level:
		2:
			# Level 2: "Extended Magazine" - Increase total number of shots 
			projectiles_per_attack += 15
			pass
		3:
			# Level 3: "Recoil Compensation" - Reduced spread 
			fire_angle *= 0.5
			pass
		4:
			# Level 4: "Richochet Rounds" - bullets bounce off enemies *once*
			pass
		5:
			# Level 5: "Overclocked Barrel" - Increased fire rate
			base_fire_rate += 1
			max_fire_rate += 2
			pass
		6:
			# Level 6: "Penetrator Rounds" - Pierce enemies once before bouncing
			pass
		7:
			# Level 7: "Suppressing Fire" - Increase knockback and fire rate, bullets bounce *twice*
			base_fire_rate += 2
			max_fire_rate += 2
			knockback_status.intensity *= 2
			pass
	fire_weapon()
