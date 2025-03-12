extends CharacterBody2D

var speed: float = 100.0
var base_speed: float = 100.0
var health: float = 3
var damage: float = 1.0
var xp_value: int
var health_drop_chance: float = 0.0
var enemy_range:float

var knockback_velocity: Vector2
# var knockback_target: Vector2
var knockback_friction: float = 400.0 # The rate at which knockback decays - should decay rapidly, like the enemy is quickly getting their footing back
var slowed_speed: float = 0.0
var slow_decay_rate: float = 5.0

# Booleans
var is_dead: bool = false
var has_health_bar: bool = false
var is_shooting: bool = false
var can_shoot: bool = true
# var knocked_back: bool = false

var player

# var enemy_types = ["basic", "elite", "boss", "ranged"]
enum EnemyType { BASIC, ELITE, BOSS, RANGED }
var enemy_type: EnemyType = EnemyType.BASIC

var basic_enemy_spritesheet = preload("res://sprites/frames/basic_enemy.tres")
var ranged_enemy_spritesheet = preload("res://sprites/frames/ranged_enemy.tres")

var enemy_health_bar_background = preload("res://sprites/frames/enemy_health_bar_background.tres")
var enemy_health_bar = preload("res://sprites/frames/enemy_health_bar_progress_texture.tres")

const BASIC_ENEMY_STATS = {
	"health": 2,
	"speed": 50.0,
	"damage": 1.0,
	"xp_value": 2,
	"scale": Vector2(0.5, 0.5)
}

const RANGED_ENEMY_STATS = {
	"health": 25,
	"speed": 50.0,
	"damage": 12.0,
	"range": 150.00,
	"xp_value": 8,	
	"scale": Vector2(0.75, 0.75),
	"health_drop_chance": 0.1
}

const ELITE_ENEMY_STATS = {
	"health": 40,
	"speed": 75.0,
	"damage": 2.5,
	"xp_value": 15,
	"scale": Vector2.ONE,
	"health_drop_chance": 0.2
}

const BOSS_ENEMY_STATS = {
	"health": 80,
	"speed": 100.0,
	"damage": 5.0,
	"xp_value": 30,
	"scale": Vector2(2, 2),
	"health_drop_chance": 0.5
}




func _ready() -> void:
	player = GameController.player
	
	$Spritesheet.play();



func initialize() -> void:
	# Set the stats based on the enemy type

	var enemy_count = GameController.total_enemies_spawned

	if enemy_count % 50 == 0:
		enemy_type = EnemyType.BOSS
	elif enemy_count % 20 == 0:
		enemy_type = EnemyType.ELITE
	elif enemy_count % 12 == 0:
		enemy_type = EnemyType.RANGED
	else:
		enemy_type = EnemyType.BASIC

	%Spritesheet.sprite_frames = basic_enemy_spritesheet

	match enemy_type:
		EnemyType.BASIC:
			name = "Basic Enemy"
			health = BASIC_ENEMY_STATS["health"]
			speed = BASIC_ENEMY_STATS["speed"]
			scale = BASIC_ENEMY_STATS["scale"]
			damage = BASIC_ENEMY_STATS["damage"]
			xp_value = BASIC_ENEMY_STATS["xp_value"]
		EnemyType.RANGED:
			name = "Ranged Enemy"
			health = RANGED_ENEMY_STATS["health"]
			speed = RANGED_ENEMY_STATS["speed"]
			scale = RANGED_ENEMY_STATS["scale"]
			damage = RANGED_ENEMY_STATS["damage"]
			enemy_range = RANGED_ENEMY_STATS["range"]
			health_drop_chance = RANGED_ENEMY_STATS["health_drop_chance"]
			xp_value = RANGED_ENEMY_STATS["xp_value"]
			%Spritesheet.sprite_frames = ranged_enemy_spritesheet
		EnemyType.ELITE:
			name = "Elite Enemy"
			health = ELITE_ENEMY_STATS["health"]
			speed = ELITE_ENEMY_STATS["speed"]
			scale = ELITE_ENEMY_STATS["scale"]
			damage = ELITE_ENEMY_STATS["damage"]
			health_drop_chance = ELITE_ENEMY_STATS["health_drop_chance"]
			xp_value = ELITE_ENEMY_STATS["xp_value"]
		EnemyType.BOSS:
			name = "Boss"
			health = BOSS_ENEMY_STATS["health"]
			speed = BOSS_ENEMY_STATS["speed"]
			scale = BOSS_ENEMY_STATS["scale"]
			damage = BOSS_ENEMY_STATS["damage"]
			health_drop_chance = BOSS_ENEMY_STATS["health_drop_chance"]
			xp_value = BOSS_ENEMY_STATS["xp_value"]
			# Only bosses have health bars.
			has_health_bar = true
			%HealthBar.init_health(health)
			%HealthBar.set_textures(enemy_health_bar_background, enemy_health_bar)
			$HealthBar.visible = true

	base_speed = speed
	%Spritesheet.animation = "walk"
	%Spritesheet.play()


func _physics_process(delta: float) -> void:

	if knockback_velocity.length() > 0.1:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
		# print_debug("kb velocity: " + str(knockback_velocity))
		velocity = knockback_velocity
		#move_and_slide()

		move_and_collide(velocity * delta)
		#var collision = move_and_collide(velocity * delta)
		#if collision:
		#	var other = collision.get_collider()
		#	if other.has_method("apply_knockback"):
		#		other.apply_knockback(collision.get_normal(), 50)


	elif not is_dead && enemy_type != EnemyType.RANGED:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed # Character body automatically applies delta

		move()
		# TODO - maybe revisit this later?
		# Avoid collision with knocked back enemies
		#for body in %AvoidanceArea.get_overlapping_bodies():
		#	if body != self and body.has_method("apply_knockback") and body.knockback_velocity.length() > 0.1:
		#		# Calculate a lateral push direciton perpendicular to the knockback dir
		#		var direction_sign = 1 if randf() < 0.5 else -1
		#		var push_dir = body.knockback_velocity.rotated(direction_sign * (PI / 2)).normalized()
		#		velocity += push_dir * 50 
	elif not is_dead && enemy_type == EnemyType.RANGED:
		# Ranged movement
		var direction = global_position.direction_to(player.global_position)

		if not is_shooting:
			if  global_position.distance_to(player.global_position) < enemy_range / 3:
				# Move away from the player, they're too close
				direction *= -1
				velocity = direction * speed
			elif not is_shooting and global_position.distance_to(player.global_position) >= enemy_range: # We should only move when we are not shooting and the player is not in our face
				velocity = direction * speed
		else: 
			velocity = Vector2.ZERO


		# Check if the player is within range. If so, shoot at them.
		# Make sure the enemy will get to at least half range before shooting the player.
		if global_position.distance_to(player.global_position) <= enemy_range and can_shoot  and global_position.distance_to(player.global_position) > enemy_range / 2:
			# Shoot a projectile at the player.
			is_shooting = true
			can_shoot = false

			# Flip the sprite to face the player when shooting.
			if player.global_position.x < global_position.x:
				$Spritesheet.flip_h = true
			else:
				$Spritesheet.flip_h = false

			%Spritesheet.animation = "attack"
			%Spritesheet.play()
			# Will fire a projectile at the player at the end of the animation
		else: move()
		
	# Finally, check if the enemy is slowed. If so, decrease the slow effect over time.
	if speed < base_speed: speed = clampf(speed + slow_decay_rate * delta, 0, base_speed)



#	elif not is_dead and knocked_back:
#		# Move the enemy back based on the current velocity.
#		velocity = -knockback_velocity * speed
#		move_and_slide()
#
#		# TODO - fix knockback function. Still not quite right.
#		if global_position.distance_to(knockback_target) < 1.0:
#			knocked_back = false
#			knockback_velocity = Vector2.ZERO
#			knockback_target = Vector2.ZERO

func move() -> void:
	if is_shooting: return

	# Flip the sprite based on direction
	if velocity.x < 0:
		$Spritesheet.flip_h = true
	elif velocity.x > 0:
		$Spritesheet.flip_h = false
	
	if velocity == Vector2.ZERO: %Spritesheet.animation = "idle"
	else: %Spritesheet.animation = "walk"
	%Spritesheet.play()

	move_and_slide()
	
# Slow the enemy by a percentage of their speed
func apply_slow(slow: float) -> void:
	# Only apply slow if the enemy is not already slowed
	if speed == base_speed: speed *= (1.0 - slow)



func take_damage(dam: float) -> void:
	health -= dam
	GameController.total_damage_done += dam
	
	if has_health_bar: %HealthBar.health = health

	if health <= 0 && not is_dead:
		# Spawn an explosion of some kind? use call_deferred if you do
		# Spawn an experience orb
		GameController.spawn_experience_orb(global_position, xp_value)
		if randf() < health_drop_chance: GameController.spawn_health_pickup(global_position)

		# %CollisionShape2D.disabled = true
		%CollisionShape2D.set_deferred("disabled", true)
		# print_debug("We died at " + str(global_position.x) + "," + str(global_position.y))
		$Spritesheet.animation = "death"
		$Spritesheet.play()
		%HealthBar.queue_free()
		$DeathSound.play()
		is_dead = true

func apply_knockback(source: Vector2, strength: float) -> void:
	# Calculate the direction from the knockback source to this enemy
	var direction: Vector2 = (global_position - source).normalized()
	knockback_velocity = direction * strength

func _on_spritesheet_animation_finished() -> void:
	if is_dead:
		# GameController.stop_tracking_enemy(self)
		GameController.total_enemies_killed += 1
		# print_debug("Enemy died")
		queue_free()
	elif is_shooting:
		is_shooting = false
		%Spritesheet.animation = "walk"
		%Spritesheet.play()
		# Shoot a projectile at the player.
		var projectile = preload("res://prefabs/enemy_bullet.tscn").instantiate()
		projectile.global_position = global_position
		projectile.initialize(player.global_position, damage)
		get_parent().add_child(projectile)
		%ShootSound.play()
		%ShootTimer.start()
		# print("Enemy shot at player")

func _on_shoot_timer_timeout() -> void:
	can_shoot = true
