class_name  PlayerDeath
extends PlayerState

## Defines the state's name as it enters the tree.
func _enter_tree() -> void: name = DEATH

func initialize(state_machine: StateMachine) -> void:
	# await owner.ready
	super.initialize(state_machine)
	# Bind the state machine (our parent) to change to our state when the player's health is depleted.
	player._health_depleted.connect(state_machine.change_state.bind(DEATH))

## Set the player's velocity to zero as they die and play the death animation. Once finished, exit the state and call game over.
func enter(_previous_state_path: String = "", _data := {}) -> void:
	player.velocity = Vector2.ZERO
	player.animation_player.play(DEATH)
	await player.animation_player.animation_finished
	GameController.game_over() # Tell the game controller we're ending the game once the player's death animation is complete.
