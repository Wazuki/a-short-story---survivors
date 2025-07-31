extends Node

enum GameState { IDLE, MAIN_MENU, CHAR_SELECT, IN_GAME, PAUSED, UNLOCK_SCREEN, GAME_OVER } ## Enum for the game's states.
var current_state: GameState = GameState.IDLE ## Indicates the current state of the game, used to determine what we are currently doing.
signal game_state_changed(state: GameState) ## Signal to emit when the game state changes.

var global_frame_count = 0 ## Tracks the total frames elapsed for anything that is calling something every [i]n[/i] frames. Combines with a modulus to execute actions every [i]n[/i] frames.
var game_time_elapsed: float = 0.0 ## Tracks the total IN-GAME time elapsed. This is not the same as the global frame count. Used to display a clock for the player.


# TODO These are all nodes we should consider changing how we acquire them.
@onready var player = get_node("/root/GameScene/YSort/Player")
#@onready var player_health_bar = get_node("/root/GameScene/UI/PlayerHealthBar")
@onready var level_up_UI = get_node("/root/GameScene/UI/LevelUpUI")
@onready var character_select_UI = get_node("/root/GameScene/UI/CharacterSelectUI")
@onready var camera_controller = get_node("/root/GameScene/MainCamera")


@onready var game_over_UI: PanelContainer = get_node("/root/GameScene/UI/GameOverUI")
@onready var pause_button: Button = get_node("/root/GameScene/UI/PauseButton")

var game_active: bool = false

# Deprecated
#signal game_started
#signal game_ended

# var start_button_pressed = true

var touch_input_enabled: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# get_node("/root/GameScene/Player/Audio/XPPickupSound").connect("finished", print_debug.bind("XP sound finished playing"))

	# Move hte Game Controller node to be a child of the actual game scene.
	# TODO - this is probably unnecessary.
	get_node("/root").call_deferred("remove_child",self)
	get_node("/root/GameScene").call_deferred("add_child", self)
	
	# Connect the game signals to the game controller.
	Events.spawn_experience.connect(spawn_experience_orb)

	# Player connected signals.
	Events.player_gained_xp.connect(_on_player_gain_xp)
	Events.player_gained_level.connect(_on_player_gain_level)
	# Events.player_damaged.connect(update_player_info_text)
	Events.player_defeated.connect(game_over)
	#player.connect("gained_xp", _on_player_gain_xp) # Called when the player gains xp.
	#player.connect("gained_level", _on_player_gain_level) # Called when the player gains a level.
	#player.connect("_health_depleted", game_over) # When the player dies
	#player.connect("health_changed", update_player_info_text) # When the player's health changes (but not zero)
	
	
	# lol
	var restart_game_button: Button = get_node("/root/GameScene/UI/GameOverUI/MarginContainer/Panel/VBoxContainer/MarginContainer/RestartButton")
	# print_debug(restart_game_button.name)
	restart_game_button.pressed.connect(restart_game)
	

	load_game()
	# Initialize the character select UI to properly set the weapons in the Dict
	character_select_UI.init()
	pause_game()

func _process(delta: float) -> void:
	global_frame_count += 1
	if game_active: 
		game_time_elapsed += delta

		# Update game time on the UI.
		update_time_passed_label()
		

## Updates the game time label to show the time elapsed in the game.
func update_time_passed_label() -> void:
	var seconds = floori(game_time_elapsed)
	var minutes = seconds / 60
	var leftover_seconds = seconds % 60
	var time_string = str(minutes) + ":" + str(leftover_seconds).pad_zeros(2)
	$"/root/GameScene/UI/GameTimeLabel".text = "[p align=\"center\"]" + time_string

	if minutes >= 5: # 5 minutes is the max time for a game
		game_over()



# Signals for tracking global player-saved variables.
func _on_player_gain_xp(amount) -> void: DataManager.add_value("experience", amount)
func _on_player_gain_level() -> void: DataManager.add_value("levels", 1)


# func update_player_info_text(health: float, max_health: float) -> void:
# 	#player_health_bar.health = player.stats.health
# 	#player_health_bar.max_health = player.stats.max_health
# 	#player_health_bar.health = health
# 	#player_health_bar.max_health = max_health

# 	#player_health_bar.max_value = max_health
# 	#player_health_bar.value = health



func spawn_health_pickup(pos: Vector2) -> void:
	var health_pickup = preload("res://prefabs/pickups/health_pickup.tscn").instantiate()
	call_deferred("add_child", health_pickup)
	health_pickup.initialize(pos)
	# print("spawned health")

# Reset enemies and weapons, then let the player select a character.
func start_game() -> void:

	game_time_elapsed = 0.0
	# display_level_up()
	# Display the character select screen
	character_select_UI.visible = true
	change_game_state(GameState.CHAR_SELECT) # Swap the game state to the char select state

func select_character(character: PlayerCharacterData) -> void:
	# Hide the select character UI and start the game after setting the player's stats
	character_select_UI.visible = false
	player.initialize(character)
	#player_health_bar.init_health(player.stats.health) # Initialize the player's health bar - sets all the values to max health.


	WeaponManager.create_weapon(character.starting_weapon) # Create the weapon based on the character's starting weapon.

	unpause_game()
	game_active = true
	change_game_state(GameState.IN_GAME) # Swap the game state t o the "in game" state (e.g., the player is now actively playing)
	# print_debug("Selected " + character)



func display_level_up() -> void:
	level_up_UI.show_level_up_screen()

func pause_game() -> void:
	get_tree().paused = true
	pause_button.visible = false

func unpause_game() -> void:
	get_tree().paused = false
	pause_button.visible = true

func quit_game() -> void:
	# Save the game and quit
	save_game()
	get_tree().quit() # TODO - Save data. Confirm quit?

func apply_shockwave_displacement(origin: Vector2, strength: float) -> void:
	# Apply the shockwave deplacement to all enemies based on the origin of the shockwave
	for e in get_tree().get_nodes_in_group("Enemies"):

		if e.displaced: continue # Skip to the next enemy since this one is already knocked back.

		# Calculate the direction from the shockwave origin to the enemy and apply displacement based on the distance.
		var direction = (e.global_position - origin).normalized()
		var distance = e.global_position.distance_to(origin)
		var shockwave_max_size = get_viewport().get_visible_rect().size.x / get_viewport().get_camera_2d().zoom.x
		# print_debug("Distance: " + str(distance) + ", Max size: " + str(shockwave_max_size))
		e.velocity = (direction * strength * clamp(1.0 - (distance / shockwave_max_size), 0.1, 1.0)) 
		e.displaced = true
		# var direction = (e.global_position - origin).normalized()
		# var distance = e.global_position.distance_to(origin)
		# var offset = 30
		# # print_debug("Distance: " + str(distance) + ", Time: " + str(time))

		# # If the enemy is within the active range of the shockwave
		# if time*speed_per_frame - offset <= distance and distance <= time*speed_per_frame + offset:
		# 	# Calculate the displacement based on the strength of the shockwave and the distance from the origin
		# 	# var displacement = strength * (1.0 - (distance / time))
		# 	# Scale displacement based on distance (closer = stronger impulse)
		# 	var impulse_strength = strength * clamp(1.0 - (distance / time), 0.3, 1.0)
		# 	# print_debug("Impulse strength: " + str(impulse_strength))
		# 	e.apply_impulse(direction * impulse_strength)
		# 	e.displaced = true
		# 	# print_debug("Applied displacement of " + str(direction * displacement))
		
func game_over() -> void:
	#Pause the game, destroy all enemies, then show the game over UI 
	change_game_state(GameState.GAME_OVER) # Notify listeners that the game state has changed to game_over.
	#game_ended.emit()
	save_game()
	pause_game()
	game_active = false
	if current_state == GameState.UNLOCK_SCREEN: return # Don't show the game over screen if we are already in the unlock screen.
	show_game_over_screen()

## Shows the game over screen and sets the game state to game over.
func show_game_over_screen() -> void: 
	game_over_UI.visible = true
	change_game_state(GameState.GAME_OVER) # Notify listeners that the game state has changed to game_over.

## Hides the game over screen and resets the game state to the main menu.
func hide_game_over_screen() -> void:
	game_over_UI.visible = false
	change_game_state(GameState.MAIN_MENU) # Notify listeners that the game state has changed to main menu.

func restart_game() -> void:
	# Hide the game over UI and return the player to the main menu.
	# print_debug("restart")
	game_over_UI.visible = false	

	# Don't forget to destroy any pickups (health/XP)
	for p in get_tree().get_nodes_in_group("Pickups"):
		p.queue_free()

	# Destroy all projectiles
	for p in get_tree().get_nodes_in_group("Projectiles"):
		p.queue_free()
	
	# # Destroy all cooldown panels.
	# for c in cooldown_container.get_children():
	# 	c.queue_free()
	
	get_node("/root/GameScene/UI/MainMenu/MainMenu").visible = true

	# TODO - reset the player's position too!
	
# Write the player's data to a file
func save_game() -> void:
	DataManager.save_data_to_disk()

# Load the player's data from a file
func load_game() -> void:
	DataManager.load_data_from_disk()

func reset_game() -> void:
	# Reset the player's stats and save the game
	DataManager.reset_saved_data() # Handles game restting and re-saves the data.

	print_debug("Game reset!")


###################################################################################################################
## hello there
####################################################################################################################

## Change to the new game state [param new_state] and emit the [game_state_changed(state)] signal.[br]
func change_game_state(new_state: GameState) -> void:
	# If we are changing to the current state, throw a warning and do nothing.
	if current_state == new_state: 
		push_warning("Error! Attempting to change the game state to the same state! State: " + str(GameState.keys()[new_state]))
		return
	# Set the new state and emit the signal.
	current_state = new_state
	game_state_changed.emit(current_state)
	#print_debug("Game state changed to: " + str(GameState.keys()[current_state]))

## Spawns an experience orb at the given position with the given value. [param pos] is the position to spawn the orb at, and [param value] is the value of the orb.
func spawn_experience_orb(pos: Vector2, value: float) -> void:
	var xp_orb = preload("res://prefabs/pickups/experience_orb.tscn").instantiate()
	call_deferred("add_child", xp_orb)
	# add_child(xp_orb)
	xp_orb.initialize(pos, value) # 10 as a basic "large XP test"
	# xp_orb.global_position = pos
	# xp_orb.set_value(15) # Basic XP test
	# spawned_xp.append(xp_orb)
	# print("spawned xp")