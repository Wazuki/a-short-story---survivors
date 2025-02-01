extends Node


@onready var player = get_node("/root/GameScene/Player")
@onready var level_up_UI = get_node("/root/GameScene/UI/LevelUpUI")
@onready var character_select_UI = get_node("/root/GameScene/UI/CharacterSelectUI")
@onready var tilemap: TileMapLayer = get_node("/root/GameScene/Level")

@onready var energy_sword = get_node ("/root/GameScene/Player/Weapons/EnergySword")
@onready var spreadfire = get_node("/root/GameScene/Player/Weapons/Spreadfire")
@onready var slam = get_node("/root/GameScene/Player/Weapons/SlamWeaponController")
@onready var light_blade = get_node("/root/GameScene/Player/Weapons/LightBladeController")
@onready var arrow = get_node("/root/GameScene/Player/Weapons/ArrowController")
@onready var waldos = get_node("/root/GameScene/Player/Weapons/Waldos")

@onready var mob_spawn_point: PathFollow2D = get_node("/root/GameScene/Player/MobSpawnPath/MobSpawnPoint")
@onready var enemy_spawn_timer: Timer = get_node("/root/GameScene/EnemySpawnTimer")

@onready var game_over_UI: PanelContainer = get_node("/root/GameScene/UI/GameOverUI")

var total_enemies_spawned: int = 0
var game_started: bool = false
var weapons = []
var enemies: Array[Node2D]
var spawned_xp: Array[Node2D]

# Variables to save/load to track player stats
var total_enemies_killed: int = 0
var total_xp_gained: int = 0
var total_damage_done: float = 0.0

var touch_input_enabled: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Move hte Game Controller node to be a child of the actual game scene.
	# TODO - this is probably unnecessary.
	get_node("/root").call_deferred("remove_child",self)
	get_node("/root/GameScene").call_deferred("add_child", self)
	enemy_spawn_timer.connect("timeout", _on_enemy_spawn_timer_timeout)
	
	player.connect("_health_depleted", game_over)
	
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

	load_game()
	# Initialize the character select UI to properly set the weapons in the Dict
	character_select_UI.init()
	pause_game()


func spawn_enemy() -> void:
	total_enemies_spawned += 1

	# Spawn a basic enemy. Every 20 enemies, spawn an elite. Every 50, spawn a boss.

	# Randomly find a tile on the tilemap to spawn enemy (so we don't spawn outside the map)
	mob_spawn_point.progress_ratio = randf()
	while(is_point_on_tilemap(tilemap.to_local(mob_spawn_point.global_position))): # We want the global pos converted to a local pos relative ot the tilemap
		mob_spawn_point.progress_ratio = randf()


	var new_enemy = preload("res://prefabs/enemy.tscn").instantiate()
	new_enemy.global_position = mob_spawn_point.global_position 
	add_child(new_enemy)

	# Initialize the enemy as an elite or boss if the total enemies spawned is a multiple of 20 or 50
	if total_enemies_spawned % 50 == 0:
		new_enemy.initialize("boss")
	elif total_enemies_spawned % 20 == 0:
		new_enemy.initialize("elite")
	else:
		new_enemy.initialize("basic")

	enemies.append(new_enemy)

func is_point_on_tilemap(pos: Vector2) -> bool:
	
	var map_pos = tilemap.local_to_map(pos)
	var cell = tilemap.get_cell_tile_data(map_pos)
	# print_debug("Cell: " + str(cell))
	return cell == null # If the cell is null we're off the map - return true, go back to the loop, and try again.
	# return false # We want this to return false in the end because the loop will run until we find a cell that is ON the map. True continues the loop!

func stop_tracking_enemy(e: Node2D) -> void:
	enemies.erase(e)
	
func stop_tracking_xp_orb(xp: Node2D) -> void:
	spawned_xp.erase(xp)

func spawn_experience_orb(pos: Vector2, value: int) -> void:
	var xp_orb = preload("res://prefabs/experience_orb.tscn").instantiate()
	call_deferred("add_child", xp_orb)
	# add_child(xp_orb)
	xp_orb.initialize(pos, value) # 10 as a basic "large XP test"
	# xp_orb.global_position = pos
	# xp_orb.set_value(15) # Basic XP test
	spawned_xp.append(xp_orb)
	# print("spawned xp")

# Reset enemies and weapons, then let the player select a character.
func start_game() -> void:
	total_enemies_spawned = 0

	for w in weapons:
		w.reset()
	
	# display_level_up()
	# Display the character select screen
	character_select_UI.visible = true

func select_character(character: Dictionary) -> void:
	# Hide the select character UI and start the game after setting the player's stats
	character_select_UI.visible = false
	player.initialize(character)
	character["weapon"].level_up() # Don't need to ask the array since we have a ref already.
	character["weapon"].visible = true # Make sure the weapon is visiible (required for some weapons)
	unpause_game()
	game_started = true
	# print_debug("Selected " + character)


func display_level_up() -> void:
	level_up_UI.show_level_up_screen()

func pause_game() -> void:
	get_tree().paused = true

func unpause_game() -> void:
	get_tree().paused = false

func quit_game() -> void:
	# Save the game and quit
	save_game()
	get_tree().quit() # TODO - Save data. Confirm quit?


func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()

func round_to_dec(num: float, digit: int) -> float:
	return round(num * pow(10.0, digit) / pow(10.0, digit))
	
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
	
	# Destroy all enemies
	for e in enemies:
		e.queue_free()
	enemies.clear()
	
	# Detroy experience too
	for xp in spawned_xp:
		xp.queue_free()
	spawned_xp.clear()
	
	get_node("/root/GameScene/UI/MainMenu").visible = true

	# TODO - reset the player's position too!
	
# Write the player's data to a file
func save_game() -> void:
	var save_data = ConfigFile.new()
	# Save the player's preferences too!
	save_data.set_value("Settings", "touch_input_enabled", touch_input_enabled)
	save_data.set_value("Settings", "sound_volume", db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))))
	save_data.set_value("Settings", "music_volume", db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))))
	
	# Save the player's stats
	save_data.set_value("SaveData","enemies killed", total_enemies_killed)
	save_data.set_value("SaveData","xp gained", total_xp_gained)
	save_data.set_value("SaveData","damage done", total_damage_done)
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

	total_enemies_killed = save_data.get_value("SaveData","enemies killed")
	total_xp_gained = save_data.get_value("SaveData","xp gained")
	total_damage_done = save_data.get_value("SaveData","damage done")
	# print_debug("Game loaded!")
	# print_debug("Enemies killed: " + str(total_enemies_killed))
	# print_debug("XP gained: " + str(total_xp_gained))
	# print_debug("Damage done: " + str(total_damage_done))

func reset_game() -> void:
	# Reset the player's stats and save the game
	total_enemies_killed = 0
	total_xp_gained = 0
	total_damage_done = 0.0
	save_game()
	character_select_UI.check_unlock_requiremets()
	print_debug("Game reset!")
