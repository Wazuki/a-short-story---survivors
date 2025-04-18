extends Projectile

var max_range: float
var traveled_distance: float = 0
var direction
#var speed: float
#var damage: float
var pierce: int
var total_pierced: int = 0
var splittable: bool = false

func initialize(spawning_weapon: Weapon, data: ProjectileData, spawn_pos: Vector2, sprite_z_index: int, target: Node2D = null) -> void:
	super.initialize(spawning_weapon, data, spawn_pos, sprite_z_index, target)
	# Arrow-specific attributes
	max_range = spawning_weapon.max_range
	pierce = spawning_weapon.pierce
	if target: # Only set these if we have a direct target, otherwise our other script will do it automatically.
		direction = global_position.direction_to(target.global_position)
		look_at(target.global_position)

func set_arrow_angle(degrees: float) -> void: 
	rotation_degrees = degrees
	direction = Vector2.RIGHT.rotated(rotation) # Rotates the direction vector based on our rotation (0 for main arrows, variable for others)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
	traveled_distance += speed * delta
	
	if traveled_distance >= max_range:
		queue_free() # destroy the bulle if itt goes past its max range


func _on_area_entered(area:Node2D) -> void:
	#print_debug("Hit " + str(area.name))
	if area != null and area is Enemy:
		if not area.dead: # If we're using masks property, it should ONLY be an enemy!
			#damage = weapon.damage_calc() ## TODO - move this to Arrow maybe? we're intiializing it anyway here
			#area.take_damage(damage)
			damage_target(area)

			if area.dead && splittable:
				splittable = false
				weapon.spawn_split_arrows(global_position)

			total_pierced += 1
			if total_pierced >= pierce:
				queue_free()


func _on_area_exited(_area:Node2D) -> void:
	if total_pierced >= pierce:
		queue_free()
