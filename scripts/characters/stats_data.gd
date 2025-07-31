class_name StatsData
extends Resource
## The data resource for holding the base values of character statistics

@export var max_health: float ## The character's maximum health
@export var armor: float ## The character's armor (1.0 = 10% damage reduction)
@export var speed: float ## The character's speed (pixels per second)
@export var phys: float ## The physical skill of the character, used for scaling
@export var mag: float ## The magical skill of the character, used for scaling
