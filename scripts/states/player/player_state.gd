class_name PlayerState
extends State

var player: Player

# After the owner (Player) is ready, set up references including actor as a fallback.
func initialize(state_machine: StateMachine) -> void:
	player = actor
	# print_debug(player.name + " is " + actor.name)
	finished.connect(state_machine.change_state) # Retrieves the parent (the State Machine) and connects our finished signal to their change state callable
	assert(player != null, "The PlayerState state type must be used only in the player scene and must be owned by the player node.")