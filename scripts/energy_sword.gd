extends Marker2D

const BASE_DAMAGE = 2.0
const BASE_SPEED = PI
const BASE_LIFETIME = 1.0
const BASE_COOLDOWN = 1.5

#Level up stats
const LEVEL_UP_DAMAGE = 1.2
const LEVEL_UP_SPEED = 1.2
const LEVEL_UP_LIFETIME = 1.2
const LEVEL_UP_COOLDOWN = 0.95


var icon: AtlasTexture = preload("res://sprites/frames/energy_sword_icon.tres")

var max_lifetime: float
var first_level_up

var weapon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	name = "Energy Sword"
	weapon = preload("res://prefabs/weapon.tscn").instantiate()
	add_child(weapon)
	# reset()

func reset() -> void:
	weapon.set_stats(BASE_DAMAGE, BASE_SPEED, BASE_COOLDOWN)
	weapon.reset_timer()
	max_lifetime = BASE_LIFETIME
	first_level_up = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if weapon.ready_to_fire:
		# Spawn swords!
		spawn_new_energy_sword()

# Handles timing and spawning swords whenever the Weapon timer expires, called on physics process
func spawn_new_energy_sword() -> void:
	var new_sword = preload("res://prefabs/energy_sword_bullet.tscn").instantiate()
	add_child(new_sword)
	new_sword.position = Vector2.ZERO
	weapon.fire_weapon()
	

func level_up() -> void:
	# Call the weapon's level up function, then finalize any others that aren't in weapon (projectiles, lifetime, etc)
	if first_level_up:
		first_level_up = false
		weapon.fire_weapon()
		return
	
	weapon.level_up(LEVEL_UP_DAMAGE, LEVEL_UP_SPEED, LEVEL_UP_COOLDOWN)
	max_lifetime *= LEVEL_UP_LIFETIME
	
	weapon.fire_weapon() # Design this way, the player starts with the cooldown instead of getting a "free shot".


func get_lifetime() -> float:
	return max_lifetime

func get_damage() -> float:
	return weapon.get_damage()

func get_speed() -> float:
	return weapon.get_speed()

func get_level_up_text() -> String:
	# Need to watch order of operations especially with modulus and concatenating strings!
	var level_up_string: String
	if first_level_up: level_up_string = "Level 1\nDamage " + str(weapon.damage) + "\nSpeed " + str(GameController.round_to_dec(rad_to_deg(weapon.speed), 2)) + "/s\nLifetime " + str(max_lifetime) + "s\nCooldown " + str(weapon.cooldown) + "s";
	else: 
		level_up_string = "Level " + str(weapon.level) + " -> " + str(weapon.level + 1) + "\n"
		level_up_string += "Damage " + str(GameController.round_to_dec(weapon.damage, 2)) + " -> " + str(GameController.round_to_dec(weapon.damage * LEVEL_UP_DAMAGE, 2)) + "\n"
		level_up_string += "Speed " + str(GameController.round_to_dec(rad_to_deg(weapon.speed), 2)) + " -> " + str(GameController.round_to_dec(rad_to_deg(weapon.speed * LEVEL_UP_SPEED),2)) + "\n"
		level_up_string += "Lifetime " + str(max_lifetime) + "s -> " + str(GameController.round_to_dec(max_lifetime * LEVEL_UP_LIFETIME, 2)) + "s\n"
		level_up_string += "Cooldown " + str(GameController.round_to_dec(weapon.cooldown, 2)) + "s -> " + str(GameController.round_to_dec((weapon.cooldown * LEVEL_UP_COOLDOWN),2)) + "s";
		
	return level_up_string
