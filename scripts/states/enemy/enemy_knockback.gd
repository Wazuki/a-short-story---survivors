class_name  EnemyKnockback
extends EnemyState

const DECAY_SPEED = 5 ## The rate at which knockback decays over time.

## Defines the state's name as it enters the tree.
func _enter_tree() -> void: 
	name = KNOCKBACK
	allows_attack_transition = false # Prevent enemies from transition to attacking while knocked back.

## Set's the enemy's walk animation as it enters the state.
func enter(_previous_state_path: String = "", data := {}) -> void:
	#print_debug("Entering " + name + " for " + enemy.name)
	enemy.animation_player.play(KNOCKBACK)
	enemy.velocity = data["velocity"] # Set the velocity to the knockback velocity.


## Move the enemy away from the source of the knockback over time.
func physics_update(delta) -> void:
	enemy.move() # Move the enemy based on velocity.

	# Decay the knockback velocity over time and once it is less than 0.1, stop the enemy and resume walking.
	enemy.velocity = enemy.velocity.lerp(Vector2.ZERO, DECAY_SPEED * delta) # Decay the velocity over time.
	if enemy.velocity.length() < 0.1: # If the velocity is less than 0.1, stop the enemy.
		enemy.state_machine.change_state(WALK) # Transition to WALK state.
		return
