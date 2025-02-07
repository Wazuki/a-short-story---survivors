extends Area2D

var damage: float
var max_slashes: int = 1 # TESTING at max attacks
var slash_count: int = 0

var slash_animations = ["slash1", "slash2", "slash3"]

func _ready() -> void:
	$Spritesheet.play(slash_animations[0])

func set_stats(dmg: float, slashes: int) -> void:
	damage = dmg
	max_slashes = slashes

func _on_spritesheet_animation_finished() -> void:
	# Check to see if we still have more slashes. If so, play the next animation. If not, destroy self.
	# Using less than or equal to because we don't want to overflow the array. Could also do slash_count -1
	# print("Slash count: " + str(slash_count))
	if slash_count < max_slashes - 1:
		# Disable collision, then reenable it after a brief delay to enable the next slash to hit
		%CollisionShape2D.disabled = true
		var timer = get_tree().create_timer(0.01)
		await(timer.timeout)
		%CollisionShape2D.disabled = false
		# timer.queue_free()
		slash_count += 1
		$Spritesheet.play(slash_animations[slash_count])
		$AudioStreamPlayer2D.play()
	else:
		queue_free()


func _on_body_entered(body:Node2D) -> void:
	if body != null && not body.is_dead: # If we're using masks property, it should ONLY be an enemy!
		body.take_damage(damage)
		# TODO - Collision only works once. Need to fix. Refresh collider?
