extends CharacterBody2D

var speed: float = 100.0
var health: float = 3
var damage: float = 1.0
var xp_value: int

# Booleans
var is_dead: bool = false
var death_animation_over: bool = false
var has_health_bar: bool = false

var player

var enemy_types = ["basic", "elite", "boss"]

const BASIC_ENEMY_STATS = {
	"health": 2,
	"speed": 50.0,
	"damage": 1.0,
	"xp_value": 2,
	"scale": Vector2(0.5, 0.5)
}

const ELITE_ENEMY_STATS = {
	"health": 40,
	"speed": 75.0,
	"damage": 2.5,
	"xp_value": 15,
	"scale": Vector2.ONE
}

const BOSS_ENEMY_STATS = {
	"health": 80,
	"speed": 100.0,
	"damage": 5.0,
	"xp_value": 30,
	"scale": Vector2(2, 2)
}

func _ready() -> void:
	player = GameController.player
	
	$Spritesheet.play();

func initialize(enemy_type: String) -> void:
	# Set the stats based on the enemy type
	match enemy_type:
		"basic":
			name = "Basic Enemy"
			health = BASIC_ENEMY_STATS["health"]
			speed = BASIC_ENEMY_STATS["speed"]
			scale = BASIC_ENEMY_STATS["scale"]
			damage = BASIC_ENEMY_STATS["damage"]
			xp_value = BASIC_ENEMY_STATS["xp_value"]
		"elite":
			name = "Elite Enemy"
			health = ELITE_ENEMY_STATS["health"]
			speed = ELITE_ENEMY_STATS["speed"]
			scale = ELITE_ENEMY_STATS["scale"]
			damage = ELITE_ENEMY_STATS["damage"]
			xp_value = ELITE_ENEMY_STATS["xp_value"]
		"boss":
			name = "Boss"
			health = BOSS_ENEMY_STATS["health"]
			speed = BOSS_ENEMY_STATS["speed"]
			scale = BOSS_ENEMY_STATS["scale"]
			damage = BOSS_ENEMY_STATS["damage"]
			xp_value = BOSS_ENEMY_STATS["xp_value"]
			# Only bosses have health bars.
			has_health_bar = true
			$HealthBar.max_value = health
			$HealthBar.value = health
			$HealthBar.visible = true


func _physics_process(_delta: float) -> void:
	if not is_dead:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed # Character body automatically applies delta

		# Flip the sprite based on direction
		if velocity.x < 0:
			$Spritesheet.flip_h = true
		elif velocity.x > 0:
			$Spritesheet.flip_h = false

		move_and_slide()
		
	elif death_animation_over:
		GameController.stop_tracking_enemy(self)
		queue_free()

func take_damage(dam: float) -> void:
	health -= dam
	if has_health_bar: $HealthBar.value = health

	if health <= 0 && not is_dead:
		# Spawn an explosion of some kind? use call_deferred if you do
		# Spawn an experience orb
		GameController.spawn_experience_orb(global_position, xp_value)
		# %CollisionShape2D.disabled = true
		%CollisionShape2D.set_deferred("disabled", true)
		# print_debug("We died at " + str(global_position.x) + "," + str(global_position.y))
		$Spritesheet.animation = "death"
		$Spritesheet.play()
		%HealthBar.queue_free()
		$DeathSound.play()
		is_dead = true

func _on_spritesheet_animation_finished() -> void:
	if(is_dead):
		death_animation_over = true
