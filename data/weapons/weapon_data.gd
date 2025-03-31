@tool
class_name WeaponData
extends RefCounted


@export_category("Descriptive Elements")
@export var name: String ## The name of the weapon
@export var description: String ## Description of the weapon in the level up gui/progress tracker
@export var icon: AtlasTexture ## The weapon's icon
@export var level_up_texts: Array[String] = [] ## The text for each level up (Max 7)

@export_category("Enumerated Statistics")
@export_enum("SLAM", "LIGHT_BLADE", "WALDOS", "ARROW", "CHAIN_LIGHTNING")
var weapon_type: int ## Type of weapon based on the Weapon Type enum
@export_enum("NONE", "CLOSEST", "HIGHEST_HP", "RANDOM")
var target_type: int ## Type of target based on the TargetType enum

@export_category("Starting Stats")
@export var damage: float ## Starting damage of the weapon
@export var weapon_range: float ## Range of the weapon (its collider)
@export var speed: float ## Starting speed of the weapon - could be attack speed, projectile speed, etc.
@export var cooldown: float ## How often the weapon can attack
@export var crit_chance: float = 0.0 ## The base critical chance of the weapon
@export var crit_mod: float = 0.0 ## The base critical damage modifier of the weapon

@export_category("Scene and Bullet Data")
@export var weapon_scene: PackedScene ## The scene for the weapon
@export var bullet_scene_map: WeaponSceneMap

## Return the level up texts from the weapon data. This is used for the level up GUI.[br]
## Pass in the current level of the weapon NOT the next level. A level zero will return the weapon's description.[br]
## Internally, the text for level [i]n[/i] is at index([i]n[/i]-2).
func get_level_up_text(current_level: int) -> String:
	var display_text = ""
	var new_level = current_level + 1
	if new_level == 1: 
		display_text = description
	elif level_up_texts.size() > 0: 
		display_text = level_up_texts[new_level-2]
	display_text = display_text.replace("\\n", "\n") # Replace the \n with actual new lines
	if not display_text.is_empty(): return display_text
	else:
		print_debug("No level up texts found for weapon: ", name)
		return ""
		