class_name EnemyBullet
extends Area2D

const ROTATION_SPEED = PI/2

var speed: float = 150.0
var damage

var velocity: Vector2

## Set up the projectile's damage and target. Make sure to set the global_position [i]before[/i] calling [method initialize]
func initialize(target: Vector2, dmg: float) -> void:
	velocity = global_position.direction_to(target) # direction_to is automatically normalized
	damage = dmg
	# Rotate towards the target
	#look_at(target)

func _physics_process(delta: float) -> void:
	# Move towards the target pos
	global_position += velocity * speed * delta
	rotation += ROTATION_SPEED * delta

	# If the bullet goes off screen, destroy it
	if global_position.x < 0 or global_position.x > get_viewport_rect().size.x or global_position.y < 0 or global_position.y > get_viewport_rect().size.y:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	# Should always be the player due to masking
	if body is Player:
		body.take_damage(damage)
	queue_free()
