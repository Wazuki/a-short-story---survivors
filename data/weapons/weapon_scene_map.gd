class_name WeaponSceneMap
extends Resource

## Scene definitions (human-readable fields mapped to enum internally)
@export var bullet_scene: BulletData
@export var secondary_bullet_scene: BulletData
@export var impact_effect_scene: BulletData
@export var trail_effect_scene: BulletData

## Optional helper to return the dictionary if needed
func to_dict() -> Dictionary:
	return {
		WeaponEnums.SceneKey.BULLET: bullet_scene,
		WeaponEnums.SceneKey.SECONDARY_BULLET: secondary_bullet_scene,
		WeaponEnums.SceneKey.IMPACT_EFFECT: impact_effect_scene,
		WeaponEnums.SceneKey.TRAIL_EFFECT: trail_effect_scene,
	}