class_name EnemyStateMachine
extends StateMachine

## Handles enemy-specific transitions like attack animations.
func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	# We transition to attack if: the player is in range, attacking is false, and our current state allows for attack transitions.
	if actor.player_in_range and not actor.attacking and current_state.allows_attack_transition:
		change_state(AnimationNames.ATTACK)
