extends Node

#############################
####### REFACTOR AREA #######
#############################
var global_frame_count = 0 ## Tracks the total frames elapsed for anything that is calling something every [i]n[/i] frames.

# TODO - clean this up some day will ya? It's gettin crowded!
@onready var player = get_node("/root/GameScene/Player")
@onready var player_health_bar = get_node("/root/GameScene/UI/PlayerHealthBar")
@onready var level_up_UI = get_node("/root/GameScene/UI/LevelUpUI")
@onready var character_select_UI = get_node("/root/GameScene/UI/CharacterSelectUI")
# @onready var tilemap: TileMapLayer = get_node("/root/GameScene/Level")

# @onready var energy_sword = get_node ("/root/GameScene/Player/Weapons/EnergySword")
# @onready var spreadfire = get_node("/root/GameScene/Player/Weapons/Spreadfire")
# @onready var slam = get_node("/root/GameScene/Player/Weapons/SlamWeaponController")
# @onready var light_blade = get_node("/root/GameScene/Player/Weapons/LightBladeController")
# @onready var arrow = get_node("/root/GameScene/Player/Weapons/ArrowController")
# @onready var waldos = get_node("/root/GameScene/Player/Weapons/Waldos")
# @onready var chain_lightning = get_node("/root/GameScene/Player/Weapons/ChainLightning") as ChainLightning

# @onready var mob_spawn_point: PathFollow2D = get_node("/root/GameScene/Player/MobSpawnPath/MobSpawnPoint")
#@onready var enemy_spawn_timer: Timer = get_node("/root/GameScene/EnemySpawnTimer")
#@onready var enemy_difficulty_timer: Timer = get_node("/root/GameScene/EnemySpawnTimer/EnemyDifficultyTimer")

@onready var game_over_UI: PanelContainer = get_node("/root/GameScene/UI/GameOverUI")
@onready var pause_button: Button = get_node("/root/GameScene/UI/PauseButton")




var game_time_elapsed: float = 0.0

var total_enemies_spawned: int = 0
var game_active: bool = false
# var weapons = []
# var enemies: Array[Node2D]
# var spawned_xp: Array[Node2D]

# Variables to save/load to track player stats
# var total_enemies_killed: int = 0
# var total_xp_gained: int = 0
# var total_damage_done: float = 0.0

signal game_started
signal game_ended

var start_button_pressed = true

var touch_input_enabled: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# get_node("/root/GameScene/Player/Audio/XPPickupSound").connect("finished", print_debug.bind("XP sound finished playing"))

	# Move hte Game Controller node to be a child of the actual game scene.
	# TODO - this is probably unnecessary.
	get_node("/root").call_deferred("remove_child",self)
	get_node("/root/GameScene").call_deferred("add_child", self)
	
	# Player connected signals.
	player.connect("gained_xp", _on_player_gain_xp) # Called when the player gains xp.
	player.connect("gained_level", _on_player_gain_level) # Called when the player gains a level.
	#player.connect("_health_depleted", game_over) # When the player dies
	player.connect("health_changed", update_player_info_text) # When the player's health changes (but not zero)
	
	
	# lol
	var restart_game_button: Button = get_node("/root/GameScene/UI/GameOverUI/MarginContainer/Panel/VBoxContainer/MarginContainer/RestartButton")
	# print_debug(restart_game_button.name)
	restart_game_button.pressed.connect(restart_game)
	
	# Add all weapons to the weapons array
	# weapons.append(energy_sword)
	# weapons.append(spreadfire)
	#weapons.append(slam)
	#weapons.append(light_blade)
	#weapons.append(arrow)
	#weapons.append(waldos)
	#weapons.append(chain_lightning)
	#slam.create_cooldown_panel.connect(create_cooldown_panel.bind(slam))
	#light_blade.create_cooldown_panel.connect(create_cooldown_panel.bind(light_blade))
	#arrow.create_cooldown_panel.connect(create_cooldown_panel.bind(arrow))
	#waldos.create_cooldown_panel.connect(create_cooldown_panel.bind(waldos))
	#chain_lightning.create_cooldown_panel.connect(create_cooldown_panel.bind(chain_lightning))

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


func update_player_info_text(health: float, max_health: float) -> void:
	player_health_bar.health = health
	player_health_bar.max_health = max_health

	#player_health_bar.max_value = max_health
	#player_health_bar.value = health

func spawn_experience_orb(pos: Vector2, value: int) -> void:
	var xp_orb = preload("res://prefabs/pickups/experience_orb.tscn").instantiate()
	call_deferred("add_child", xp_orb)
	# add_child(xp_orb)
	xp_orb.initialize(pos, value) # 10 as a basic "large XP test"
	# xp_orb.global_position = pos
	# xp_orb.set_value(15) # Basic XP test
	# spawned_xp.append(xp_orb)
	# print("spawned xp")

func spawn_health_pickup(pos: Vector2) -> void:
	var health_pickup = preload("res://prefabs/pickups/health_pickup.tscn").instantiate()
	call_deferred("add_child", health_pickup)
	health_pickup.initialize(pos)
	# print("spawned health")

# Reset enemies and weapons, then let the player select a character.
func start_game() -> void:
	total_enemies_spawned = 0

	# for w in weapons:
	# 	w.reset()

	game_time_elapsed = 0.0
	# display_level_up()
	# Display the character select screen
	character_select_UI.visible = true
	game_started.emit()

func select_character(character: PlayerCharacterData) -> void:
	# Hide the select character UI and start the game after setting the player's stats
	character_select_UI.visible = false
	player.initialize(character)
	player_health_bar.init_health(player.health) # Initialize the player's health bar - sets all the values to max health.


	WeaponManager.create_weapon(character.starting_weapon) # Create the weapon based on the character's starting weapon.
	# # TODO - Improve the functionality of the initial weapon gaining via the Weapon enum. Prefer instantiating new instance maybe.
	# match character.starting_weapon:
	# 	Weapon.Type.LIGHT_BLADE:
	# 		light_blade.level_up()
	# 	Weapon.Type.CHAIN_LIGHTNING:
	# 		chain_lightning.level_up()
	# 	Weapon.Type.SLAM:
	# 		slam.level_up()
	# 	Weapon.Type.ARROW:
	# 		arrow.level_up()
	# 	Weapon.Type.WALDOS:
	# 		waldos.level_up()
	# 		waldos.visible = true	

	#character["weapon"].level_up() # Don't need to ask the array since we have a ref already.
	#character["weapon"].visible = true # Make sure the weapon is visiible (required for some weapons)


	unpause_game()
	game_active = true
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
	game_ended.emit()
	save_game()
	pause_game()
	game_active = false
	game_over_UI.visible = true

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
