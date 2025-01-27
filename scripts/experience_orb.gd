extends Area2D

const LARGE_XP_THRESHOLD = 10
const HUGE_XP_THREADHOLD = 20

#  TODO: The orb should quickly move away from the player, then slowly float to the player, vanishing and adding XP when hitting them
var speed = 250.0
var spawn_speed = 100.0
var xp_value = 1

var spawn_pos
var move_on_spawn = true
var absorbing = false

var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = GameController.player
	# On spawn, move in a little in a random direction.
	# var distance = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	
	# spawn_pos = (distance * randf_range(0.5, 2.5)) + global_position
	# print_debug("We spawned at " + str(global_position.x) + "," + str(global_position.y))
	# print_debug("We want to move to " + str(spawn_pos.x) + "," + str(spawn_pos.y))

func initialize(pos: Vector2, value: int) -> void:
	# Need a separate initializtion for global_position because _ready might be called before the pos is set.
	global_position = pos
	set_value(value)
	
	var distance = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	# spawn_pos = (distance * randf_range(0.5, 2.5)) + global_position
	spawn_pos = global_position + (distance * randf_range(50, 150))
	# print_debug("spawn_pos: " + str(spawn_pos.x) + "," + str(spawn_pos.y))
	# print_debug("global_position: " + str(global_position.x) + "," + str(global_position.y))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# If the player has gotten close enough, move towards them to absorb. Otherwise, on spawn, jump a little in a random direction
	if absorbing: 
		# print_debug("abs")
		# move_on_spawn = false - Unneeded as absorbing has priorty in the if-else
		var velocity = global_position.direction_to(player.global_position) # If XP orbs don't absorb right look here first lmao
		global_position += velocity * speed * delta
	elif move_on_spawn:
		# global_position += spawn_pos * (spawn_speed * delta) - does not work
		var velocity = global_position.direction_to(spawn_pos)
		global_position += velocity * spawn_speed * delta
		# global_position.move_toward(spawn_pos, spawn_speed * delta)
		if global_position.distance_to(spawn_pos) < 1.0:
			move_on_spawn = false

func set_value(v: int) -> void:
	
	xp_value = v
	
	#Set the XP to different sprites based on how much XP they have
	if xp_value >= HUGE_XP_THREADHOLD:
		%Spritesheet.frame = 2
		scale = Vector2.ONE * 2
	elif xp_value >= LARGE_XP_THRESHOLD:
		%Spritesheet.frame = 1
		scale = Vector2.ONE * 1.5
	else: %Spritesheet.frame = 0

# Once we touch the player, destroy self and give the player our XP
func _on_body_entered(body: Node2D) -> void:
	body.gain_experience(xp_value)
	GameController.stop_tracking_xp_orb(self)
	queue_free()
