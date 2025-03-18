class_name ExperienceOrb
extends Pickup

const LARGE_XP_THRESHOLD = 10
const HUGE_XP_THRESHOLD = 20

#  TODO: The orb should quickly move away from the player, then slowly float to the player, vanishing and adding XP when hitting them
var speed = 250.0
var spawn_speed = 100.0

var spawn_pos
var absorbing = false
var player: Player


# Call the base _ready() and then set the default values and collision information.
func _ready() -> void:
	super._ready()
	name = "Experience Orb"
	value = 1
	# Experience orbs need to monitor when touching walls and will disable collision when they touch an obstacle.

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

## Initializes the values of the experience orb.[br]
## [b]Parameters:[/b] [pos: Vector2], [xp_value: int]
func initialize(pos: Vector2, xp_value: int) -> void:
	# Need a separate initializtion for global_position because _ready might be called before the pos is set.
	set_value(xp_value)
	# Sets our global position and how far we should move away (our "spawn position", where we land after the move on spawn)
	global_position = pos
	var distance = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	spawn_pos = global_position + (distance * randf_range(50, 150))

## Sets the value of the experience orb and adjusts the sprite and scale based on the value.[br]
## [b]Huge XP:[/b] [constant HUGE_XP_THRESHOLD][br]
## [b]Large XP:[/b] [constant LARGE_XP_THRESHOLD][br]
func set_value(v: int) -> void:
	value = v
	
	#Set the XP to different sprites based on how much XP they have
	if value >= HUGE_XP_THRESHOLD:
		# print_debug("Huge XP")
		%Spritesheet.frame = 2
		scale = Vector2.ONE * 2
	elif value >= LARGE_XP_THRESHOLD:
		# print_debug("Large XP")
		%Spritesheet.frame = 1
		scale = Vector2.ONE * 1.5
	else: %Spritesheet.frame = 0

# # Once we touch the player, destroy self and give the player our XP
# func _on_body_entered(body: Node2D) -> void:
# 	if body == GameController.player:
# 		body.gain_experience(value)
# 		# GameController.stop_tracking_xp_orb(self)
# 		# GameController.total_xp_gained += value
# 		# print_debug("Total XP Gained: " + str(GameController.total_xp_gained))
# 		queue_free()
# 	else: move_on_spawn = false

## Sets the orb as "absorbing", i.e. fly towards the player .
func absorb_xp(p: Player) -> void:
	player = p
	absorbing = true
	# If we're still monitoring, disable it. We no longer need to check for wall collisions.
	if monitoring: disable_monitoring()

## Apply the experience to the player and queue the orb for deletion.
func apply_pickup_to_player(p: Player) -> void:
	# print_debug("Player gained " + str(value) + " XP!")
	p.gain_experience(value)
	queue_free()
