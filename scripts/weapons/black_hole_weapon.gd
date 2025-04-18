extends Weapon
# Fire a spinning black hole at a random target, dealing damage in in area over time

var start_size: Vector2 ## The initial size of the projectile when spawned
var max_size: Vector2 ## The maximum size of the projectile - our tween target
var grow_time: float ## The time it takes for the black hole to go from [start_size] to [max_size]

var vortex_status: StatusEffect ## TODO - The Vortex status effect that will draw enemies to the center of the vortex

var projectile_lifetime_increase: float = 0.0 ## The amount added to the projectile's lifetime
var projectile_tick_duration_increase: float = 0.0 ## The amount the projectile's damage duration 

func initialize(data: WeaponData) -> void:
	super.initialize(data)

	start_size = data.start_size
	max_size = data.max_size
	grow_time = data.grow_time

func _physics_process(_delta: float) -> void:
	if ready_to_fire:
		spawn_black_hole()


## Spawns a black hole at a target, growing in size over time and dealing damage to nearby enemies.
func spawn_black_hole() -> void:
	# Find the enemy in range with the highest number of enemies nearby (the "biggest cluster")
	var target = get_enemy_with_largest_cluster_in_range()

	if not target:
		print_debug("No targets within range!")
		return

	# Create a black hole at our position, then tween it over time.
	var black_hole = instantiate_projectile_by_key(SceneKey.PROJECTILE, global_position, SpriteConstants.Z_INDEX.BLACK_HOLE)
	add_child(black_hole)

	black_hole.scale = start_size
	black_hole.top_level = true
	var move_time = global_position.distance_to(target.global_position) / speed
	# Create a tween to animate the global position and scale increase of the black hole
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(black_hole, "scale", max_size, grow_time).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(black_hole, "global_position", target.global_position, move_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	fire_weapon()