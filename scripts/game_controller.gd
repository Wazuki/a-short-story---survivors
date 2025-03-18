extends Node

## Default values for the game.
## Tracks the z-index for all sprite layers
var sprite_constants: SpriteConstants = preload("res://scripts/data_resources/sprite_constants.tres")

## In game variables
var tracked_variables :TrackedVariables = preload("res://scripts/data_resources/tracked_variables.tres")

# TODO - clean this up some day will ya? It's gettin crowded!
@onready var player = get_node("/root/GameScene/Player")
@onready var player_health_bar = get_node("/root/GameScene/UI/PlayerHealthBar")
@onready var level_up_UI = get_node("/root/GameScene/UI/LevelUpUI")
@onready var character_select_UI = get_node("/root/GameScene/UI/CharacterSelectUI")
@onready var tilemap: TileMapLayer = get_node("/root/GameScene/Level")

@onready var energy_sword = get_node ("/root/GameScene/Player/Weapons/EnergySword")
@onready var spreadfire = get_node("/root/GameScene/Player/Weapons/Spreadfire")
@onready var slam = get_node("/root/GameScene/Player/Weapons/SlamWeaponController")
@onready var light_blade = get_node("/root/GameScene/Player/Weapons/LightBladeController")
@onready var arrow = get_node("/root/GameScene/Player/Weapons/ArrowController")
@onready var waldos = get_node("/root/GameScene/Player/Weapons/Waldos")
@onready var chain_lightning = get_node("/root/GameScene/Player/Weapons/ChainLightning") as ChainLightning

@onready var mob_spawn_point: PathFollow2D = get_node("/root/GameScene/Player/MobSpawnPath/MobSpawnPoint")
@onready var enemy_spawn_timer: Timer = get_node("/root/GameScene/EnemySpawnTimer")
@onready var enemy_difficulty_timer: Timer = get_node("/root/GameScene/EnemySpawnTimer/EnemyDifficultyTimer")

@onready var game_over_UI: PanelContainer = get_node("/root/GameScene/UI/GameOverUI")
@onready var pause_button: Button = get_node("/root/GameScene/UI/PauseButton")

@onready var cooldown_container = get_node("/root/GameScene/UI/CooldownContainer")

var quest: QuestResource = load("res://test_quest.tres")

const BASE_DIFFICULTY_INCREASE_TIME = 60.0
const BASE_ENEMY_SPAWN_TIME = 0.5
var enemy_spawn_time = BASE_ENEMY_SPAWN_TIME

var game_time_elapsed: float = 0.0

var total_enemies_spawned: int = 0
var game_started: bool = false
var weapons = []
var difficulty = 0
# var enemies: Array[Node2D]
# var spawned_xp: Array[Node2D]

# Variables to save/load to track player stats
# var total_enemies_killed: int = 0
# var total_xp_gained: int = 0
# var total_damage_done: float = 0.0



var start_button_pressed = true

var touch_input_enabled: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var instance := quest.instantiate()
	Questify.start_quest(instance)
	for q in Questify.get_quests():
		print_debug(q.name)
		for o in q.get_active_objectives():
			print_debug(o.description)

	# get_node("/root/GameScene/Player/Audio/XPPickupSound").connect("finished", print_debug.bind("XP sound finished playing"))

	# Move hte Game Controller node to be a child of the actual game scene.
	# TODO - this is probably unnecessary.
	get_node("/root").call_deferred("remove_child",self)
	get_node("/root/GameScene").call_deferred("add_child", self)
	enemy_spawn_timer.connect("timeout", _on_enemy_spawn_timer_timeout)
	enemy_difficulty_timer.connect("timeout", _on_enemy_difficulty_timer_timeout)
	
	# Player connected signals.
	player.connect("gained_xp", _on_player_gain_xp) # Called when the player gains xp.
	player.connect("gained_level", _on_player_gain_level) # Called when the player gains a level.
	player.connect("_health_depleted", game_over) # When the player dies
	player.connect("_health_changed", update_player_info_text) # When the player's health changes (but not zero)
	
	
	# lol
	var restart_game_button: Button = get_node("/root/GameScene/UI/GameOverUI/MarginContainer/Panel/VBoxContainer/MarginContainer/RestartButton")
	# print_debug(restart_game_button.name)
	restart_game_button.pressed.connect(restart_game)
	
	# Add all weapons to the weapons array
	# weapons.append(energy_sword)
	# weapons.append(spreadfire)
	weapons.append(slam)
	weapons.append(light_blade)
	weapons.append(arrow)
	weapons.append(waldos)
	weapons.append(chain_lightning)
	slam.create_cooldown_panel.connect(create_cooldown_panel.bind(slam))
	light_blade.create_cooldown_panel.connect(create_cooldown_panel.bind(light_blade))
	arrow.create_cooldown_panel.connect(create_cooldown_panel.bind(arrow))
	waldos.create_cooldown_panel.connect(create_cooldown_panel.bind(waldos))
	chain_lightning.create_cooldown_panel.connect(create_cooldown_panel.bind(chain_lightning))

	load_game()
	# Initialize the character select UI to properly set the weapons in the Dict
	character_select_UI.init()
	pause_game()

func _process(delta: float) -> void:
	if game_started: 
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

func spawn_enemy() -> void:

	total_enemies_spawned += 1

	# Spawn a basic enemy. Every 20 enemies, spawn an elite. Every 50, spawn a boss.

	# Randomly find a tile on the tilemap to spawn enemy (so we don't spawn outside the map)
	mob_spawn_point.progress_ratio = randf()
	while(is_point_on_tilemap(tilemap.to_local(mob_spawn_point.global_position))): # We want the global pos converted to a local pos relative ot the tilemap
		mob_spawn_point.progress_ratio = randf()


	var new_enemy = preload("res://prefabs/enemy_kinematic.tscn").instantiate()
	new_enemy.global_position = mob_spawn_point.global_position 
	add_child(new_enemy)
	#new_enemy.initialize() # Moved to the enemy's _ready()
	
	# Connect any important signals to the GameController from the new enemy.
	new_enemy.damaged.connect(_on_enemy_damaged)
	new_enemy.health_depleted.connect(_on_enemy_health_depleted)

	# Initialize the enemy as an elite or boss if the total enemies spawned is a multiple of 20 or 50
	#if total_enemies_spawned % 50 == 0:
	#	new_enemy.initialize(new_enemy.EnemyType.BOSS)
	#elif total_enemies_spawned % 20 == 0:
	#	new_enemy.initialize(new_enemy.EnemyType.ELITE)
	#else:
	#	new_enemy.initialize(new_enemy.EnemyType.BASIC)

	# enemies.append(new_enemy)

func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()

	# Spawn extra enemies based on the difficulty
	var extra_enemy_count = difficulty
	while extra_enemy_count > 0:
		spawn_enemy()
		extra_enemy_count -= 1

	enemy_spawn_timer.wait_time = enemy_spawn_time

# Signals for tracking global player-saved variables.
func _on_enemy_damaged(amount) -> void: tracked_variables.add_value(TrackedVariables.Type.DAMAGE, amount)
func _on_enemy_health_depleted() -> void: tracked_variables.add_value(TrackedVariables.Type.KILLS, 1)
func _on_player_gain_xp(amount) -> void: tracked_variables.add_value(TrackedVariables.Type.XP, amount)
func _on_player_gain_level() -> void: tracked_variables.add_value(TrackedVariables.Type.LEVELS, 1)

func _on_enemy_difficulty_timer_timeout() -> void:
	enemy_spawn_time = clamp(enemy_spawn_time - 0.1, 0.1, BASE_ENEMY_SPAWN_TIME)
	difficulty += 1
	# print_debug("Difficulty: " + str(difficulty))

func update_player_info_text(health: float, max_health: float) -> void:
	player_health_bar.health = health
	player_health_bar.max_health = max_health

	#player_health_bar.max_value = max_health
	#player_health_bar.value = health

func is_point_on_tilemap(pos: Vector2) -> bool:
	
	var map_pos = tilemap.local_to_map(pos)
	var cell = tilemap.get_cell_tile_data(map_pos)
	# print_debug("Cell: " + str(cell))
	return cell == null # If the cell is null we're off the map - return true, go back to the loop, and try again.
	# return false # We want this to return false in the end because the loop will run until we find a cell that is ON the map. True continues the loop!

func spawn_experience_orb(pos: Vector2, value: int) -> void:
	var xp_orb = preload("res://prefabs/experience_orb.tscn").instantiate()
	call_deferred("add_child", xp_orb)
	# add_child(xp_orb)
	xp_orb.initialize(pos, value) # 10 as a basic "large XP test"
	# xp_orb.global_position = pos
	# xp_orb.set_value(15) # Basic XP test
	# spawned_xp.append(xp_orb)
	# print("spawned xp")

func spawn_health_pickup(pos: Vector2) -> void:
	var health_pickup = preload("res://prefabs/health_pickup.tscn").instantiate()
	call_deferred("add_child", health_pickup)
	health_pickup.initialize(pos)
	# print("spawned health")

# Reset enemies and weapons, then let the player select a character.
func start_game() -> void:
	total_enemies_spawned = 0

	for w in weapons:
		w.reset()
	
	# Reset the enemy spawn timer and start it.
	enemy_spawn_timer.wait_time = BASE_ENEMY_SPAWN_TIME
	enemy_spawn_timer.start()
	# Reset the enemy difficulty timer as well.
	enemy_difficulty_timer.wait_time = BASE_DIFFICULTY_INCREASE_TIME
	enemy_difficulty_timer.start()

	game_time_elapsed = 0.0
	# display_level_up()
	# Display the character select screen
	character_select_UI.visible = true

func select_character(character: Character) -> void:
	# Hide the select character UI and start the game after setting the player's stats
	character_select_UI.visible = false
	player.initialize(character)
	player_health_bar.init_health(player.health) # Initialize the player's health bar - sets all the values to max health.

	# TODO - Improve the functionality of the initial weapon gaining via the Weapon enum. Prefer instantiating new instance maybe.
	match character.starting_weapon:
		Weapon.Type.LIGHT_BLADE:
			light_blade.level_up()
		Weapon.Type.CHAIN_LIGHTNING:
			chain_lightning.level_up()
		Weapon.Type.SLAM:
			slam.level_up()
		Weapon.Type.ARROW:
			arrow.level_up()
		Weapon.Type.WALDOS:
			waldos.level_up()
			waldos.visible = true	

	#character["weapon"].level_up() # Don't need to ask the array since we have a ref already.
	#character["weapon"].visible = true # Make sure the weapon is visiible (required for some weapons)


	unpause_game()
	game_started = true
	# print_debug("Selected " + character)

# Create a new cooldown panel and instantiate it, then connect the weapon firing signal to resetting the cooldown panel's timer
func create_cooldown_panel(weapon: Weapon) -> void:
	var new_panel = preload("res://prefabs/cooldown_panel.tscn").instantiate()
	new_panel.initialize(weapon.icon, weapon.name, weapon.cooldown)
	weapon.fire.connect(new_panel.reset_cooldown)
	weapon.gained_level.connect(new_panel.update_level_text)
	weapon.begin_attack_sequence.connect(new_panel.begin_attack_sequence)
	cooldown_container.add_child(new_panel)

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
	save_game()
	pause_game()
	game_started = false
	game_over_UI.visible = true

func restart_game() -> void:
	# Hide the game over UI and return the player to the main menu.
	# print_debug("restart")
	game_over_UI.visible = false	
	difficulty = 0

	# Destroy all enemies
	for e in get_tree().get_nodes_in_group("Enemies"):
		e.queue_free()

	# Don't forget to destroy any pickups (health/XP)
	for p in get_tree().get_nodes_in_group("Pickups"):
		p.queue_free()

	# Destroy all projectiles
	for p in get_tree().get_nodes_in_group("Projectiles"):
		p.queue_free()
	
	# Destroy all cooldown panels.
	for c in cooldown_container.get_children():
		c.queue_free()
	
	get_node("/root/GameScene/UI/MainMenu/MainMenu").visible = true

	# TODO - reset the player's position too!
	
# Write the player's data to a file
func save_game() -> void:
	var save_data = ConfigFile.new()
	# Save the player's preferences too!
	save_data.set_value("Settings", "touch_input_enabled", touch_input_enabled)
	save_data.set_value("Settings", "sound_volume", db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))))
	save_data.set_value("Settings", "music_volume", db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))))
	
	# Save the player's stats
	save_data.set_value("SaveData","enemies killed", tracked_variables.get_value(TrackedVariables.Type.KILLS))
	save_data.set_value("SaveData","xp gained", tracked_variables.get_value(TrackedVariables.Type.XP))
	save_data.set_value("SaveData","damage done", tracked_variables.get_value(TrackedVariables.Type.DAMAGE))
	save_data.set_value("SaveData","levels gained", tracked_variables.get_value(TrackedVariables.Type.LEVELS))

	save_data.save("user://save_game.cfg")
	print_debug("Game saved!")

	character_select_UI.check_unlock_requiremets()

# Load the player's data from a file
func load_game() -> void:
	var save_data = ConfigFile.new()
	var error = save_data.load("user://save_game.cfg")
	if error != OK: return

	# Load the player's preferences
	touch_input_enabled = save_data.get_value("Settings", "touch_input_enabled", false)
	$"/root/GameScene/UI/MainMenu".set_touch_input_button_state(touch_input_enabled)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(save_data.get_value("Settings", "sound_volume", 0.5)))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(save_data.get_value("Settings", "music_volume", 0.5)))

	# Load the player's tracked variables from file and assign it to the tracked variable var
	tracked_variables.set_value(TrackedVariables.Type.KILLS, save_data.get_value("SaveData","enemies killed", 0))
	tracked_variables.set_value(TrackedVariables.Type.XP, save_data.get_value("SaveData","xp gained", 0))
	tracked_variables.set_value(TrackedVariables.Type.DAMAGE, save_data.get_value("SaveData","damage done", 0))
	tracked_variables.set_value(TrackedVariables.Type.LEVELS, save_data.get_value("SaveData","levels gained", 0))
	
	for v in tracked_variables.values:
		var value = tracked_variables.values[v]
		var value_name:String = TrackedVariables.Type.keys()[v]
		print_debug(value_name + " " + str(value))

	# total_xp_gained = save_data.get_value("SaveData","xp gained")
	# total_damage_done = save_data.get_value("SaveData","damage done")
	# print_debug("Game loaded!")
	# print_debug("Enemies killed: " + str(total_enemies_killed))
	# print_debug("XP gained: " + str(total_xp_gained))
	# print_debug("Damage done: " + str(total_damage_done))

func reset_game() -> void:
	# Reset the player's stats and save the game
	for v in tracked_variables.values: tracked_variables.set_value(v, 0) # Iterates through the tracked variables and zeroes them out.
	save_game()

	character_select_UI.check_unlock_requiremets()
	print_debug("Game reset!")

# Go through the weapons and find the one that matches our type and return it.
func get_weapon_by_type(t: Weapon.Type) -> Weapon:
	for w in weapons: if w.weapon_type == t: return w
	print_debug(Weapon.Type.keys()[t] + " was not found in the weapon array.")
	return null
