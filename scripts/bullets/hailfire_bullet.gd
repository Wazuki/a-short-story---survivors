class_name HailfireBullet
extends Bullet

const BOUNCE_VARIANCE = 30.0

# Hailfire Bullet Specifics
var pierce: int = 0
var bounces: int = 0
# Movement variables
var target_pos: Vector2
var direction: Vector2
var traveled_distance: float
var max_distance: float

## Initialize the bullet based on 
func initialize(spawning_weapon: Weapon, data: BulletData, spawn_pos: Vector2, sprite_z_index: int, target: Node2D = null) -> void:
	super.initialize(spawning_weapon, data, spawn_pos, sprite_z_index, target)
	pierce = weapon.get_pierce_amount()
	bounces = weapon.get_bounce_amount()
	max_distance = weapon.max_range
	# If we currently don't have a valid target, keep shooting in the direction of our last target.
	if target: target_pos = target.global_position
	else: target_pos = weapon.last_target_pos

func _ready() -> void:
	super._ready()
	# Look at our target's position and get our direction heading.
	look_at(target_pos)
	direction = global_position.direction_to(target_pos)

## Rotate the bullet based on the spread angle [variance: float], then rotate the direction by [Vector2.RIGHT.rotated(rotation)] to caculate the angle properly.[br]
## Requires [Vector2.RIGHT.rotated()] because Godot treats facing Right (+x) as zero deg/rad.
func apply_firing_angle_variance(variance: float) -> void:
	rotation_degrees += variance
	direction = Vector2.RIGHT.rotated(rotation)

## Animate the bullet.
func _physics_process(delta: float) -> void:
	# Move towards our target based on our own speed. Calculate how far we've traveled.
	position += direction * speed * delta
	traveled_distance += speed * delta
	# If we've traveled further than our max range, destroy ourself.
	if traveled_distance >= max_distance: call_deferred("queue_free")

## Checks to see if we have exceeded our pierce count and, if we have, queue free
func check_pierce_count() -> void:
	if pierce <= 0: 
		call_deferred("queue_free")
		# print_debug("Hailfire bullet queued for deletion.")

## Sets the attack sound to autoplay upon entering the scene tree.
func play_attack_sound() -> void: %HailfireSounds.autoplay = true

## Bounce the bullet off the target if possible.
func bounce_off(target: Node2D) -> void:
	#print_debug("Bounce!")
	var normal = (target.global_position - global_position).normalized()
	direction = direction.bounce(normal).normalized()
	direction = direction.rotated(deg_to_rad((randf_range(-BOUNCE_VARIANCE, BOUNCE_VARIANCE))))
	#apply_firing_angle_variance(randf_range(-BOUNCE_VARIANCE, BOUNCE_VARIANCE)) # Appply a bit of variance to the bounce so they don't directly reflect off the target.
	rotation = direction.angle()
	bounces -= 1

## Deal damage to the target (if it's a valid instance). Then check for pierce and bounces.
func _on_area_entered(area:Area2D) -> void:
	# Check to make sure we don't have this enemy in our effected area's to prevent accidentally damaging the same enemy twice.
	if affected_areas.has(area.get_instance_id()): return
 	# Call to the base Bullet which will automatically calculate our damage.
	weapon.knockback_status.set_origin(global_position) # Set the knockback's origin to our pos so it applies correctly.
	damage_target(area, weapon.knockback_status) # Also pass in the knockback status from the weapon to apply knockback.
	affected_areas.set(area.get_instance_id(), area)
	# Then check for bouncing. We should only check for piecing if we don't have any bounces left.
	if bounces > 0:
		bounce_off(area)
	else: check_pierce_count()
	
## After passing through a body, count it as pierced and then destroy self if we've exceeded our pierce quantity.
func _on_area_exited(area:Area2D) -> void:
	if affected_areas.has(area.get_instance_id()): return
	#if bounces > 0: bounces -= 1 # Reduce the bounce count on exiting, not on the bounce_off, due to the exit triggering an early destruction of the bullet.
	if bounces <= 0:
		pierce -= 1
		check_pierce_count()
