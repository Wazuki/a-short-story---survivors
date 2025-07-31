class_name  PlayerWalk
extends PlayerState

## Defines the state's name as it enters the tree.
func _enter_tree() -> void: name = WALK

## Sets the player's animation to the walk animation as it enters.
func enter(_previous_state_path: String = "", _data := {}) -> void:
	player.animation_player.play(anim_prefix + WALK)

## Take the player's input vector [Input.get_vector(input actions)] and assign it to a direction which will determine the player's speed etc.
func physics_update(delta) -> void:
	var direction: Vector2
	# Use touch input instead if it's enabled.
	if GameController.touch_input_enabled && Input.is_action_pressed("touch"):
		direction = player.global_position.direction_to(player.get_global_mouse_position()) # Normalized vector to mouse cursor
	else:
		direction = Input.get_vector("move_left", "move_right", "move_up", "move_down") # Normalized vector that's an aggregate of all currently pressed inputs
	# Modify the player's velocity based on direction and the player's speed. 
	player.velocity = direction * player.stats.speed
	# Adjust the player's sprite direction based on the velocity lengths along the x direction. No velocity means we keep our current flip.
	flip_sprite(player.velocity)

	# Before moving, check if we have velocity. If not, transition back to idle.
	if player.velocity.length() <= 0: 
		finished.emit(IDLE)
		return
	player.play_random_walk_sound()
	player.move_and_collide(player.velocity * delta) # Move and collide does NOT applies delta to the player's velocity.
