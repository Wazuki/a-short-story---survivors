class_name EnemyState
extends State

## Constant to determine how often we check our direction to the player.
const FRAME_UPDATE_OFFSET = 6

var enemy: Enemy

# After the owner (Enemy) is ready, set up references including actor as a fallback.
func initialize(state_machine: StateMachine) -> void:
	enemy = actor
	# print_debug(player.name + " is " + actor.name)
	finished.connect(state_machine.change_state) # Retrieves the parent (the State Machine) and connects our finished signal to their change state callable
	assert(enemy != null, "The EnemyState state type must be used only in the player scene and must be owned by the player node.")
	# print_debug("Enemy state " + name + " initialized")