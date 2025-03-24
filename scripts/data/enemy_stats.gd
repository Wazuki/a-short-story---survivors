class_name EnemyStats
extends CharacterStats

## Determines the enemy type for their behavior as well for allowing for future expandability.
enum EnemyType { BASIC, ELITE, BOSS, RANGED }

## Variables for derived enemies to define for stat initialization.
var enemy_health: float
var enemy_speed: float
var enemy_armor: float = 0.0 # Some enemies won't have armor so default this to zero.

var base_speed: float ## The base, unmodified speed of the enemy.

@export_category("Non-Coded Values")
@export var xp_value: int ## Value of experience orbs dropped by the enemy.
@export var enemy_scale: Vector2 ## Scale the enemy will use - bosses tend to be larger.
@export var health_drop_chance: float = 0.0 ## Chance for the enemy to drop a health pickup.
@export var contact_damage: float = 1.0 ## How much damage the enemy should do to the player when it touches them.
@export var attack_damage: float = 0.0 ## How much damage the enemy does with each attack (if any - most won't have any)


# Initialize the enemy's stat block when we are ready since the enemies will define them in init.
func initialize() -> void:
	stats[Stat.HEALTH] = get_base_health()
	stats[Stat.MAX_HEALTH] = stats[Stat.HEALTH]
	stats[Stat.ARMOR] = get_base_armor()
	stats[Stat.SPEED] = get_base_speed()
	base_speed = enemy_speed

func get_copy() -> EnemyStats: return self.duplicate()

## Overridable setters for enemy stats.
func get_base_health() -> float: return 1
func get_base_speed() -> float: return 10.0
func get_base_armor() -> float: return 0.0
func get_type() -> EnemyType: return EnemyType.BASIC