class_name  EnemyDeath
extends EnemyState

## Defines the state's name as it enters the tree.
func _enter_tree() -> void: name = DEATH

func initialize(state_machine: StateMachine) -> void:
	super.initialize(state_machine)
	# await enemy.ready - Do NOT need this because the enemy is already ready so this will never call!
	# Bind the state machine (our parent) to change to our state when the actor's health is depleted.
	enemy.stats.defeated.connect(state_machine.change_state.bind(DEATH))
	# print("State machine death result " + error_string(result))
	# if result != OK: print_debug("Death state not connected for " + enemy.name)

## Set the actor's velocity to zero as they die and play the death animation. Once finished, exit the state and queue the enemy for deletion.
func enter(_previous_state_path: String = "", _data := {}) -> void:
	#print_debug("Enemy dying!")
	enemy.velocity = Vector2.ZERO
	# Disable the enemy's collision (deferred)
	enemy.set_deferred("monitoring", false)
	enemy.set_deferred("monitorable", false)
	# Play death sounds and death animations, then remove the enemy once the animation is done.
	enemy.death_sound.play()
	enemy.animation_player.play(anim_prefix + DEATH)
	var duration: float = max(enemy.animation_player.current_animation_length, enemy.death_sound.stream.get_length())

	await get_tree().create_timer(duration).timeout
	#await Signals.all([enemy.animation_player.animation_finished, enemy.death_sound.finished])
	# await (enemy.animation_player.animation_finished and enemy.death_sound.finished)

	# TODO - this should be changed so if we have longer death sounds or animations they get called in the right order.
	# Consider an actual animation player for the sprites for direct comparisons to the length.


	enemy.call_deferred("queue_free")
