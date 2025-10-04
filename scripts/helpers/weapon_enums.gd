class_name  WeaponEnums
extends RefCounted

# Handles all the enumerations for weapons.
enum SceneKey { PROJECTILE, SECONDARY_PROJECTILE, IMPACT_EFFECT, TRAIL_EFFECT }
enum Type { SLAM, LIGHT_BLADE, WALDOS, ARROW, CHAIN_LIGHTNING, HAILFIRE, SCATTERSTAR, BLACK_HOLE }
enum TargetType { NONE, CLOSEST, HIGHEST_HP, RANDOM, CONTINUOUS, BIGGEST_CLUSTER }

## Defines tags that describe the weapon's characteristics, as well as what upgrades it can receive from the random pool.
## Tags are internally defined in categories:[br]
## [b]Delivery:[/b] melee, projectile, orbital, aura, summon [br]
## [b]Effect Type:[/b] burst, dot, pierce, bounce, knockback[br]
## [b]Speed:[/b] slow_fire, rapid_fire, ramp_up[br]
## [b]Target:[/b] single_target, multi_target, aoe[br]
## [b]Scaling Type:[/b] phys, mag, hybrid[br]
enum Tag {
	ANY, # Used for generic augments that can apply to any weapon.
	MELEE, PROJECTILE, ORBITAL, AURA, SUMMON,
	BURST, DOT, PIERCE, BOUNCE, KNOCKBACK,
	SLOW_FIRE, RAPID_FIRE, RAMP_UP,
	SINGLE_TARGET, MULTI_TARGET, AOE,
	PHYS, MAG, HYBRID
}

# Other options for tags could include: crit_focus, status_focus, chain, shield/armor/health scaling, homing/retargets