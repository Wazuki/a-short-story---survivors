extends Node
# Manager class for tracking enemies and telling weapons to discard tracked enemies from their respective collections.

var enemy_database: EnemyDatabase = load("res://data/characters/enemies/enemy_database.tres") ## Enemy database that handles enemy vital statistics and data.
@onready var tile_map_layer: TileMapLayer = get_node("/root/GameScene/Level")
var mob_spawn_point: PathFollow2D

# Constants
const BASE_DIFFICULTY_INCREASE_TIME = 60.0 ## Rate at which the difficulty increases and more enemies spawn.
const BASE_ENEMY_SPAWN_TIME = 0.5 ## Base rate at which new enemies spawn.
var enemy_spawn_rate = BASE_ENEMY_SPAWN_TIME ## Current rate at which enemies spawn.

# Timers for tracking enemies.
var enemy_spawn_timer: Timer
var enemy_difficulty_timer: Timer

var total_enemies_spawned: int = 0
var enemy_difficulty: int = 0

var spawned_enemies = {}

signal remove_invalid_enemy(instance_id: int)
signal cleanup

func _init() -> void:
	enemy_database.initialize()

func _ready() -> void:
	# Set up the base timers and set the signals properly. Don't forget to add the timers to the tree!
	# Enemy Spawn Timer
	enemy_spawn_timer = Timer.new()
	enemy_spawn_timer.wait_time = enemy_spawn_rate
	enemy_spawn_timer.one_shot = false
	enemy_spawn_timer.connect("timeout", _on_enemy_spawn_timer_timeout)
	add_child(enemy_spawn_timer)
	# Enemy Difficulty Timer
	enemy_difficulty_timer = Timer.new()
	enemy_difficulty_timer.wait_time = BASE_DIFFICULTY_INCREASE_TIME
	enemy_difficulty_timer.one_shot = false
	enemy_difficulty_timer.connect("timeout", _on_enemy_difficulty_timer_timeout)
	add_child(enemy_difficulty_timer)
	

	# Connect our signals to the GameManager's game_started and game_over signals to spawn and cleanup enemies quickly.
	if not GameController.is_node_ready(): await GameController.ready
	GameController.game_started.connect(begin_enemy_spawn)
	GameController.game_ended.connect(cleanup_enemies)

## Start the enemy timers to spawn enemies.
func begin_enemy_spawn() -> void:
	if enemy_spawn_timer.is_stopped(): enemy_spawn_timer.start()
	if enemy_difficulty_timer.is_stopped(): enemy_difficulty_timer.start()

func spawn_enemy() -> void:
	# print_debug("new enemy")
	total_enemies_spawned += 1	
	# Randomly find a tile on the tilemap to spawn enemy (so we don't spawn outside the map)
	mob_spawn_point.progress_ratio = randf()
	while(MapUtils.is_point_on_tilemap(tile_map_layer, tile_map_layer.to_local(mob_spawn_point.global_position))): # We want the global pos converted to a local pos relative ot the tilemap
		mob_spawn_point.progress_ratio = randf()

	# Spawn the enemy based on the EnemyDatabase stats.
	var new_enemy = preload("res://prefabs/characters/enemies/enemy.tscn").instantiate()
	add_child(new_enemy)

	new_enemy.initialize(enemy_database.init_from_type(determine_enemy_type(total_enemies_spawned)))
	new_enemy.global_position = mob_spawn_point.global_position 

	# Connect any important signals to the GameController from the new enemy.
	new_enemy.damaged.connect(_on_enemy_damaged)
	new_enemy.enemy_died.connect(_on_enemy_health_depleted)

	# Finally, add add the enemy to the spawned_enemies container.
	spawned_enemies.set(new_enemy.get_instance_id(), new_enemy)

func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()

	# Spawn extra enemies based on the difficulty
	var extra_enemy_count = enemy_difficulty
	while extra_enemy_count > 0:
		spawn_enemy()
		extra_enemy_count -= 1

	# Update the enemy spawn rate as it may change due to a difficulty increase.
	enemy_spawn_timer.wait_time = enemy_spawn_rate

func startup_enemies() -> void:
	# Reset the enemy spawn timer and start it.
	enemy_spawn_timer.wait_time = BASE_ENEMY_SPAWN_TIME
	enemy_spawn_timer.start()
	# Reset the enemy difficulty timer as well.
	enemy_difficulty_timer.wait_time = BASE_DIFFICULTY_INCREASE_TIME
	enemy_difficulty_timer.start()
	enemy_difficulty = 0 # Reset the difficulty too!

func cleanup_enemies() -> void:
	# Destroy all enemies
	for e in get_tree().get_nodes_in_group("Enemies"):
		e.queue_free()

	# Emit the cleanup signal to tell any listeners to clean up their own references.
	cleanup.emit()

func _on_enemy_difficulty_timer_timeout() -> void:
	enemy_spawn_rate = clamp(enemy_spawn_rate - 0.1, 0.1, BASE_ENEMY_SPAWN_TIME)
	enemy_difficulty += 1
	# print_debug("Difficulty: " + str(difficulty))


## Determine what enemy type to spawn based on a counter (typically total enemies spawned).[br]
func determine_enemy_type(enemy_count: int) -> EnemyStats.EnemyType:
	# Spawn a basic enemy. Every 12, a ranged enemy. Every 20 enemies, spawn an elite. Every 50, spawn a boss. 
	if enemy_count % 50 == 0: return EnemyStats.EnemyType.BOSS
	elif enemy_count % 20 == 0: return EnemyStats.EnemyType.ELITE
	elif enemy_count % 12 == 0: return EnemyStats.EnemyType.RANGED
	else: return EnemyStats.EnemyType.BASIC


# Signal connectors for tracking player variables.
func _on_enemy_damaged(amount) -> void: DataManager.add_value("damage", amount)

## Removes the enemy from each of the weapon's arrays if it has it.
func _on_enemy_health_depleted(enemy: Enemy) -> void: 
	DataManager.add_value("kills", 1)

	# Emit the remove_invalid_enemy signal to tell any listeners (weapon etc) that this enemy is no longer a valid ref.
	if spawned_enemies.has(enemy): remove_invalid_enemy.emit(enemy.get_instance_id())
