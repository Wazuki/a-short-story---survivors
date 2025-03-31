class_name EnemyAttack
extends EnemyState

var target_pos: Vector2
var attack_cooldown_timer: Timer

func _enter_tree() -> void: name = ATTACK

## Initialize the state and connect our signals.
func initialize(state_machine: StateMachine) -> void:
	super.initialize(state_machine)
	# Connect to our attack timeout signal only if the enemy is an attack. Connect the 
	if enemy.stats.is_attacker(): 
		setup_attack_timer()
		enemy.animation_player.animation_finished.connect(attack)

## Set the enemy velocity to zero and play the attack animation.
func enter(_previous_state_path: String = "", _data := {}) -> void:
	enemy.velocity = Vector2.ZERO
	enemy.animation_player.play(ATTACK)
	target_pos = enemy.player.global_position
	
	# print(enemy.name + " is attacking!")

## Deploys the actual attack sequence to the enemy and returns to the appropriate transition state.
func attack() -> void:
	# If the attack animation just ended then we should attack and start the cooldown timer.
	if enemy.animation_player.animation == ATTACK: # Safety check to make sure we're attacking.
		enemy.play_attack_sound()
		enemy.spawn_projectile(target_pos)
		attack_cooldown_timer.start()
		enemy.attacking = true

		# Transition to the appropriate state depending on if the enemy is in range or not.
		if enemy.player_in_range: finished.emit(IDLE)
		else: finished.emit(WALK)


## Set up attack timer.
func setup_attack_timer() -> void:
	attack_cooldown_timer = Timer.new()
	attack_cooldown_timer.one_shot = true # The timer will only start again when making an attack.
	attack_cooldown_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	attack_cooldown_timer.wait_time = enemy.stats.attack_cooldown
	attack_cooldown_timer.timeout.connect(reset_attack_state) # Connect the timeout signal to resetting the attack state.
	add_child(attack_cooldown_timer) # Don't forget to add it to the scene tree (:

## Signal for flipping the enemy's attacking state to aid in transitions.
func reset_attack_state() -> void: enemy.attacking = false
