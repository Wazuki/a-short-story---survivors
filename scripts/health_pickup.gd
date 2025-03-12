extends Area2D

const HEALTH_PICKUP_VAL = 0.15


var speed = 250.0
var spawn_speed = 100.0

var spawn_pos
var move_on_spawn = true

var player

func _ready() -> void:
	player = GameController.player
	# add_to_group("Pickups")


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

# Once we touch the player, destroy self and heal the player a fixed amount
func _on_body_entered(body: Node2D) -> void:
	if body == GameController.player:
		body.heal_damage(HEALTH_PICKUP_VAL)		
		# GameController.total_xp_gained += xp_value
		# print_debug("Total XP Gained: " + str(GameController.total_xp_gained))
		queue_free()
	else: move_on_spawn = false
