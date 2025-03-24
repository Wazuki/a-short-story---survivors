class_name EnemyIdle
extends EnemyState

## Defines the state's name as it enters the tree.
func _enter_tree() -> void: name = IDLE

## Set the Enemy's velocity to zero as they are not moving.
## Play the idle animation.
func enter(_previous_state_path: String = "", _data := {}) -> void:
	enemy.velocity = Vector2.ZERO
	enemy.animation_player.play(IDLE)

## If the enemy has any velocity, start moving towards the player.
func physics_update(_delta) -> void:
	if GameController.global_frame_count % FRAME_UPDATE_OFFSET == 0: 
		if enemy.global_position.distance_to(GameController.player.global_position) < 100:
			enemy.update_move_dir()
			
	if enemy.velocity.length() > 0: finished.emit(WALK)