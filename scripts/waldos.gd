extends Area2D

const BASE_DAMAGE = 0.5
const BASE_SPEED = PI / 2
# const BASE_COOLDOWN = 1.5
const BASE_COOLDOWN = 0.5
const BASE_SCALE = 1.0

#Level up stats
const LEVEL_UP_DAMAGE = 1.2
# const LEVEL_UP_SPEED = 1.2
const LEVEL_UP_COOLDOWN = 0.99
const LEVEL_UP_SCALE = 1.05


var icon: AtlasTexture = preload("res://sprites/frames/waldos_icon.tres")

var first_level_up

var weapon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	name = "Spinning Waldos"
	weapon = preload("res://prefabs/weapon.tscn").instantiate()
	add_child(weapon)
	# reset()

func reset() -> void:
	weapon.set_stats(BASE_DAMAGE, 1.0, 1.0)
	weapon.reset_timer()
	scale = Vector2(BASE_SCALE, BASE_SCALE)
	first_level_up = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	rotation += BASE_SPEED * delta

	if weapon.ready_to_fire:
		var colliding_bodies = get_overlapping_bodies()
		if colliding_bodies.size() > 0:
			deal_damage(colliding_bodies)
			weapon.fire_weapon()

func deal_damage(colliding_bodies: Array[Node2D]) -> void:
	for e in colliding_bodies:
		e.take_damage(weapon.damage)


	

func level_up() -> void:
	# Call the weapon's level up function, then finalize any others that aren't in weapon (projectiles, lifetime, etc)
	if first_level_up:
		first_level_up = false
		visible = true
		weapon.fire_weapon()
		return
	
	weapon.level_up(LEVEL_UP_DAMAGE, 1.0, LEVEL_UP_COOLDOWN)
	scale *= LEVEL_UP_SCALE
	weapon.fire_weapon() # Design this way, the player starts with the cooldown instead of getting a "free shot".



func get_level_up_text() -> String:
	# Need to watch order of operations especially with modulus and concatenating strings!
	var level_up_string: String
	if first_level_up: level_up_string = "Level 1\nDamage " + str(weapon.damage) + "\nInterval " + str(weapon.cooldown) + "/s";
	else: 
		level_up_string = "Level " + str(weapon.level) + " -> " + str(weapon.level + 1) + "\n"
		level_up_string += "Damage " + str(GameController.round_to_dec(weapon.damage, 2)) + " -> " + str(GameController.round_to_dec(weapon.damage * LEVEL_UP_DAMAGE, 2)) + "\n"
		level_up_string += "Size " + str(GameController.round_to_dec(scale.x, 2)) + " -> " + str(GameController.round_to_dec(scale.x * LEVEL_UP_SCALE, 2)) + "\n"
		level_up_string += "Interval " + str(GameController.round_to_dec(weapon.cooldown, 2)) + "s -> " + str(GameController.round_to_dec((weapon.cooldown * LEVEL_UP_COOLDOWN),2)) + "s";
		
	return level_up_string
