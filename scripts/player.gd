class_name Player
extends CharacterBody2D

# const STARTING_HEALTH = 150
# const STARTING_SPEED = 300
const STARTING_TIL_NEXT_LEVEL = 5

var max_health
var health
var speed
var armor: float # Each point of armor reduces damage by 0.1

var experience: float
var level
var xp_to_next_level
var level_up_text = "Level Up!"
var level_up_text_reset_pos

var total_level_ups = 0
# var enemy_damage_rate = 5.0

@onready var player_info_text : RichTextLabel = get_node("/root/GameScene/UI/PlayerInfoContainer/Panel/MarginContainer/PlayerInfoText")

signal gained_xp(amount)
signal gained_level
signal _health_changed
signal _health_depleted

func _ready() -> void:
	level_up_text_reset_pos = %LevelUpText.position

func initialize(character: Character) -> void:
	health = character.get_stat_value(Character.Stat.HEALTH)
	max_health = health
	speed = character.get_stat_value(Character.Stat.SPEED)
	armor = character.get_stat_value(Character.Stat.ARMOR)
	%Spritesheet.sprite_frames = character.spritesheet

	experience = 0
	level = 1
	xp_to_next_level = STARTING_TIL_NEXT_LEVEL
	# Don't forget to reset the UI!
	adjust_health_bar()
	update_player_info_text()

	%Spritesheet.animation = "idle"
	%Spritesheet.play()

	# Set the player's z-index
	z_index = GameController.sprite_constants.Z_INDEX.PLAYER
	# weapon = character["weapon"]
	# print_debug("Set character stats to " + str(character))

func _physics_process(delta: float) -> void:
	if Input.is_action_just_released("give_xp"): gain_experience(10)
	if Input.is_action_just_released("level"): gain_experience(30)
	if Input.is_action_just_released("difficulty_increase"): GameController.difficulty += 5
	if Input.is_action_pressed("time_cheat"): Engine.time_scale = 5.0
	elif Input.is_action_just_released("time_cheat"): Engine.time_scale = 1.0
	#GetVector() turns movement into 2D direction

 	# If the player is alive, move them based on input. This is also where we will fire weapons, gain XP, etc.
	if health > 0:
		if GameController.touch_input_enabled && Input.is_action_pressed("touch"):
			# honk honk
			# var direction = global_position.direction_to(InputEventScreenTouch.position)
			var direction = global_position.direction_to(get_global_mouse_position())
			velocity = direction * speed
		else:
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
	
		var overlapping_mobs = %PlayerCollider.get_overlapping_bodies()
		
		# TODO - refactor this to use signals etc.
		if not overlapping_mobs.is_empty():
			var total_damage = 0.0
			
			for m in overlapping_mobs: 
				if m is Enemy:
					total_damage += clamp((m.damage - (armor / 10)), 0, m.damage) # Clamp the damage to 0 if it's negative

			#health -= total_damage * delta # Deal damage for each mob touching the player times delta so they don't explode
			take_damage(total_damage * delta)
			# Firing weapons moved to each weapon function to make them independent of the player.
			
		var xp_to_absorb = %PickupRadius.get_overlapping_areas()
		# print_debug("There are " + str(xp_to_absorb.size()) + " xp in range!")
		for xp in xp_to_absorb:
			# This should be illegal lmao
			if "absorbing" in xp: xp.absorbing = true # Call the Absorb function on the XP so they fly towards the player
			if not %XPPickupSound.playing: %XPPickupSound.play() # Play the XP sound but only if it's not currently playing to rpevent spam
			# print_debug("Detected " + xp.name)

		update_player_info_text()
	# If the player is dead, play the death animation and emit the signal to the game controller.
	else:
		#  Kill the player at zero health.
		# emit_signal("_health_depleted")
		%Spritesheet.animation = "death"
		%Spritesheet.play()

func take_damage(damage: float) -> void:
	health -= damage
	adjust_health_bar()

# Heal the player by a percentage of max health, clamped by max health
func heal_damage(heal: float) -> void:
	health = clamp(health + (heal * max_health), 0, max_health)
	adjust_health_bar()

func adjust_health_bar() -> void:
	emit_signal("_health_changed", health, max_health)

# TODO - Weapon-managed ranges with variable ranges.
func get_target() -> Vector2:
	# Return the first mob that overlaps the weapon range collider - TODO: adjustable range?
	var enemies_in_range: Array[Node2D] = %WeaponRange.get_overlapping_bodies()
	if not enemies_in_range.is_empty():
		return enemies_in_range[0].global_position
	return Vector2.ZERO # Return zero if no enemies within range.

func get_closest_target() -> Vector2:
	# Return the closest mob that overlaps the weapon range collider - TODO: adjustable range?
	var enemies_in_range: Array[Node2D] = %WeaponRange.get_overlapping_bodies()
	if not enemies_in_range.is_empty():
		var closest_enemy = enemies_in_range[0]
		for e in enemies_in_range:
			if e.global_position.distance_to(global_position) < closest_enemy.global_position.distance_to(global_position):
				closest_enemy = e
		# print("Closest enemy is " + closest_enemy.name)
		return closest_enemy.global_position
	return Vector2.ZERO

func get_highest_hp_target() -> Vector2:
	# Returns the highest HP enemy in range.
	var enemies_in_range: Array[Node2D] = %WeaponRange.get_overlapping_bodies()
	if not enemies_in_range.is_empty():
		var highest_hp_enemy = enemies_in_range[0]
		for e in enemies_in_range:
			if e.health > highest_hp_enemy.health:
				highest_hp_enemy = e
		return highest_hp_enemy.global_position
	return Vector2.ZERO

func gain_experience(xp: float) -> void:
	# If the player gets enough XP, level up!
	emit_signal("gained_xp", xp)
	experience += xp
	tween_xp_bar()
	update_player_info_text()
	# print_debug("We gained " + str(xp) + "xp!")
	for i in range(total_level_ups):
		# Reset the XP immediately so we don't get a double level up bug
		# experience -= xp_to_next_level
		if not %LevelUpSound.playing: %LevelUpSound.play()
		# print_debug("Level up!")
		show_level_up_text()
		# level_up()
	total_level_ups = 0		
	update_player_info_text()

# TODO - this whole t hing could really use a rewrite tbh or just changing it
func tween_xp_bar() -> void:
	# Tween the XP bar to show the player how much XP they gained
	%XPBar.visible = true
	var tween = %XPBar.create_tween()
	# Tween the XP bar to show the player how much XP they gained based on the ratio of XP to next level
	tween.tween_property(%XPBar, "value", experience / xp_to_next_level,  clampf(1.0 - (experience / xp_to_next_level), 0.25, 1.0))

	#TODO - Adjust the tween so it properly shows on multiple level ups
	while experience >= xp_to_next_level:
		experience -= xp_to_next_level
		total_level_ups += 1
		emit_signal("gained_level")
		tween.tween_property(%XPBar, "value", 0.0, 0.5)
		tween.tween_property(%XPBar, "value", experience, 1.0)
	tween.tween_callback(%XPBar.hide)
	tween.tween_callback(tween.kill)


func show_level_up_text() -> void:
	%LevelUpText.visible = true
	var tween = %LevelUpText.create_tween()

	# Tween the text up and fade it out, then call the level_up function
	tween.set_parallel()
	tween.tween_property(%LevelUpText, "position", %LevelUpText.position + Vector2(0, -30), 1.0)
	tween.tween_property(%LevelUpText, "modulate:a", 0, 1.0)
	tween.set_parallel(false)
	tween.tween_callback(level_up)
	tween.tween_callback(tween.kill)

func level_up() -> void:
	# Reset the level up text so we don't forget
	# print_debug("Level up!")
	%LevelUpText.visible = false
	%LevelUpText.modulate = Color(1, 1, 1, 1)
	%LevelUpText.position = level_up_text_reset_pos

	# Show the level up UI with the avaiable options, the weapons, level them
	# experience -= xp_to_next_level
	level += 1
	
	xp_to_next_level = roundi(level * 2.5) + STARTING_TIL_NEXT_LEVEL
	
	# update_player_info_text()
	
	# Display the Level Up UI from the Game Manager
	GameController.level_up_UI.show_level_up_screen()

func update_player_info_text() -> void:
	var text = "Level: " + str(level)
	text += "\nXP: " + str(experience)
	text += "\nTNL: " + str(xp_to_next_level)
	text += "\nHP: " + str(roundi(health))
	player_info_text.text = text


func _on_spritesheet_animation_finished() -> void:
	# Tell the UI we're dead
	# print_debug("Our animation is " + %Spritesheet.animation)
	if %Spritesheet.animation == "death":
		# print("Player died!")
		emit_signal("_health_depleted")
		%Spritesheet.stop()

## Signals pickups to fly towards the player if they are experience. 
func _on_pickup_radius_area_entered(area:Area2D) -> void:
	# Experience orbs should fly to the player when they enter the player's pickup radius.
	# print_debug("Found a " + area.name)
	if area is ExperienceOrb:
		area.absorb_xp(self)

## Signals pickups to enter the player and apply their effect.
func _on_player_collider_area_entered(area: Area2D) -> void:
	# print_debug("Touched " + area.name)
	if area is Pickup:
		area.apply_pickup_to_player(self)
