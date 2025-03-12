extends TextureProgressBar

@onready var timer = %DamageTimer
@onready var health_bar = %HealthBar
@onready var damage_bar = %DamageBar

var health = 0 : set = _set_health
var max_health = 0: set = _set_max_health

func set_textures(background: AtlasTexture, progress: AtlasTexture) -> void:
	# Change the background and progress textures. No need to (currently) change the damage bar textures as it is colored by a shader.
	texture_under = background
	%HealthBar.texture_progress = progress

func _set_max_health(new_max_health) -> void:
	max_health = new_max_health
	health_bar.max_value = max_health
	damage_bar.max_value = max_health

func _set_health(new_health) -> void:
	var prev_health = health
	health = min(max_health, new_health)
	health_bar.value = health

	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health # Reset the damage bar because we are healing instead of taking damage.

func init_health(_health) -> void:
	max_health = _health
	health = max_health

	# Initialize the health and damage bars
	health_bar.max_value = max_health
	health_bar.value = max_health

	damage_bar.max_value = max_health
	damage_bar.value = max_health

	# print_debug("Max health: " + str(max_health) + " Health: " + str(health) + " Input var: " + str(_health))

func _on_damage_timer_timeout() -> void:
	damage_bar.value = health # Catch the damage bar up to the health bar.
