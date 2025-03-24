extends Area2D

var max_range: float
var traveled_distance: float = 0
var direction
var speed: float
var damage: float
var pierce: int
var total_pierced: int = 0
var splittable: bool = false


func initialize(dmg: float, spd: float, rng: float, prc: int) -> void:
	damage = dmg
	speed = spd
	max_range = rng
	pierce = prc

func _physics_process(delta: float) -> void:
	direction = Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta
	
	traveled_distance += speed * delta
	
	if traveled_distance >= max_range:
		queue_free() # destroy the bulle if itt goes past its max range


func _on_area_entered(area:Node2D) -> void:
	if area != null and area is Enemy:
		if not area.dead: # If we're using masks property, it should ONLY be an enemy!
			damage = GameController.arrow.damage_calc() ## TODO - move this to Arrow maybe? we're intiializing it anyway here
			area.take_damage(damage)

			if area.dead && splittable:
				splittable = false
				GameController.arrow.spawn_split_arrows(global_position)

			total_pierced += 1
			if total_pierced >= pierce:
				queue_free()


func _on_area_exited(_area:Node2D) -> void:
	if total_pierced >= pierce:
		queue_free()
