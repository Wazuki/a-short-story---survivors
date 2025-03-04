extends Area2D


# var speed: float # Animation speed. Will increase as cooldown increase?
var damage: float
var attack_origin
var enemies_damaged_this_cycle = []
var is_mini_slam = false
# var slow_value: float

# Fire the weapon - if we hit something, return true so we fire the weapon and reset the timer.
func slam(pos: Vector2) -> bool:
	var overlapping_bodies = get_overlapping_bodies()
	attack_origin = pos

	if not overlapping_bodies.is_empty() || is_mini_slam: # Mini-slams should always fire whether there are enemies there or not.
		#reparent(get_node("/root/GameScene"))
		%AnimatedSprite2D.frame = 0
		enemies_damaged_this_cycle.clear()
		set_as_top_level(true)
		global_position = attack_origin
		rotation = randf_range(0.0, 2.0 * PI) # Randomly rotate the slam (which in turn will rotate the mini-slams)

		%AnimatedSprite2D.play()
		%SlamSounds.play()

		# Apply damage to all enemies in the area.
		for enemy in overlapping_bodies:
			deal_damage(enemy)

		return true
	else: return false
	
func set_stats(dmg: float, spd: float) -> void:
	damage = dmg
	$AnimatedSprite2D.speed_scale = spd


func _on_body_entered(body: Node2D) -> void:
	# If we hit an enemy, deal damage to them but only when the animation is playing (i.e., we're attacking)
	if body != null && not body.is_dead and %AnimatedSprite2D.is_playing(): # If we're using masks property, it should ONLY be an enemy!
		# print("Slam bullet hit")
		deal_damage(body)

func deal_damage(e : Node2D) -> void:
		e.take_damage(damage)
		enemies_damaged_this_cycle.append(e)
		if GameController.slam.is_slow_enabled() and not is_mini_slam: e.apply_slow(GameController.slam.SLOW_VALUE)



func _on_animated_sprite_2d_animation_finished() -> void:
	# Destroy self once the animation ends if we are a mini-slam.
	if is_mini_slam:
		# print_debug("Mini-slam gone after " + str(lifetime))
		queue_free()
	else: 
		GameController.slam.spawn_mini_slams()
