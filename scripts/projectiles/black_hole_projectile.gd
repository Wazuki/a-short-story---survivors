extends Projectile

const DESTROY_TIME = 0.25
# func initialize(spawning_weapon: Weapon, data: ProjectileData, spawn_pos: Vector2, sprite_z_index: int, target: Node2D = null) -> void:
# 	super.initialize(spawning_weapon, data, spawn_pos, sprite_z_index, target)
var damage_timer: float = 0.0

# Iterate through the enemies we spawn on and add them to the affected enemies, then damage them.
func _ready() -> void:
	super._ready()

	damage_timer = damage_cooldown # Set this to the current cooldown so we'll damage enemies when we first spawn.
	if not get_overlapping_areas().is_empty():
		for node in get_overlapping_areas():
			if node is Enemy:
				affected_areas.set(node.get_instance_id(), node)

## Deal damage to the enemies in the array if the damage timer has expired, then reset the timer.
func _physics_process(delta: float) -> void:
	damage_timer += delta

	if damage_timer >= damage_cooldown:
		for key in affected_areas:
			damage_target(affected_areas[key]) # TODO - add Vortex status effect to this!
		damage_timer -= damage_cooldown

## Add the Enemy to the [affected_areas] Dict if they are a valid target.
func _on_area_entered(area:Area2D) -> void:
	if area is Enemy and is_instance_valid(area): affected_areas.set(area.get_instance_id(), area)

## Remove the Enemy from the [affected_areas] Dict if they leave the area.
func _on_area_exited(area:Area2D) -> void:
	var key = area.get_instance_id()

	# Remove the enemy from the dictionary if we have a reference to them.
	if affected_areas.has(key):
		affected_areas.erase(key)

## Destroy the projectile on the timer expiration (with effects)
func destroy_self_on_timer_timeout() -> void:
	# Animate the projectile shrinking to zero then destroy it/
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, DESTROY_TIME).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	# Wait for the tween to finish before destroying the projectile (from the super's call)
	await tween.finished
	super.destroy_self_on_timer_timeout()