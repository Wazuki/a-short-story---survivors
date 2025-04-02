extends EnemyData

## Overridable setters for enemy stats.
# func get_base_health() -> float: return 40
# func get_base_speed() -> float: return 75.0
# func get_base_armor() -> float: return 0.0
func get_type() -> EnemyType: return EnemyType.ELITE