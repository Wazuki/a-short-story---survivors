extends EnemyData

## Overridable setters for enemy stats.
# func get_base_health() -> float: return 80
# func get_base_speed() -> float: return 100.0
# func get_base_armor() -> float: return 0.0
func get_type() -> EnemyType: return EnemyType.BOSS