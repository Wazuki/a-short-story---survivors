class_name  PlayerJump
extends PlayerState

const CAMERA_SHAKE_Y = 25 ## The strength to shake the camera by on the Y axis
const JUMP_DOWN_EMIT_DIR = -1 ## Direction cosnt for emitting the particles when jumping down (emitting up)
const JUMP_UP_EMIT_DIR = 1 ## Direction const for emitting the particles when jumping up (emitting down)
const JUMP_UP_DURATION = 0.4 ## The amount of time spend in the "jump up" state
const JUMP_DOWN_DURATION = 0.2 ## The amount of time spend in the "jump down" state

var audio: AudioStreamPlayer2D ## Audio for the jump sound effects
var landing_circle: DrawCircle ## The fixed circle for that shows where the player will land
var inner_landing_circle: DrawCircle ## The inner circle the animates to the size of [landing_circle] to indicate when the jump ends
var jump_up_sound = preload("res://assets/audio/light blade/jump/lifting off/retro_boost_power_02.wav")
var jump_down_sound = preload("res://assets/audio/light blade/jump/landing/metal_med_impact_01.wav")

#var jumping: bool = false
var jump_speed: float ## How fast we jump into the air
var jump_time: float = 0.0 ## How long we stay in the air for
#var jump_up_time: float = 0.0
# var jump_down_time: float = 0.0
var landing_radius: float = 0.0 ## The radius of our circle for landing effects

signal jump_ended

## Defines the state's name as it enters the tree.
func _enter_tree() -> void: 
	name = JUMP
	# Create an audio stream player for our jump sounds.
	audio = AudioStreamPlayer2D.new()
	add_child(audio)
	audio.stream = jump_up_sound	

	# Create a DrawCircle to draw our landing circle.
	landing_circle = DrawCircle.new()
	landing_circle.z_index = SpriteConstants.Z_INDEX.JUMP_CIRCLE
	landing_circle.z_as_relative = false
	# Create an inner draw circle
	inner_landing_circle = DrawCircle.new()
	inner_landing_circle.z_index = SpriteConstants.Z_INDEX.JUMP_CIRCLE + 1
	inner_landing_circle.z_as_relative = false

## Sets the player's animation to jumping and plays all related jumping effects.[br]
## The player will be launched into the air and will hang there for a set amount of time before falling back down.[br]
## [data] needs ["jump_speed"], ["jump_time"], ["landing_radius]"
func enter(_previous_state_path: String = "", data := {}) -> void:
	player.invincible = true # Mark the player as invincible since they cannot take damage while jumping.
	# Set the animation and the direction of the jump sprite.
	player.animation_player.play(anim_prefix + JUMP)
	flip_jump_particles()
	set_jump_particle_y_velocity(JUMP_UP_EMIT_DIR) # Set the emit direction of the particles
	player.trail_particles.emitting = true

	# Launch the player's sprite node into the air.
	jump_speed = data["jump_speed"]
	jump_time = data["jump_time"]
	landing_radius = data["landing_radius"]

	audio.play() # Play our jumping up audio
	landing_circle.set_params(landing_radius) # Set the radius of our landing circle to our passed size.
	# Check if the landing radius has a parent. If not, assign it ti the player.
	if landing_circle.get_parent() == null: 
		player.add_child(landing_circle)
		landing_circle.add_child(inner_landing_circle) # Parent the inner circle to the main landing circle.

	jump_up()

## Allows the player to move during the jump and animates the inner landing circle.
func physics_update(delta) -> void:
	#jump(delta)

	# Animate the inner landing circle as a percentage of how far we have left til we land, based on the ENTIRE jump length.
	inner_landing_circle.set_params(clampf(inner_landing_circle.radius + ((landing_radius / (jump_time + JUMP_UP_DURATION + JUMP_DOWN_DURATION)) * delta), 0.0, landing_radius))
	move(delta) # Allows the player to still move while jumping.

## Jump up in the air for [JUMP_UP_DURATION], hang in the air for [jump_time], then fall over [JUMP_DOWN_DURATION].[br]
## Recalculate [jump_speed] once our hang time has ended.
func jump() -> void:
	# if jump_up_time < JUMP_UP_DURATION:  # Have the player jump up for a set duration.
	# 	jump_up(delta)
	await get_tree().create_timer(jump_time).timeout
	# elif jump_time > 0.0: # Have the player hang in the air for a set duration.
	# 	jump_time -= delta
	# 	if jump_time <= 0: # When our jump_time (hang time) is zero, we've hit max air time. Calculate our new jump speed and then jump down on the next frame.
	jump_speed = abs(player.sprite_parent.position.y / JUMP_DOWN_DURATION)
	set_jump_particle_y_velocity(JUMP_DOWN_EMIT_DIR)

	jump_down()
	#else: jump_down(delta)



## Jump up for a set amount of time based on [jump_speed] by creating a tween that jumps for [-jump_speed * JUMP_UP_DURATION]
func jump_up() -> void:
	# Jump up for a set amount of time.
	#jump_up_time += delta
	#player.sprite_parent.position.y -= jump_speed * delta # Use -= because -y is up in Godot.

	var tween = create_tween()
	tween.tween_property(player.sprite_parent, "position", Vector2(player.sprite_parent.position.x, (-jump_speed * JUMP_UP_DURATION)), JUMP_UP_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(jump)

## Jump down for [JUMP_DOWN_DURATION] until we reach our original position.
func jump_down() -> void:
	var tween = create_tween()
	tween.tween_property(player.sprite_parent, "position", Vector2.ZERO, JUMP_DOWN_DURATION).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(finish_jump)

	# jump_down_time += delta
	# # Move the player down based on the jump speed and delta time.
	# player.sprite_parent.position = player.sprite_parent.position.move_toward(Vector2.ZERO, jump_speed * delta)
	
	# # If the sprite parent has reached Vector2.ZERO it means our jump is over and we should exit this state.
	# if player.sprite_parent.position == Vector2.ZERO:
	# 	# Set the audio stream to our jump down stream and play it.
	# 	audio.stream = jump_down_sound
	# 	audio.play()
	# 	# Disable the particle system and transition to the idle state.
	# 	player.trail_particles.emitting = false
	# 	finished.emit(IDLE)

## Called when the jump ends.
func finish_jump() -> void: 
	# Set the audio stream to our jump down stream and play it.
	audio.stream = jump_down_sound
	audio.play()
	# Disable the particle system and transition to the idle state.
	player.trail_particles.emitting = false
	finished.emit(IDLE)

## Reset all the variables used in the jumpingg animation.
func exit() -> void:
	# Apply a camera shake 
	GameController.camera_controller.apply_camera_shake(Vector2(0, CAMERA_SHAKE_Y))
	# Reset all the jumping variables
	jump_speed = 0
	#jump_up_time = 0
	#jump_down_time = 0
	# Reset the audio and circle size.
	audio.stream = jump_up_sound
	landing_circle.set_params(0)
	inner_landing_circle.set_params(0)
	player.invincible = false # Remove the player's invincibility tag. TODO - this should be handled differently (effect that considers the source?)
	jump_ended.emit()

## Allows the player to move while in the air, ignoring zero-velocity to idle transition.
func move(delta) -> void:
	var direction: Vector2
	# Use touch input instead if it's enabled.
	if GameController.touch_input_enabled && Input.is_action_pressed("touch"):
		direction = player.global_position.direction_to(player.get_global_mouse_position()) # Normalized vector to mouse cursor
	else:
		direction = Input.get_vector("move_left", "move_right", "move_up", "move_down") # Normalized vector that's an aggregate of all currently pressed inputs
	# Modify the player's velocity based on direction and the player's speed. 
	player.velocity = direction * player.stats.speed
	# Adjust the player's sprite direction based on the velocity lengths along the x direction. No velocity means we keep our current flip.
	flip_sprite(player.velocity)
	flip_jump_particles() # Set the scale of the particles to -1 if the player is currently facing left, otherwise set it to the normal 0

	#player.play_random_walk_sound()
	player.move_and_collide(player.velocity * delta) # Move and collide does NOT applies delta to the player's velocity.

## Flips the jumping particles based on the player's velocity.
func flip_jump_particles() -> void:
	if player.velocity.x != 0:
		player.trail_particles.scale.x = -1 if player.velocity.x < 0 else 1 # Set the scale of the particles to -1 if the player is currently facing left, otherwise set it to the normal 0+

## Sets the emitting direction of the jump particles based on the [param direction][br]
## [-1] is going "up" (jumping down) and [+1] is going "down" (jumping  up)
func set_jump_particle_y_velocity(direction: int) -> void:
	var total_direction = Vector3(0, direction, 0)
	player.trail_particles.process_material.set("direction", total_direction)
