class_name  PlayerIdle
extends PlayerState

## Defines the state's name as it enters the tree.
func _enter_tree() -> void: name = IDLE

## Set the player's velocity to zero as they are not moving.
## Play the idle animation.
func enter(_previous_state_path: String = "", _data := {}) -> void:
	player.velocity = Vector2.ZERO
	player.animation_player.play(IDLE)

## If the player applies any movement, transition to the Walk state.
func physics_update(_delta) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction.length() > 0:
		finished.emit(WALK) 
