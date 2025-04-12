class_name State
extends Node

const IDLE = AnimationNames.IDLE
const WALK = AnimationNames.WALK
const DEATH = AnimationNames.DEATH
const ATTACK = AnimationNames.ATTACK
const KNOCKBACK = AnimationNames.KNOCKBACK

var allows_attack_transition = false ## Tracks whether or not a state can transition to attacking from the current state.

var actor

## Emitted when a state finished and want to transition to the next state.
signal finished(next_state_path: String, data: Dictionary)

## Overriddable initialize function to initialize each state.
func initialize(state_machine: StateMachine) -> void: pass

## Called by the state machine upon changing the active state. The 'data' parameter is a dictionary of data that the state could use to initialize itself.
func enter(_previous_state_path: String = "", _data := {}): pass

## Called by the state machine before changing the active state. Used to clean up the state.
func exit(): pass

## For non-physics (UI, non-body) updates
func update(_delta): pass

## Called for physics-based updates.
func physics_update(_delta): pass

## Flips sprites based on the velocity - left [-x/false] or right [+x/true]
func flip_sprite(velocity: Vector2) -> void:
	if velocity.x != 0:
		actor.animation_player.flip_h = velocity.x < 0 # Flip the sprite to the left if velocity.x is less than zero (-x)
