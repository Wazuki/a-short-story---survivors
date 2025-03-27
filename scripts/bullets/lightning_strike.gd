class_name LightningStrike extends Bullet

const SPAWN_RADIUS_VARIANCE = 0.8 ## Determines how much of the collider we consider when spawning a strike.

## How often we deal damage.
var damage_cooldown = 0.5
var damage_timer = 0.0

## Spawns a lightning strike at target Vector2.[br]
## [b]Required:[/b] [code]damage: float, spawn_position: Vector2, lifetime: float, damage_cooldown:float[/code]
func initialize_strike(spawning_weapon: Weapon, spawn_pos: Vector2, strike_lifetime: float, dmg_cooldown: float) -> void:
	# Call the super constructors to initialize these vars
	# Will automatically set up the timer and kill the aoe after the duration because we set lifetime dependent to true.
	super.initialize(spawning_weapon, spawn_pos, SpriteConstants.Z_INDEX.LIGHTNING_STRIKE, null, strike_lifetime, true)
	#(spawning_weapon: Weapon, pos: Vector2, sprite_z_index: int, target: Node2D = null, projectile_lifetime: float = 0.0, is_lifetime_dependent = false)
	# Set the damage timer (handles when we deal damage) and the cooldown (reset value for damage_timer)
	damage_cooldown = dmg_cooldown
	damage_timer = damage_cooldown


# Called when it enters the scene tree.
func _ready() -> void:
	super._ready()
	name = "Lightning Strike" # Part of a node so belongs in ready.

	# This has to be done HERE because _init only handles data, this is scene tree work.
	# When spawning, we don't automatically trigger _on_body_entered() for bodies we start overlapping.
	# Call get_overlapping_bodies() manually and assign it to the affected_bodies array if it isn't empty. Then deal damage.
	if not get_overlapping_areas().is_empty():
		affected_areas = get_overlapping_areas()
	# Immediately deal damage on spawn - this will also trigger the timer.
	deal_damage_to_affected_areas()


# Deal damage based on an internally-tracked cooldown.
func _physics_process(delta: float) -> void:
	damage_timer -= delta
	if damage_timer <= 0:
		deal_damage_to_affected_areas()

## Deal damage to any affected bodies based on the array.
## Reset the cooldown after dealing  damage.
func deal_damage_to_affected_areas() -> void:
	if not affected_areas.is_empty():
		for e in affected_areas:
			var enemy = e as Enemy
			enemy.take_damage(damage)
		# print_debug(name + " dealt damage to " + str(affected_bodies.size()) + " enemies!")
	damage_timer = damage_cooldown

##[b]Spawn Radius Check[/b][br]
## Checks to see if we are able to spawn a damage field based on half the collider radius[br]
##[b]Parameters:[/b] [code]position: Vector2, tree: SceneTree[/code]
static func can_spawn_strike_at_pos(pos: Vector2, tree: SceneTree) -> bool:
	if tree.get_node_count_in_group("Lightning Strikes") > 0:
		for strike in tree.get_nodes_in_group("Lightning Strikes"):
			if strike.global_position.distance_to(pos) < strike.get_damage_radius() * SPAWN_RADIUS_VARIANCE:
				return false
	return true

func get_damage_radius() -> float: return %DamageArea.shape.radius

# Add the enemy to the affected_bodies array so we can damage them on cooldown.
func _on_area_entered(area:Node2D) -> void: affected_areas.append(area)

# Remove the enemy from the affected_bodies array when they leave the area
func _on_area_exited(area:Node2D) -> void: affected_areas.erase(area)
