class_name StatusEffect
extends  Resource
# Base class for status effects to apply to character and enemy alike.

@export var duration: float ## The duration of the atstus effect.
@export var intensity: float ## How intense the status effect is (varied based on the type of status effect)

## Initialize the values of the status effect.[br]
## [param time] is [duration], [param magnitude] is [intensity] of effect
func _init(time: float = 0, magnitude: float = 0) -> void:
	duration = time
	intensity = magnitude

## Copies the effects of another effect onto the new effect.
func copy(other: StatusEffect) -> void:
	duration = other.duration
	intensity = other.intensity

# ## Initialize the values of the status effect.[br]
# ## [param time] is [duration], [param magnitude] is [intensity] of effect
# func initialize(time: float, magnitude: float) -> void:
# 	duration = time
# 	intensity = magnitude

func apply(_target) -> void: pass

## Updates the duration for the effect. If the effect has now ended, returns true. Else returns false.
func update(delta: float) -> bool:
	duration -= delta
	if duration <= 0: return true
	return false

## TODO - used for cleansing effects?
func remove(_target) -> void:
	#free()
	pass
	#call_deferred("queue_free")
