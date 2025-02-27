extends Area2D

var damage: float
# var max_slashes: int = 1
# var slash_count: int = 0
# var connected: bool = false
var slash_animations = ["slash1", "slash2", "slash3"]
var cause_knockback = false
var knockback_strength: float  = 250.0 # High knockback combined with high friction to simulate the enemy recovering their footing
var enemies_damaged_this_slash = []

#func _ready() -> void:
	#$Spritesheet.play(slash_animations[0])

# func set_stats(dmg: float, slashes: int) -> void:
	#damage = dmg
	#max_slashes = slashes

#func _on_spritesheet_animation_finished() -> void:
	# Check to see if we still have more slashes. If so, play the next animation. If not, destroy self.
	# Using less than or equal to because we don't want to overflow the array. Could also do slash_count -1
	# print("Slash count: " + str(slash_count))
#	if slash_count < max_slashes - 1:
		# Disable collision, then reenable it after a brief delay to enable the next slash to hit
#		%CollisionShape2D.disabled = true
#		var timer = get_tree().create_timer(0.01)
#		await(timer.timeout)
#		%CollisionShape2D.disabled = false
		# timer.queue_free()
#		slash_count += 1
#		$Spritesheet.play(slash_animations[slash_count])
#		$AudioStreamPlayer2D.play()
#	else:
#		queue_free()


func _on_body_entered(body:Node2D) -> void:
	 # If we're using masks property, it should ONLY be an enemy!
	if body != null && not body.is_dead && %Spritesheet.is_playing() && enemies_damaged_this_slash.find(body) == -1:
		body.take_damage(damage)

		# If we're on the last slash, perform a knockback.
		if cause_knockback:
			body.apply_knockback(GameController.player.global_position, knockback_strength)
			# body.knocked_back = true
			# body.knockback_velocity = body.global_position.direction_to(GameController.player.global_position)
			# body.knockback_target = body.knockback_strength * 5

		enemies_damaged_this_slash.append(body)

func reset_damaged_enemies() -> void:
	enemies_damaged_this_slash.clear()

# Damage each enemy detected when slashing.
#func damage_enemies_in_slash() -> void:
#	for e in get_overlapping_bodies():
#		if e != null && not e.is_dead:
#			e.take_damage(damage)

func play_slash_animation(slash: int) -> void:
	%Spritesheet.play(slash_animations[slash - 1])

func reset_animation() -> void:
	%Spritesheet.animation = slash_animations[0]
	# %Spritesheet.stop()
	# print_debug("stopping animation")
	
