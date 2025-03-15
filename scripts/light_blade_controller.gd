extends Weapon

const BASE_DAMAGE = 5
# const BASE_SPEED = 1.0
const BASE_COOLDOWN = 1.0
const BASE_SLASHES = 2
const BASE_SCALE = Vector2.ONE
const FINAL_SLASH_DAMAGE_MOD = 1.5

# Level up stats
# const LEVEL_UP_DAMAGE = 1.2
# const LEVEL_UP_SPEED = 1.2
# const LEVEL_UP_SLASHES_MOD = 5
# const LEVEL_UP_COOLDOWN = 0.99
# const LEVEL_UP_SCALE = 1.03
# const MAX_SLASHES = 3

var icon: AtlasTexture = preload("res://sprites/frames/light_sword_icon.tres")
@onready var spritesheet: AnimatedSprite2D = get_child(0).get_child(0)

var slashes: int = 2
var overhaul_enabled: bool = false
var weapon_scale: Vector2
var final_slash_scale: Vector2
var current_slash: int = 0
var currently_slashing: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	name = "Light Sword"
	weapon_type = Type.LIGHT_BLADE
	description = "Two quick sword slashes."
	# weapon = preload("res://prefabs/weapon.tscn").instantiate()
	# add_child(weapon)
	# reset()
	# spritesheet.connect("animation_finished", %LightBlade.damage_enemies_in_slash)
	spritesheet.connect("animation_finished", end_slash)

func reset() -> void:
	set_stats(BASE_DAMAGE, 1.0, BASE_COOLDOWN)
	reset_timer()
	slashes = BASE_SLASHES
	current_slash = 0
	currently_slashing = false
	weapon_scale = BASE_SCALE
	final_slash_scale = BASE_SCALE
	overhaul_enabled = false
	
	first_level_up = true
	# %LightBlade.connect_spritesheet_signal(slash)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	slash()

func slash() -> void:
	# Slash once, then, once the animation ends, slash again until reaching the final slash.
	if ready_to_fire and not currently_slashing and not get_overlapping_bodies().is_empty():
		if current_slash < slashes:
			## Pause for a frame or so to prevent engine weirdness with animation doubling? Testing function
			# await get_tree().create_timer(get_process_delta_time()).timeout
			current_slash += 1
			currently_slashing = true
			look_at(get_closest_target())

			# Set the damage based on the current slash and play the correct sound
			if current_slash == 3: 
				%BigSlash.play()
				%LightBlade.damage = damage * FINAL_SLASH_DAMAGE_MOD
				%LightBlade.scale = final_slash_scale
				if overhaul_enabled: %LightBlade.cause_knockback = true # In theory, this will only ever be called at level 7 so no need to change it otherwise since it'llb e false from previous calls
			else: 
				%Slash.play()
				%LightBlade.damage = damage
				%LightBlade.scale = weapon_scale
				%LightBlade.cause_knockback = false

			%LightBlade.play_slash_animation(current_slash)
			# %LightBlade.damage_enemies_in_slash()
			# print_debug("Slash " + str(current_slash))


		else:
			# Reset the timer and the slash count.
			%LightBlade.reset_animation()
			fire_weapon()
			current_slash = 0
			# print_debug("Resetting slash")

func end_slash() -> void: 
	currently_slashing = false
	%LightBlade.reset_damaged_enemies()

# Handles timing and spawning swords whenever the Weapon timer expires, called on physics process
#func spawn_new_light_sword() -> void:
	# Look towards the closest target, then spawn the slashes
#	look_at(GameController.player.get_closest_target())

#	var new_sword = preload("res://prefabs/light_blade_bullet.tscn").instantiate()
#	new_sword.set_stats(weapon.damage, slashes)
#	add_child(new_sword)
	# new_sword.position.x += weapon.level # Slowly add the weapon's level to the x position to offset hte ever-increasing scale.
#	new_sword.scale = weapon_scale
#	weapon.fire_weapon()
	

func level_up() -> void:
	# Call the weapon's level up function, then finalize any others that aren't in weapon (projectiles, lifetime, etc)
	if first_level_up:
		first_level_up = false
		fire_weapon()
		return
	else:
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
				overhaul_enabled = true
				

		fire_weapon()

# Upgrade Plan
# Level 1: 2 swipe combo
# Level 2: ~10% damage increase, attack speed increase
# Level 3: Increased size?
# Level 4: ~10% damage increase
# Level 5: Third slash with windup? deals extra damage
# Level 6: Reduce cooldown between slashes or extend reach on last slam?
# Level 7: Last slash gets extra effect (knockback? crit chance? buff?)

func get_level_up_text() -> String:
	if first_level_up: return description
	else:
		match level + 1:
			2:
				return "Increased damage and attack speed."
			3:
				return "Increased size."
			4:
				return "Increased damage and attack speed."	
			5:
				return "Third slash that deals bonus damage."
			6:
				return "Increase size of third slash."
			7:
				return "Signature: Cause knockback with third slash."
	return "Error! get_level_text() of Light Blade dropped out of switch!"

func _on_body_entered(_body: Node2D) -> void:
	slash()




#func level_up() -> void:
	# Call the weapon's level up function, then finalize any others that aren't in weapon (projectiles, lifetime, etc)
#	if first_level_up:
#		first_level_up = false
#		weapon.fire_weapon()
#		return
	
#	weapon.level_up(LEVEL_UP_DAMAGE, LEVEL_UP_SPEED, LEVEL_UP_COOLDOWN)
#	slashes = slashes + 1 if (weapon.level % LEVEL_UP_SLASHES_MOD) == 0 else slashes
#	slashes = clamp(slashes, 1, MAX_SLASHES)

#	weapon_scale *= LEVEL_UP_SCALE
	
#	weapon.fire_weapon() # Design this way, the player starts with the cooldown instead of getting a "free shot".


#func get_level_up_text() -> String:
	# Need to watch order of operations especially with modulus and concatenating strings!
#	var new_slashes: int = slashes + 1 if ((weapon.level +1) % LEVEL_UP_SLASHES_MOD) == 0 else slashes
#	new_slashes = clamp(new_slashes, 1, MAX_SLASHES)
	
#	var level_up_string: String
#	if first_level_up: level_up_string = "Level 1\nDamage " + str(weapon.damage) + "\nSlashes " + str(slashes)+ "\nCooldown " + str(weapon.cooldown) + "s";
#	else: 
#		level_up_string = "Level " + str(weapon.level) + " -> " + str(weapon.level + 1) + "\n"
#		level_up_string += "Damage " + str(GameController.round_to_dec(weapon.damage, 2)) + " -> " + str(GameController.round_to_dec(weapon.damage * LEVEL_UP_DAMAGE, 2)) + "\n"
#		level_up_string += "Slashes " + str(slashes) + " -> " + str(new_slashes) + "\n"
#		level_up_string += "Cooldown " + str(GameController.round_to_dec(weapon.cooldown, 2)) + "s -> " + str(GameController.round_to_dec((weapon.cooldown * LEVEL_UP_COOLDOWN),2)) + "s";
		
#	return level_up_string

