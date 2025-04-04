class_name  EnemyWalk
extends EnemyState

#const SPEED = CharacterData.Stat.SPEED

## Defines the state's name as it enters the tree.
func _enter_tree() -> void: 
	name = WALK
	allows_attack_transition = true # Allows walking enemies to transition to attacking.

## Set's the enemy's walk animation as it enters the state.
func enter(_previous_state_path: String = "", _data := {}) -> void:
	enemy.update_move_dir()
	flip_sprite(enemy.move_dir)
	enemy.animation_player.play(WALK)

## Updates the enemy's move direction based on the global frame count.
func _process(_delta: float) -> void:
	if GameController.global_frame_count % FRAME_UPDATE_OFFSET == 0: 
		# print_debug("Updated movement for " + enemy.name)
		enemy.update_move_dir() # Update the enemy's move direction
		flip_sprite(enemy.move_dir) # Since the move dir changed, let's see if we should flip the sprite as well.

## Update the enemy's direction every [FRAME_UPDATE_OFFSET] frames and then move the enemy towards the player.
func physics_update(delta) -> void:
	# if enemy.avoidance_dir == Vector2.ZERO:	enemy.final_direction = enemy.move_dir # Default enemy movement - simply move to the player.
	# else: # Avoidance logic
	# 	enemy.final_direction =  enemy.move_dir.lerp(enemy.avoidance_dir, enemy.avoidance_weight) # Lerp from our main move direction towards the play 90% and the enemy we are avoiding 10%
	# 	enemy.avoidance_dir.move_toward(Vector2.ZERO, get_physics_process_delta_time()) # Move the avoidance Vector2 towards zero.
	# 	print_debug("avoid :(")

	enemy.velocity = enemy.move_dir * enemy.stats.get(CharacterData.Stat.SPEED) * delta
	if enemy.velocity.length() > 0:
		enemy.move()
	# else:
	# 	finished.emit(IDLE)
