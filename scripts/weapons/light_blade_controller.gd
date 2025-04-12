extends Weapon

# const BASE_DAMAGE = 5
# # const BASE_SPEED = 1.0
# const BASE_COOLDOWN = 1.0
# const BASE_SLASHES = 2
# const BASE_SCALE = Vector2.ONE
# const FINAL_SLASH_DAMAGE_MOD = 1.5

# Level up stats
# const LEVEL_UP_DAMAGE = 1.2
# const LEVEL_UP_SPEED = 1.2
# const LEVEL_UP_SLASHES_MOD = 5
# const LEVEL_UP_COOLDOWN = 0.99
# const LEVEL_UP_SCALE = 1.03
# const MAX_SLASHES = 3
const JUMP_SPEED = 1000.0 # The speed at which the player will jump after the last slash.

var light_blade_bullet: Bullet
var final_slash_scale: Vector2
var final_slash_damage_mod: float
var current_slash: int = 0 ## The current slash we are on. This is used to determine the slash animation and damage.
var currently_slashing: bool = false ## Determines if we are currently attacking or not to prevent a transition to the next attack.
var last_target_pos: Vector2 = Vector2.ZERO ## The global position of the last target we attacked.
var jump_time: float = 0.0 ## How long the player can stay in the air after the last slash.
var can_jump: bool = false ## Determines if we can leap into the air as part of the overhaul.

## Initialize the weapon statistics before being added to the scene tree.
func initialize(data: WeaponData) -> void:
	super.initialize(data)
	# Call any remaining specific intialization below.
	projectile_count = data.projectile_count
	weapon_scale = Vector2(data.initial_scale, data.initial_scale)
	final_slash_scale = Vector2(data.final_slash_scale, data.final_slash_scale)
	final_slash_damage_mod = data.final_slash_damage_mod
	jump_time = data.jump_time
	# Instantiate the main bullet for the weappon since this is a melee weapon.
	light_blade_bullet = instantiate_bullet_by_key(SceneKey.BULLET, global_position, SpriteConstants.Z_INDEX.LIGHT_BLADE)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	# Now that we're in the scene tree, add the light blade bullet as a child of our weapon.
	add_child(light_blade_bullet)

	# Connect to the jump signal of the player's state machine.
	GameController.player.state_machine.connect_signal_to_state(AnimationNames.JUMP, "jump_ended", end_jump)

	#light_blade_bullet.get_child("Spritesheet").connect("animation_finished", end_slash)
	#spritesheet.connect("animation_finished", end_slash)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	#super._physics_process(_delta)
	if ready_to_fire and not currently_slashing and (not enemies_in_range.is_empty() or last_target_pos != Vector2.ZERO): # TODO - Consider revisiting this check.
		begin_attack_sequence.emit() # Tell the listeners (Cooldown Panel et al) that we have started attacking.
		slash()

func slash() -> void:
	# Slash once, then, once the animation ends, slash again until reaching the final slash.

	if current_slash < projectile_count:
		## Pause for a frame or so to prevent engine weirdness with animation doubling? Testing function
		# await get_tree().create_timer(get_process_delta_time()).timeout
		currently_slashing = true
		if closest_enemy == null and last_target_pos == Vector2.ZERO: get_closest_target() # We should only get a new target if we don't currently have one.
		if last_target_pos == Vector2.ZERO: # Set the last target pos to the closest enemy's position if we currently don't have one.
			last_target_pos = closest_enemy.global_position
		look_at(last_target_pos)

		%Slash.play()
		light_blade_bullet.damage = damage
		light_blade_bullet.scale = weapon_scale
		light_blade_bullet.cause_knockback = false

		# Adjust our rotation to account for new slash direction.
		# 360 / slash count = angle between slashes
		rotation_degrees += (360.0 / projectile_count) * current_slash # We adjust our rotation since our slash is angled at -90 degrees.


		# # Set the damage based on the current slash and play the correct sound
		# if current_slash == 3: 
		# 	%BigSlash.play()
		# 	light_blade_bullet.damage = damage * final_slash_damage_mod
		# 	light_blade_bullet.scale = final_slash_scale
		# 	if is_overhaul_enabled(): light_blade_bullet.cause_knockback = true # In theory, this will only ever be called at level 7 so no need to change it otherwise since it'llb e false from previous calls
		# else: 
		# 	%Slash.play()
		# 	light_blade_bullet.damage = damage
		# 	light_blade_bullet.scale = weapon_scale
		# 	light_blade_bullet.cause_knockback = false

		current_slash += 1 # Increment the slash at the end to avoid affecting the rotation.
		light_blade_bullet.play_slash_animation(1) # TODO - more slash animations to re-add.
		# %LightBlade.damage_enemies_in_slash()
		# print_debug("Slash " + str(current_slash))

	else:
		reset_attack_chain()

func end_slash() -> void: 
	currently_slashing = false
	light_blade_bullet.reset_damaged_enemies()

	
	# If we are using the overhaul, we can jump after the last slash.
	if can_jump and current_slash == projectile_count: 
		jump()
	# If we are currently on the last attack chain, reset the weapon.
	if current_slash >= projectile_count: reset_attack_chain()

func reset_attack_chain() -> void:
	# Reset the timer and the slash count.
	light_blade_bullet.reset_animation()
	fire_weapon()
	current_slash = 0
	last_target_pos = Vector2.ZERO # Reset the last target position
	
	# Reset the overhaul can_jump variable based on the weapon's level.
	if is_overhaul_enabled(): can_jump = true
	else: can_jump = false
	# print_debug("Resetting slash")

## Allow the player to "leap" into the air after the last slash with overhaul enabled.[br]
func jump() -> void:
		#print_debug("Jumping")
		can_jump = false

		# Change the player's current state to the jumping state.
		# TODO - consider an animation player or something similar to handle state changes a bit smoother.
		GameController.player.state_machine.change_state("jump", { "jump_speed" : JUMP_SPEED, "jump_time" : jump_time,"landing_radius": weapon_range})

## End the jump by dealing damage around the player and then reset the attack cycle.
func end_jump() -> void:
	%BigSlash.play()
	#print_debug("landeD")
	# Deal damage to each enemy in weapon range.
	# Instantiate the secondary bullet to deal damage to all enemies in the area.
	
	var jump_bullet = instantiate_bullet_by_key(SceneKey.IMPACT_EFFECT, global_position, SpriteConstants.Z_INDEX.LANDING_CIRCLE)
	add_child(jump_bullet)
	jump_bullet.top_level = true # Set it to top level so it doesn't follow the player.

	reset_attack_chain()
	#print_debug("landing complete")

# func _on_body_entered(_body: Node2D) -> void:
# 	slash()
	

# func level_up() -> void:
# 	# Call the weapon's level up function, then finalize any others that aren't in weapon (projectiles, lifetime, etc)
# 	super.level_up()
# 	level += 1
# 	match level:
# 		2:
# 			# Level 2: ~10% damage increase, attack speed increase
# 			damage *= 1.1
# 			cooldown *= 0.9
# 		3:
# 			# Level 3: Increased size?
# 			weapon_scale *= 1.1
# 			final_slash_scale *= 1.1
# 		4:
# 			# Level 4: ~10% damage increase
# 			damage *= 1.1

# 		5:
# 			# Level 5: Third slash deals extra damage
# 			#slashes = 3
# 			pass
# 		6:
# 			# Level 6: Reduce cooldown between slashes or extend reach on last slam?
# 			cooldown *= 0.9
# 			final_slash_scale *= 1.5
# 		7:
# 			# Level 7: Last slash gets extra effect: knockback
# 			# Level up UI handles checking if the weapon is a levle up option. Duh.
# 			pass
# 	fire_weapon()

# Upgrade Plan
# Level 1: 2 swipe combo
# Level 2: ~10% damage increase, attack speed increase
# Level 3: Increased size?
# Level 4: ~10% damage increase
# Level 5: Third slash with windup? deals extra damage
# Level 6: Reduce cooldown between slashes or extend reach on last slam?
# Level 7: Last slash gets extra effect (knockback? crit chance? buff?)
