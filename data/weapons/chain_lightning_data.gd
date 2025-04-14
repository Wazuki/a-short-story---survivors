@tool
extends WeaponData

@export_category("Chain Lightning Specifics")
@export var initial_max_chains: int = 2 ## Initial number of times chain lightning can chain
@export var initial_jump_speed: float = 0.125 ## How long it takes each lightning bolt to travel
@export var initial_arc_split_chance: float = 0.25 ## The chance for a lightning bolt to split (Level 5)
@export var lightning_strike_modulus: int = 4 ## The number of chains before a lightning strike is spawned (Level 7)
@export var stun_effect: Stun ## The Stun status effect to apply.

## Chain lightning modifiers dictionary for chain number: chain damage modifier] [int: float]
@export var chain_modifiers = {}


# func _get_property_list() -> Array[Dictionary]:

# 	var properties: Array[Dictionary] = []
# 	properties.append({
# 			name = "chain_modifiers",
# 			type = TYPE_DICTIONARY,
# 			usage = PROPERTY_USAGE_DEFAULT,
# 			hint_string = "Damage modifiers for each chain. The key is the number of chains, and the value is the damage modifier.",
# 			hint = PROPERTY_HINT_DICTIONARY_TYPE
# 	})
# 	return properties