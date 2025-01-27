extends CharacterBody2D

const STARTING_HEALTH = 100
const STARTING_SPEED = 450
const STARTING_TIL_NEXT_LEVEL = 10

var health
var speed
var experience: float
var level
var xp_to_next_level
var enemy_damage_rate = 5.0

@onready var player_info_text : RichTextLabel = get_node("/root/GameScene/UI/PlayerInfoContainer/Panel/MarginContainer/PlayerInfoText")

signal _health_depleted

func _ready() -> void:
	reset()

func _physics_process(delta: float) -> void:
	#GetVector() turns movement into 2D direction

 	# If the player is alive, move them based on input. This is also where we will fire weapons, gain XP, etc.
	if health > 0:
		var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = direction * speed
		
		move_and_slide() # Automatically moves character based on velocity. Applies delta automatically
		
		# If the player is moving, play the walk animation. Otherwise, play the idle animation. Flip the sprite based on direction.
		
		if velocity.length() > 0:
			%Spritesheet.animation = "walk"
			if velocity.x < 0:
				%Spritesheet.flip_h = true
			elif velocity.x > 0:
				%Spritesheet.flip_h = false
			%Spritesheet.play()
		else: %Spritesheet.animation = "idle"
	
		var overlapping_mobs = %HurtBox.get_overlapping_bodies()
		
		if not overlapping_mobs.is_empty():
			health -= enemy_damage_rate * overlapping_mobs.size() * delta # Deal damage for each mob touching the player times delta so they don't explode
			%HealthBar.value = health
			# Firing weapons moved to each weapon function to make them independent of the player.
			
		var xp_to_absorb = %PickupRadius.get_overlapping_areas()
		# print_debug("There are " + str(xp_to_absorb.size()) + " xp in range!")
		for xp in xp_to_absorb:
			xp.absorbing = true # Call the Absorb function on the XP so they fly towards the player
			if not %XPPickupSound.playing: %XPPickupSound.play() # Play the XP sound but only if it's not currently playing to rpevent spam

		update_player_info_text()
	# If the player is dead, play the death animation and emit the signal to the game controller.
	else:
		#  Kill the player at zero health.
		# emit_signal("_health_depleted")
		%Spritesheet.animation = "death"
		%Spritesheet.play()

func get_target() -> Vector2:
	# Return the first mob that overlaps the weapon range collider - TODO: adjustable range?
	var enemies_in_range: Array[Node2D] = %WeaponRange.get_overlapping_bodies()
	if not enemies_in_range.is_empty():
		return enemies_in_range[0].global_position
	return Vector2.ZERO # Return zero if no enemies within range.

func gain_experience(xp: float) -> void:
	# If the player gets enough XP, level up!
	experience += xp
	# print_debug("We gained " + str(xp) + "xp!")
	if experience >= xp_to_next_level:
		# print_debug("Level up!")
		level_up()
		
	update_player_info_text()

func level_up() -> void:
	# Show the level up UI with the avaiable options, the weapons, level them, and reset the XP.
	if not %LevelUpSound.playing: %LevelUpSound.play()
	experience -= xp_to_next_level
	level += 1
	
	xp_to_next_level = roundi(level * 7.5)
	
	# update_player_info_text()
	
	# Display the Level Up UI from the Game Manager
	GameController.level_up_UI.show_level_up_screen()

func reset() -> void:
	health = STARTING_HEALTH
	speed = STARTING_SPEED
	experience = 0
	level = 1
	xp_to_next_level = STARTING_TIL_NEXT_LEVEL
	
	# Don't forget to reset the UI!
	%HealthBar.value = health
	update_player_info_text()

	%Spritesheet.animation = "idle"
	%Spritesheet.play()
	
func update_player_info_text() -> void:
	var text = "Level: " + str(level)
	text += "\nXP: " + str(experience)
	text += "\nTNL: " + str(xp_to_next_level)
	text += "\nHP: " + str(roundi(health))
	player_info_text.text = text


func _on_spritesheet_animation_finished() -> void:
	# Tell the UI we're dead
	print_debug("Our animation is " + %Spritesheet.animation)
	if %Spritesheet.animation == "death":
		print("Player died!")
		emit_signal("_health_depleted")
		%Spritesheet.stop()
