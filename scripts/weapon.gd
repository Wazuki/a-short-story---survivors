extends Node2D

var level: int
var damage: float
var speed: float
var cooldown: float

var cooldown_timer: Timer
var ready_to_fire: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create the weapon timer programmatically.
	cooldown_timer = Timer.new()
	cooldown_timer.connect("timeout", _on_weapon_timer_timeout)
	add_child(cooldown_timer)
	# cooldown_timer.wait_time = cooldown
	
	ready_to_fire = false

func level_up(damage_level_up: float, speed_level_up: float, cooldown_level_up: float) -> void:
	level += 1
	damage *= damage_level_up
	speed *= speed_level_up
	cooldown *= cooldown_level_up
	
	cooldown_timer.stop()
	cooldown_timer.wait_time = cooldown
	
	ready_to_fire = true
	
#func start_timer() -> void:
#	timer.start()

func reset_timer() -> void:
	# print(cooldown_timer)
	cooldown_timer.stop()
	cooldown_timer.wait_time = cooldown
	ready_to_fire = false
	
func fire_weapon() -> void:
	ready_to_fire = false
	cooldown_timer.start()

func set_stats(base_damage: float, base_speed: float, base_cooldown: float):
	level = 1
	damage = base_damage
	speed = base_speed
	cooldown = base_cooldown


func get_damage() -> float:
	return damage
	
func get_speed() -> float:
	return speed


func _on_weapon_timer_timeout() -> void:
	ready_to_fire = true
