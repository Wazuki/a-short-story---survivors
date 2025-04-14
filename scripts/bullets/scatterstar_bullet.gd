extends Bullet

## Initialize the bullet basd on the weapon parameters.
func initialize(spawning_weapon: Weapon, data: BulletData, spawn_pos: Vector2, sprite_z_index: int, target: Node2D = null) -> void:
	super.initialize(spawning_weapon, data, spawn_pos, sprite_z_index, target)
	# Set up the knockback status effect.

func _ready() -> void:
	super._ready()
	## When we enter the scene tree, check for any enemies currently overlapping and add them to the affected areas collection.
	for e in get_overlapping_areas():
		if is_instance_valid(e):
			affected_areas.set(e.get_instance_id(), e)

## Shoot the target by playing the animated sprite, waiting a very short delay, and then dealing damage to each target in the area.
func shoot() -> void:
	%ScatterstarSprite.play()
	# Await a small amount, then deal damage to all enemies in the affected area.
	await get_tree().create_timer(0.1).timeout

	# Set the origin of the knockback before iterating to deal damage.
	weapon.knockback_status.set_origin(weapon.global_position)
	# Deal damage to each target in the affected area array.
	for key in affected_areas:
		# Make sure each instance of the enemy is valid. If they are, deal damage to them and heal the player (if possible) the amount listed.
		
		damage_target(affected_areas.get(key), weapon.knockback_status)
		#print_debug("Deal damage to " + e.name)
		weapon.heal_on_hit()

func is_sprite_playing() -> bool: return %ScatterstarSprite.is_playing()


# Signal functions for tracking entities currently in the affected area.
func _on_area_entered(area:Area2D) -> void:
	if is_instance_valid(area): affected_areas.set(area.get_instance_id(), area)

func _on_area_exited(area:Area2D) -> void:
	if affected_areas.has(area.get_instance_id()):
		affected_areas.erase(area.get_instance_id())
