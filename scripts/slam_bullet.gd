extends Area2D


# var speed: float # Animation speed. Will increase as cooldown increase?
var damage: float


	
func set_stats(dmg: float, spd: float) -> void:
	damage = dmg
	$AnimatedSprite2D.speed_scale = spd


func _on_body_entered(body: Node2D) -> void:
	# If we hit an enemy, deal damage to them.
	if body != null && not body.is_dead: # If we're using masks property, it should ONLY be an enemy!
		# print("Slam bullet hit")
		body.take_damage(damage)





func _on_animated_sprite_2d_animation_finished() -> void:
	# Destroy self once the animation ends.
	queue_free()
