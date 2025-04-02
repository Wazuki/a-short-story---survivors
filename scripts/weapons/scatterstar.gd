class_name Scatterstar
extends Weapon

const DISORIENT_LEVEL = 2 ## Level at which the Disorient passive unlocks.
const HEALING_LEVEL = 5 ## Level att which the Nano-Infused Shells passive unlocks.
# Data-derived variiables
var shots_per_cooldown: int ## How many shots can be fired before the weapon goes on cooldown.
var disorient_chance: float ## The chance for the weapon to disorient once unlocked.
var disorient_duration: float ## How long a target is disoriented for.
var knockback_strength: float ## The strength of the weapon's knockback
var heal_per_hit: float ## How much is healed per enemy hit by the Nano-Infused Shells passive.

# Internal variables for state tracking.
var scatterstar_bullet
var current_shot = 0



## Initializes the core weapon functions.
func initialize(data: WeaponData) -> void:
	super.initialize(data)
	# Initialize the weapon's specifics.
	shots_per_cooldown = data.shots_per_cooldown
	disorient_chance = data.disorient_chance
	disorient_duration = data.disorient_duration
	knockback_strength = data.knockback_strength
	heal_per_hit = data.heal_per_hit

	scatterstar_bullet = instantiate_bullet_by_key(SceneKey.BULLET, global_position, SpriteConstants.Z_INDEX.SCATTERSTAR)

## Add the bullet as a child now thatt it's in the scene tree.
func _ready() -> void:
	super._ready()
	add_child(scatterstar_bullet)


func _physics_process(_delta: float) -> void:
	if ready_to_fire and not scatterstar_bullet.is_sprite_playing() and closest_enemy != null: shoot()

## Fires the weapon.
func shoot() -> void:
	if current_shot == 0: begin_attack_sequence.emit()
	# Attack sequence: get the closest target.
	current_shot += 1
	# Shoot at it once.
	look_at(closest_enemy.global_position)
	scatterstar_bullet.shoot()
	%ScatterstarSounds.play()

	# At the very end
	if current_shot >= shots_per_cooldown:
		fire_weapon()
		current_shot = 0

## Handles the level up functions for the weapon.
func level_up() -> void:
	super.level_up()
	level += 1
	match level:
		2: # Disorient level unlock.
			pass
		3: # Increased knockback and Disorient chance.
			knockback_strength *= 2
			disorient_chance += 0.25
		4: # Increased disorient duration and cooldown
			disorient_duration += 0.25
			cooldown *= 0.8
		5: # Nano-infused shells
			pass
		6: # Better heal from Nano, better Disorient chance
			heal_per_hit += 1
			disorient_chance += 0.25
		7: # Better disorient chance, heal more from Nano
			heal_per_hit += 1
			disorient_chance = 1.0
	fire_weapon()

# ## Handler for detecting when the particles are finished firing and determine if we should shoot again.
# func _on_scatterstar_particles_finished() -> void:
# 	if current_shot < shots_per_cooldown: shoot()


# Helper functions for determining when level-activated functions should trigger.

## Returns true if the weapon should cause disorientation based on the value and our level.
func cause_disorient() -> bool:
	if disorient_chance >= 1.0: return true
	elif level >= DISORIENT_LEVEL:
		return randf() <= disorient_chance
	return false

## Healers the player on hit if applicable to the weapon's current level and unlocks.
func heal_on_hit() -> bool:
	if level >= HEALING_LEVEL: 
		GameController.player.heal_damage(heal_per_hit)
		return true
	return false
