extends Projectile

# Initialize the bullet 
func initialize(spawning_weapon: Weapon, data: ProjectileData, spawn_pos: Vector2, sprite_z_index: int, _target: Node2D = null) -> void:
	super.initialize(spawning_weapon, data, spawn_pos, sprite_z_index)
	# Set any inner-waldo specific variables.
	scale = spawning_weapon.inner_ring_scale

# Set the damage timer's cooldown now that it's in the scene tree.
func _ready() -> void:
	super._ready()
	%DamageTimer.wait_time = damage_cooldown
	%DamageTimer.start()
	top_level = true

## Handles cleanup for the array to purge any entities that may no longer be valid.
func _process(_delta: float) -> void:
	if GameController.global_frame_count % WeaponManager.ENEMY_CLEANUP_FRAME_OFFSET == 0 and not affected_areas.is_empty(): 
		var cleaned_array = affected_areas.values().filter(is_instance_valid)
		affected_areas.clear()
		for e in cleaned_array: affected_areas.set(e.get_instance_id(), e)

## Rotate the weapon based on its speed, then deal damage (if the timer has stopped) to enemies in range.
func _physics_process(delta: float) -> void:
	rotation += speed * delta
	# Have the inner ring follow the main waldos.
	global_position = weapon.global_position

	if %DamageTimer.is_stopped() and not affected_areas.is_empty():
		damage_affected_enemies()


## Adds the enemy to the inner ring dict while within range.
# func _on_inner_ring_entered(area: Area2D) -> void:
# 	if area is Enemy and inner_ring_enabled: inner_ring_enemies.set(area.get_instance_id(), area)

## Removes the enemy from the inner ring dict when they leave the range.
# func _on_inner_ring_exited(area: Area2D) -> void:
# 	if area is Enemy and inner_ring_enabled:
# 		if inner_ring_enemies.has(area):
# 			inner_ring_enemies.erase(area)

## Deal damage to each affected enemy and then reset the damage timer.
func damage_affected_enemies() -> void:
	for key in affected_areas:
		damage_target(affected_areas[key])
	%DamageTimer.start()
	#print_debug(name + " dealt damage!")

## Adds any enemy that enters the area to our damaging dict.
func _on_area_entered(area:Area2D) -> void:
	if area is BaseEnemy:
		affected_areas.set(area.get_instance_id(), area)

## When an enemy leaves the area, remove them from the dictionary.
func _on_area_exited(area:Area2D) -> void:
	if area is BaseEnemy:
		if affected_areas.has(area.get_instance_id()):
			affected_areas.erase(area.get_instance_id())
