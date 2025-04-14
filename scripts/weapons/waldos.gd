class_name Waldos
extends Weapon

const SLOW_ENABLED_LEVEL = 4
const INNER_RING_LEVEL = 5
const SHIELD_ENABLED_LEVEL = 6
# const BASE_DAMAGE = 8.0
# const BASE_SPEED = PI / 2
# # const BASE_COOLDOWN = 1.5
# const BASE_COOLDOWN = 0.5
# const BASE_SCALE = Vector2.ONE
# const SLOW_VALUE = 0.25
# const OVERHAUL_GROWTH_RATE = Vector2(0.3, 0.3)
# #Level up stats
# # const LEVEL_UP_DAMAGE = 1.2
# # const LEVEL_UP_SPEED = 1.2
# # const LEVEL_UP_COOLDOWN = 0.99
# # const LEVEL_UP_SCALE = 1.05


#var weapon_scale: Vector2
var inner_ring
var inner_ring_scale: Vector2
var max_inner_ring_scale : Vector2

var overhaul_growth_rate: Vector2
var max_scale: Vector2
var expanding: bool = false
var can_shield: bool = false
var shield_cooldown: float

var shield_status: Shield ## The shield status to apply to the player when unlocked.
var slow_status: Slow ## The slow status to apply to enemies when hit.

# var inner_ring_enemies = {}

func initialize(data: WeaponData) -> void:
	super.initialize(data)
	# Set any Waldos-specific variables as well!
	inner_ring_scale = data.inner_ring_scale
	max_inner_ring_scale = data.max_inner_ring_scale
	overhaul_growth_rate = data.overhaul_growth_rate
	max_scale = data.max_scale
	shield_cooldown = data.shield_cooldown
	# Instantiate the status effects
	shield_status = data.shield_status
	slow_status = data.slow_status
	#slow_status_effect.initialize(1, slow_value) # Small slow. TODO - implement this properly like, immediately.
	#print_debug("Slow: " + str(slow_status_effect.duration) + "s, " + str(slow_status_effect.intensity))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Check if we can apply a shield to the player.
	if is_shield_enabled():
		# Set all the shield variables BEFORE passing it to the player!
		#var shield = Shield.new(99999)
		GameController.player.effect_manager.apply_effect(shield_status)
		# Connect the new shield instance in the effect manager to the signal to restart the shield.
		GameController.player.effect_manager.connect_signal(typeof(shield_status), "shield_destroyed", %ShieldTimer.start)
		can_shield = false # Disable the shield effect until it's removed by a signal and the timer refires.
		# Set the shield timer
		%ShieldTimer.wait_time = shield_cooldown

	rotation += speed * delta
	#%InnerRing.rotation -= BASE_SPEED * delta * 2 # Have to double this to make it spin opposite due to the parent also spinning

	if is_overhaul_enabled():
		# Burst mode
		if expanding:
			scale = clamp(scale + overhaul_growth_rate * delta, weapon_scale, max_scale)
			if scale.x >= max_scale.x:
				expanding = false
				#print_debug("expand")
		else:
			scale = clamp(scale - overhaul_growth_rate * delta, weapon_scale, max_scale)
			if scale.x <= weapon_scale.x:
				expanding = true
				#print_debug("shrink")

	# Deal damage to every
	if ready_to_fire and not enemies_in_range.is_empty():
		deal_damage(enemies_in_range.values())
		fire_weapon()
		# Check to see if the inner ring is enabled. If so, repeat the process.

		# print_debug("Inner ring dealt damage")
		# Probably unnessary but a safety check for weird corner cases
		#fire_weapon()


## Deal damage to each enemy in range.
func deal_damage(enemies: Array) -> void:
	for e in enemies:
		if e.dead: continue
		if is_slow_enabled(): e.take_damage(damage, slow_status)
		else: e.take_damage(damage)
		#e.take_damage(damage)
		#if is_slow_enabled(): e.apply_slow(slow_value)


# Level 1: Base: a slowly expanding, passive damage field.
# Level 2: Increase size growth rate and a slight damage boost.
# Level 3: Increase the rotation speed so it covers more area per unit time.
# Level 4: Introduce a secondary effect, like a brief slow on enemies.
# Level 5: New Mechanic: Unlock a secondary ring (or an inner core) that deals extra damage.
# Level 6: Further boost the damage per tick and perhaps add a small shield effect to the player.
# Level 7: Signature Overhaul: The weapon might gain a temporary burst mode, where its rotation speeds up dramatically or its area significantly increases for a short period.

func level_up() -> void:
	# Call the weapon's level up function, then finalize any others that aren't in weapon (projectiles, lifetime, etc)
	super.level_up()
	level += 1
	match level:
		2:
			# Level 2: ~10% damage and scale increase
			damage *= 1.1
			weapon_scale *= 1.25
		3:
			# Level 3: Increased damage frequency (basically Cooldown)
			cooldown *= 0.9
		4:
			# Level 4: Slow enemies on hit
			pass # Handled internally by consts.
		5:
			# Level 5: Add inner core that deals bonus damage
			inner_ring = instantiate_bullet_by_key(SceneKey.BULLET, global_position, SpriteConstants.Z_INDEX.INNER_WALDOS)
			call_deferred("add_child", inner_ring)
			# # Assign the inner ring to the RemoteTransform2D so it'll follow the main waldos without scaling. Defer everything since not in tree yet.
			# %RemoteTransform2D.set_deferred("remote_path", inner_ring.call_deferred("get_path"))
			# #%RemoteTransform2D.remote_path = inner_ring.get_path()
		6:
			# Level 6: Further boost damage frequency and add a shield effect
			cooldown *= 9
			can_shield = true
		7:
			# Level 7: Signature overhaul - burst mode? 
			# Level up UI handles checking if the weapon is a levle up option. Duh.
			#overhaul_enabled = true
			inner_ring.scale = max_inner_ring_scale
			expanding = true
				
	scale = weapon_scale
	fire_weapon()

## Returns whether or not slow is enabled based on the weapon's level and the defined consts.
func is_slow_enabled() -> bool: return level >= SLOW_ENABLED_LEVEL
func is_shield_enabled() -> bool:  ## Returns whether or not the shield effect is enabled and if we are able to shield.
	if level >= SHIELD_ENABLED_LEVEL and can_shield: return true
	return false

func _on_shield_timer_timeout() -> void:
	can_shield = true # Re-enable the shield effect after the cooldown is over.
	#print_debug("Shield timer over")
