extends Marker2D

const BASE_DAMAGE = 4.0
const BASE_SPEED = 1.0
const BASE_COOLDOWN = 1.5
const BASE_SLASHES = 1
const BASE_SCALE = Vector2.ONE

#Level up stats
const LEVEL_UP_DAMAGE = 1.2
const LEVEL_UP_SPEED = 1.2
const LEVEL_UP_SLASHES_MOD = 5
const LEVEL_UP_COOLDOWN = 0.99
const LEVEL_UP_SCALE = 1.03
const MAX_SLASHES = 3

var icon: AtlasTexture = preload("res://sprites/frames/light_sword_icon.tres")

var first_level_up
var slashes: int = 1
var weapon_scale: Vector2
var weapon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	name = "Light Sword"
	weapon = preload("res://prefabs/weapon.tscn").instantiate()
	add_child(weapon)
	# reset()

func reset() -> void:
	weapon.set_stats(BASE_DAMAGE, BASE_SPEED, BASE_COOLDOWN)
	weapon.reset_timer()
	slashes = BASE_SLASHES
	weapon_scale = BASE_SCALE

	first_level_up = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if weapon.ready_to_fire:
		# Spawn swords!
		spawn_new_light_sword()

# Handles timing and spawning swords whenever the Weapon timer expires, called on physics process
func spawn_new_light_sword() -> void:
	# Look towards the closest target, then spawn the slashes
	look_at(GameController.player.get_closest_target())

	var new_sword = preload("res://prefabs/light_sword_bullet.tscn").instantiate()
	new_sword.set_stats(weapon.damage, slashes)
	add_child(new_sword)
	# new_sword.position.x += weapon.level # Slowly add the weapon's level to the x position to offset hte ever-increasing scale.
	new_sword.scale = weapon_scale
	weapon.fire_weapon()
	

func level_up() -> void:
	# Call the weapon's level up function, then finalize any others that aren't in weapon (projectiles, lifetime, etc)
	if first_level_up:
		first_level_up = false
		weapon.fire_weapon()
		return
	
	weapon.level_up(LEVEL_UP_DAMAGE, LEVEL_UP_SPEED, LEVEL_UP_COOLDOWN)
	slashes = slashes + 1 if (weapon.level % LEVEL_UP_SLASHES_MOD) == 0 else slashes
	slashes = clamp(slashes, 1, MAX_SLASHES)

	weapon_scale *= LEVEL_UP_SCALE
	
	weapon.fire_weapon() # Design this way, the player starts with the cooldown instead of getting a "free shot".


func get_level_up_text() -> String:
	# Need to watch order of operations especially with modulus and concatenating strings!
	var new_slashes: int = slashes + 1 if ((weapon.level +1) % LEVEL_UP_SLASHES_MOD) == 0 else slashes
	new_slashes = clamp(new_slashes, 1, MAX_SLASHES)
	
	var level_up_string: String
	if first_level_up: level_up_string = "Level 1\nDamage " + str(weapon.damage) + "\nSlashes " + str(slashes)+ "\nCooldown " + str(weapon.cooldown) + "s";
	else: 
		level_up_string = "Level " + str(weapon.level) + " -> " + str(weapon.level + 1) + "\n"
		level_up_string += "Damage " + str(GameController.round_to_dec(weapon.damage, 2)) + " -> " + str(GameController.round_to_dec(weapon.damage * LEVEL_UP_DAMAGE, 2)) + "\n"
		level_up_string += "Slashes " + str(slashes) + " -> " + str(new_slashes) + "\n"
		level_up_string += "Cooldown " + str(GameController.round_to_dec(weapon.cooldown, 2)) + "s -> " + str(GameController.round_to_dec((weapon.cooldown * LEVEL_UP_COOLDOWN),2)) + "s";
		
	return level_up_string
