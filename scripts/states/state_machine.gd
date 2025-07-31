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
	# Grab the animation library anme from our actor's AnimationPlayer and use it as a prefix for our animations.
	var anim_prefix = %AnimationPlayer.get_animation_library_list()[1] + "/" # Currently hardcoded to grab the second animation library in the list due to the first being a RESET track.
	# TODO - maybe make this not hardcoded?

	# Grab the animation library prefix from the animation player of the actor and assign it to our anim_prefix
	#print_debug(anim_prefix)
	#await actor.ready - this does NOT WORK because the actor is ALREADY ready!
	#print_debug("Loading StateMachine for " + actor.name)
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.actor = actor
			child.anim_prefix = anim_prefix
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

## Connect a [param state_name]'s [param signal_name] to a passed [param callable]
func connect_signal_to_state(state_name: String, signal_name: String, callable: Callable) -> bool:
	if states[state_name].has_signal(signal_name):
		states[state_name].connect(signal_name, callable)
		return true
	return false