class_name StateMachine
extends Node

## Exports the actor that this state machine will manipulate.
@export var actor: Node
var states = {}
var current_state: State

## Sets up the children of the state machine - if they are states, add them to the states variable top track them. [br]
## Requires an animation name from [AnimationNames]
func initialize(animation_name: String) -> void:
	# Throw an assert if we forgot to assign an actor to the StateMachine.
	assert(actor != null, "StateMachine: actor must be set before calling iniitialize().")
	#await actor.ready - this does NOT WORK because the actor is ALREADY ready!
	#print_debug("Loading StateMachine for " + actor.name)
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.actor = actor
			child.initialize(self) # Pass ourself into the child for signal connection.
	change_state(animation_name) # Default state of idle

	# print("StateMachine for " + actor.name + " finished loading - we have " + str(states.size()) + " states!")

## Swap from the current state (if any) to a new state passed as [new_state_name: String].
func change_state(new_state_name: String, data := {}) -> void:
	#print_debug("Entering " + new_state_name)
	if current_state: current_state.exit()

	# Convert the previous state's name to an empty string (no state) if there isn't a previous state (e.g., starting the machine)
	var prev_state_name: String = current_state.name if current_state else ""
	current_state = states.get(new_state_name)

	if current_state: current_state.enter(prev_state_name, data)

	# print_debug("Current state: " + current_state.name)

# Notify the states to perform their updates if applicable.
func _process(delta: float) -> void:
	if current_state: current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state: current_state.physics_update(delta)
