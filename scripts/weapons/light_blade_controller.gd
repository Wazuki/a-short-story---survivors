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

var light_blade_bullet: Bullet
var slashes: int
var final_slash_scale: Vector2
var final_slash_damage_mod: float
var current_slash: int = 0
var currently_slashing: bool = false

## Initialize the weapon statistics before being added to the scene tree.
func initialize(data: WeaponData) -> void:
	super.initialize(data)
	# Call any remaining specific intialization below.
	slashes = data.initial_slashes
	weapon_scale = Vector2(data.initial_scale, data.initial_scale)
	final_slash_scale = Vector2(data.final_slash_scale, data.final_slash_scale)
	final_slash_damage_mod = data.final_slash_damage_mod
	# Instantiate the main bullet for the weappon since this is a melee weapon.
	light_blade_bullet = instantiate_bullet_by_key(SceneKey.BULLET, global_position, SpriteConstants.Z_INDEX.LIGHT_BLADE)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	# Now that we're in the scene tree, add the light blade bullet as a child of our weapon.
	add_child(light_blade_bullet)
	#light_blade_bullet.get_child("Spritesheet").connect("animation_finished", end_slash)
	#spritesheet.connect("animation_finished", end_slash)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	#super._physics_process(_delta)
	slash()

func slash() -> void:
	# Slash once, then, once the animation ends, slash again until reaching the final slash.
	if ready_to_fire and not currently_slashing and not enemies_in_range.is_empty():
		begin_attack_sequence.emit() # Tell the listeners (Cooldown Panel et al) that we have started attacking.
		if current_slash < slashes:
			## Pause for a frame or so to prevent engine weirdness with animation doubling? Testing function
			# await get_tree().create_timer(get_process_delta_time()).timeout
			current_slash += 1
			currently_slashing = true
			if closest_enemy == null: get_closest_target()
			look_at(closest_enemy.global_position)

			# Set the damage based on the current slash and play the correct sound
			if current_slash == 3: 
				%BigSlash.play()
				light_blade_bullet.damage = damage * final_slash_damage_mod
				light_blade_bullet.scale = final_slash_scale
				if is_overhaul_enabled(): light_blade_bullet.cause_knockback = true # In theory, this will only ever be called at level 7 so no need to change it otherwise since it'llb e false from previous calls
			else: 
				%Slash.play()
				light_blade_bullet.damage = damage
				light_blade_bullet.scale = weapon_scale
				light_blade_bullet.cause_knockback = false

			light_blade_bullet.play_slash_animation(current_slash)
			# %LightBlade.damage_enemies_in_slash()
			# print_debug("Slash " + str(current_slash))


		else:
			reset_attack_chain()

func end_slash() -> void: 
	currently_slashing = false
	light_blade_bullet.reset_damaged_enemies()
	# If we are currently on the last attack chain, reset the weapon.
	if current_slash >= slashes: reset_attack_chain()

func reset_attack_chain() -> void:
	# Reset the timer and the slash count.
	light_blade_bullet.reset_animation()
	fire_weapon()
	current_slash = 0
	# print_debug("Resetting slash")


# func _on_body_entered(_body: Node2D) -> void:
# 	slash()
	

func level_up() -> void:
	# Call the weapon's level up function, then finalize any others that aren't in weapon (projectiles, lifetime, etc)
	super.level_up()
	level += 1
	match level:
		2:
			# Level 2: ~10% damage increase, attack speed increase
			damage *= 1.1
			cooldown *= 0.9
		3:
			# Level 3: Increased size?
			weapon_scale *= 1.1
			final_slash_scale *= 1.1
		4:
			# Level 4: ~10% damage increase
			damage *= 1.1

		5:
			# Level 5: Third slash deals extra damage
			slashes = 3
		6:
			# Level 6: Reduce cooldown between slashes or extend reach on last slam?
			cooldown *= 9
			final_slash_scale *= 1.5
		7:
			# Level 7: Last slash gets extra effect: knockback
			# Level up UI handles checking if the weapon is a levle up option. Duh.
			pass
	fire_weapon()

# Upgrade Plan
# Level 1: 2 swipe combo
# Level 2: ~10% damage increase, attack speed increase
# Level 3: Increased size?
# Level 4: ~10% damage increase
# Level 5: Third slash with windup? deals extra damage
# Level 6: Reduce cooldown between slashes or extend reach on last slam?
# Level 7: Last slash gets extra effect (knockback? crit chance? buff?)
