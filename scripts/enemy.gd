extends CharacterBody2D

const SPEED = 100.0
const MAX_HEALTH = 3
var health: float = 3

# Booleans
var is_dead: bool = false
var death_animation_over: bool = false

var player

func _ready() -> void:
	player = GameController.player
	
	$Spritesheet.play();

func _physics_process(delta: float) -> void:
	if not is_dead:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * SPEED # Character body automatically applies delta
		move_and_slide()
		
	elif death_animation_over:
		GameController.stop_tracking_enemy(self)
		queue_free()

func take_damage(damage: float) -> void:
	health -= damage
	if health <= 0 && not is_dead:
		# Spawn an explosion of some kind? use call_deferred if you do
		# Spawn an experience orb
		GameController.spawn_experience_orb(global_position)
		# %CollisionShape2D.disabled = true
		%CollisionShape2D.set_deferred("disabled", true)
		# print_debug("We died at " + str(global_position.x) + "," + str(global_position.y))
		$Spritesheet.animation = "slime_death"
		$Spritesheet.play()
		
		$DeathSound.play()
		is_dead = true

func _on_spritesheet_animation_finished() -> void:
	if(is_dead):
		death_animation_over = true
