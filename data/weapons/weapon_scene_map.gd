class_name WeaponSceneMap
extends Resource

## Scene definitions (human-readable fields mapped to enum internally)
@export var projectile_scene: ProjectileData
@export var seconday_projectile_scene: ProjectileData
@export var impact_effect_scene: ProjectileData
@export var trail_effect_scene: ProjectileData

## Optional helper to return the dictionary if needed
func to_dict() -> Dictionary:
	return {
		WeaponEnums.SceneKey.PROJECTILE: projectile_scene,
		WeaponEnums.SceneKey.SECONDARY_PROJECTILE: seconday_projectile_scene,
		WeaponEnums.SceneKey.IMPACT_EFFECT: impact_effect_scene,
		WeaponEnums.SceneKey.TRAIL_EFFECT: trail_effect_scene,
	}