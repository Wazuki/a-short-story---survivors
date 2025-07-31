class_name Stats
extends Object
## Node and class to handle a character's stats via components

var max_health: float ## The character's maximum health
var health: float ## The character's current health
var armor: float ## The character's armor (1.0 = 10% damage reduction)
var speed: float ## The character's speed (pixels per second)
var base_speed: float ## The base speed of the character - used for reseting speed after reduction
var phys: float ## The physical skill of the character, used for scaling
var mag: float ## The magical skill of the character, used for scaling

signal damaged(damage: float)
signal defeated

## Initialize the character stats based on a [param data:CharacterData] object
func _init(data: StatsData) -> void:
	max_health = data.max_health
	health = max_health
	armor = data.armor
	speed = data.speed
	base_speed = speed
	phys = data.phys
	mag = data.mag

## Apply [param amount] damage to the target, reduced by [armor] where 1.0 = 10% damage reduction
func apply_damage(amount: float) -> void:
	var effective_damage = max(amount * (1.0 - damage_reduction()), 0) # Reduces the damage by the armor, hopefully extendable for future damage reduction implementations.

	health = clampf(health - effective_damage, 0, max_health)
	
	damaged.emit(amount) # Emit the damaged signal to tell listners we took damage.

	# Emit the dead signal so our owner knows that we have been defeated
	if is_dead(): defeated.emit()

func reset_speed() -> void: speed = base_speed

## Apply [param amount] healing to the clamped by [max_health]
func heal(amount: float) -> void:
	health = clampf(health + amount, 0, max_health)

## Returns if the target is dead or not based on their health.
func is_dead() -> bool: return health <= 0

## Calculates the effective damage reduction of armor, where 1.0 = 10% damage reduction (so 10.0 armor = 100% DR) [br]
## Extendable for future implementations hopefully
func damage_reduction() -> float:
	return armor / 10.0