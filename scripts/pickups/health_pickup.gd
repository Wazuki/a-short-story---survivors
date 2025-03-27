class_name HealthPickup
extends Pickup

const HEALTH_PICKUP_VAL = 0.15

var speed = 250.0
var spawn_speed = 100.0

var spawn_pos

func _ready() -> void:
	name = "Floor Chicken"
	value = HEALTH_PICKUP_VAL
	# add_to_group("Pickups")

## Initialize the health pickup with a [pos: Vector2] global position.
func initialize(pos: Vector2) -> void:
	# Need a separate initializtion for global_position because _ready might be called before the pos is set.
	global_position = pos
	
	var distance = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	# spawn_pos = (distance * randf_range(0.5, 2.5)) + global_position
	spawn_pos = global_position + (distance * randf_range(50, 150))
	# print_debug("spawn_pos: " + str(spawn_pos.x) + "," + str(spawn_pos.y))
	# print_debug("global_position: " + str(global_position.x) + "," + str(global_position.y))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if move_on_spawn:
		# global_position += spawn_pos * (spawn_speed * delta) - does not work
		var velocity = global_position.direction_to(spawn_pos)
		global_position += velocity * spawn_speed * delta
		# global_position.move_toward(spawn_pos, spawn_speed * delta)
		if global_position.distance_to(spawn_pos) < 1.0:
			move_on_spawn = false
			disable_monitoring()

## Heal the player for the specified amount.
func apply_pickup_to_player(player: Player) -> void:
	player.heal_damage(value)
	queue_free()
