class_name Player
extends CharacterBody2D

const PRUNE_DICT_FRAME_OFFSET = 30
var shader_flicker_speed = 0.0
var enemies_touching = {}
var enemies_touching_last_frame: int
var total_contact_damage: float = 0.0
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

@export var state_machine: StateMachine
@onready var player_info_text : RichTextLabel = get_node("/root/GameScene/UI/PlayerInfoContainer/Panel/MarginContainer/PlayerInfoText")
@onready var animation_player: AnimatedSprite2D = %Spritesheet

signal gained_xp(amount)
signal gained_level
signal _health_changed
signal _health_depleted

func _ready() -> void:
	level_up_text_reset_pos = %LevelUpText.position
	state_machine.initialize(AnimationNames.IDLE) # Initialize the state machine with the IDLE animation since the player starts with no input.

func initialize(character: PlayerCharacterStats) -> void:
	health = character.get_stat_value(PlayerCharacterStats.Stat.HEALTH)
	max_health = health
	speed = character.get_stat_value(PlayerCharacterStats.Stat.SPEED)
	armor = character.get_stat_value(PlayerCharacterStats.Stat.ARMOR)
	level_up_text = character.level_up_text
	%Spritesheet.sprite_frames = character.spritesheet

	experience = 0
	level = 1
	xp_to_next_level = STARTING_TIL_NEXT_LEVEL
	# Don't forget to reset the UI!
	adjust_health_bar()
	update_player_info_text()
	
	# Set the state machine to our idle animation (for respawns/resets etc.)
	state_machine.change_state(AnimationNames.IDLE)

	# Set the player's z-index
	z_index = SpriteConstants.Z_INDEX.PLAYER
	# weapon = character["weapon"]
	# print_debug("Set character stats to " + str(character))

func _physics_process(delta: float) -> void:
	if Input.is_action_just_released("give_xp"): gain_experience(10)
	if Input.is_action_just_released("level"): gain_experience(30)
	if Input.is_action_just_released("difficulty_increase"): EnemyManager.enemy_difficulty += 5
	if Input.is_action_pressed("time_cheat"): Engine.time_scale = 5.0
	elif Input.is_action_just_released("time_cheat"): Engine.time_scale = 1.0
	#GetVector() turns movement into 2D direction

	update_player_info_text()

	# Deal damage to the player if any enemies are touching the player.
	if not enemies_touching.is_empty():
		shader_flicker_speed = 8.0
		%Spritesheet.material.set_shader_parameter("speed", shader_flicker_speed) # Set the player's "being damaged" shader speed 
		# If our enemy dict hasn't changed since last frame then just deal the same damage again rather than iterate.
		if enemies_touching_last_frame != enemies_touching.size(): 
			total_contact_damage = 0
			for e in enemies_touching: total_contact_damage += enemies_touching[e].stats.contact_damage # Remember that the enemy dict is { ID, enemy } so we need to use the key
			enemies_touching_last_frame = enemies_touching.size()
		# Deal damage to the player.
		take_damage(total_contact_damage * delta)
	else: # Reset the shader flicker speed (ONLY if it's not 0.0 to prevent a lot of calls to the material)
		if shader_flicker_speed != 0.0:
			shader_flicker_speed = 0.0
			%Spritesheet.material.set_shader_parameter("speed", shader_flicker_speed)
			total_contact_damage = 0.0
			enemies_touching_last_frame = 0
	
	# Prune the enemies touching dict of invalid instances (about once every second at physics 30 FPS)
	if not enemies_touching.is_empty() and GameController.global_frame_count % PRUNE_DICT_FRAME_OFFSET == 0:
		var enemies_left = enemies_touching.values().filter(is_instance_valid)
		enemies_touching.clear()
		for e in enemies_left: enemies_touching.set(e.get_instance_id(), e) # Reset the dict after clear with the { ID, enemy } data



func take_damage(damage: float) -> void:
	health -= damage
	adjust_health_bar()
	if health <= 0: _health_depleted.emit()

# Heal the player by a percentage of max health, clamped by max health
func heal_damage(heal: float) -> void:
	health = clamp(health + (heal * max_health), 0, max_health)
	adjust_health_bar()

func adjust_health_bar() -> void:
	emit_signal("_health_changed", health, max_health)

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
	%LevelUpText.text = level_up_text
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


# func _on_spritesheet_animation_finished() -> void:
# 	# Tell the UI we're dead
# 	# print_debug("Our animation is " + %Spritesheet.animation)
# 	if %Spritesheet.animation == "death":
# 		# print("Player died!")
# 		emit_signal("_health_depleted")
# 		%Spritesheet.stop()

## Signals pickups to fly towards the player if they are experience. 
func _on_pickup_radius_area_entered(area:Area2D) -> void:
	# Experience orbs should fly to the player when they enter the player's pickup radius.
	if area is ExperienceOrb:
		area.absorb_xp(self)

## Signals pickups to enter the player and apply their effect. 
## Enemies should be added to the enemies_touching array to deal damage to the player on the physics tick.
func _on_player_collider_area_entered(area: Area2D) -> void:
	if area is Pickup:
		area.apply_pickup_to_player(self)
	elif area is Enemy:
		# Apply damage to player
		enemies_touching.set(area.get_instance_id(), area)
	## TODO - change enemies to Area2D and apply their touching signals here?
	# elif area is Enemy:
	# 	touching_enemies.append(area)

## Remove the leaving area from the enemies_touching collection if they were an enemy
func _on_player_collider_area_exited(area:Area2D) -> void:
	if area is Enemy and enemies_touching.has(area.get_instance_id()): enemies_touching.erase(area.get_instance_id())
