class_name WeaponData
extends RefCounted

# Data class that holds data for each weapon. Should be derived only.


enum Type { SLAM, LIGHT_BLADE, WALDOS, ARROW, CHAIN_LIGHTNING}
enum TargetType { NONE, CLOSEST, HIGHEST_HP, RANDOM }

@export_category("Descriptive Elements")
@export_enum("SLAM", "LIGHT_BLADE", "WALDOS", "ARROW", "CHAIN_LIGHTNING")
var weapon_type: int
@export var description: String
@export var icon: AtlasTexture
@export var level_up_texts: Array[String] = []


@export_category("Starting Stats")
@export var damage: float
@export var speed: float
@export var cooldown: float
@export var crit_chance: float = 0.0
@export var crit_mod: float = 0.0

