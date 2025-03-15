class_name  Weapon extends Area2D

enum Type { SLAM, LIGHT_BLADE, WALDOS, ARROW, CHAIN_LIGHTNING}

var weapon_type: Type
var description: String

var level: int
var damage: float
var speed: float
var cooldown: float

var crit_chance: float
var crit_mod: float

var cooldown_timer: Timer
var ready_to_fire: bool

var first_level_up: bool = true

var cooldown_panel

const OVERHAUL_LEVEL = 7

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create the weapon timer programmatically.
	cooldown_timer = Timer.new()
	cooldown_timer.connect("timeout", _on_weapon_timer_timeout)
	add_child(cooldown_timer)
	# cooldown_timer.wait_time = cooldown
	
	crit_chance = 0
	crit_mod = 0
	
	ready_to_fire = false

# Helper targeting functions!
func get_closest_target() -> Vector2:
	# Return the closest mob that overlaps the weapon range collider - TODO: adjustable range?
	var enemies_in_range: Array[Node2D] = get_overlapping_bodies()
	if not enemies_in_range.is_empty():
		var closest_enemy = enemies_in_range[0]
		for e in enemies_in_range:
			if e.global_position.distance_to(global_position) < closest_enemy.global_position.distance_to(global_position):
				closest_enemy = e
		# print("Closest enemy is " + closest_enemy.name)
		return closest_enemy.global_position
	return Vector2.ZERO


func get_highest_hp_target() -> Vector2:
	# Returns the highest HP enemy in range.
	var enemies_in_range: Array[Node2D] = get_overlapping_bodies()
	if not enemies_in_range.is_empty():
		var highest_hp_enemy = enemies_in_range[0]
		for e in enemies_in_range:
			if e.health > highest_hp_enemy.health:
				highest_hp_enemy = e
		return highest_hp_enemy.global_position
	return Vector2.ZERO

# func level_up(damage_level_up: float, speed_level_up: float, cooldown_level_up: float) -> void:
# 	level += 1
# 	damage *= damage_level_up
# 	speed *= speed_level_up
# 	cooldown *= cooldown_level_up
	
# 	cooldown_timer.stop()
# 	cooldown_timer.wait_time = cooldown
	
# 	ready_to_fire = true
# 	print_debug("Warning! This function should no longer be called!")
	
#func start_timer() -> void:
#	timer.start()

func reset_timer() -> void:
	# print(cooldown_timer)
	cooldown_timer.stop()
	cooldown_timer.wait_time = cooldown
	ready_to_fire = false
	
func fire_weapon() -> void:
	# print_debug(get_parent().name + " is firing!")
	ready_to_fire = false
	cooldown_timer.start()

func set_stats(base_damage: float, base_speed: float, base_cooldown: float):
	level = 1
	damage = base_damage
	speed = base_speed
	cooldown = base_cooldown

func _on_weapon_timer_timeout() -> void:
	ready_to_fire = true

# Handles damage calcs for things like critical hits etc.
func damage_calc() -> float:
	if crit_chance == 0:
		return damage
	elif (randf() <= crit_chance):
		# print("Crit with " + get_parent().name)
		return damage * crit_mod
	else: return damage

func get_weapon_range() -> float: return %WeaponRange.shape.radius
