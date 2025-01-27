extends Node


@onready var player = get_node("/root/GameScene/Player")
@onready var level_up_UI = get_node("/root/GameScene/UI/LevelUpUI")
@onready var energy_sword = get_node ("/root/GameScene/Player/Weapons/EnergySword")
@onready var spreadfire = get_node("/root/GameScene/Player/Weapons/Spreadfire")

@onready var mob_spawn_point: PathFollow2D = get_node("/root/GameScene/Player/MobSpawnPath/MobSpawnPoint")
@onready var enemy_spawn_timer: Timer = get_node("/root/GameScene/EnemySpawnTimer")

@onready var game_over_UI: PanelContainer = get_node("/root/GameScene/UI/GameOverUI")
var enemies: Array[Node2D]
var spawned_xp: Array[Node2D]

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
	
	pause_game()


func spawn_enemy() -> void:
	# print_debug("spawn enemy")
	mob_spawn_point.progress_ratio = randf()
	var new_enemy = preload("res://prefabs/enemy.tscn").instantiate()
	new_enemy.global_position = mob_spawn_point.global_position 
	add_child(new_enemy)
	enemies.append(new_enemy)
	
func stop_tracking_enemy(e: Node2D) -> void:
	enemies.erase(e)
	
func stop_tracking_xp_orb(xp: Node2D) -> void:
	spawned_xp.erase(xp)

func spawn_experience_orb(pos: Vector2) -> void:
	var xp_orb = preload("res://prefabs/experience_orb.tscn").instantiate()
	call_deferred("add_child", xp_orb)
	# add_child(xp_orb)
	xp_orb.initialize(pos, 5) # 10 as a basic "large XP test"
	# xp_orb.global_position = pos
	# xp_orb.set_value(15) # Basic XP test
	spawned_xp.append(xp_orb)
	# print("spawned xp")

func start_game() -> void:
	player.reset()
	level_up_UI.reset_weapons()
	display_level_up()

func display_level_up() -> void:
	level_up_UI.show_level_up_screen()

func pause_game() -> void:
	get_tree().paused = true

func unpause_game() -> void:
	get_tree().paused = false

func quit_game() -> void:
	get_tree().quit() # TODO - Save data. Confirm quit?


func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()

func round_to_dec(num: float, digit: int) -> float:
	return round(num * pow(10.0, digit) / pow(10.0, digit))
	
func game_over() -> void:
	#Pause the game, destroy all enemies, then show the game over UI 
	pause_game()
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
	
