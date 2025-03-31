## Base class for things the player might acquire that need a physical representation in game[br]
## [b]Examples:[/b] Experience, health, in-game items or collectibles
class_name Pickup
extends Area2D

# enum EFFECT { EXPERIENCE, HEALTH }
# var effect: EFFECT

var value
var move_on_spawn = true

## Sets up the initial settings for every pickup. Monitoring is true to check for walls, set the layer to the sprite pickup layer.
func _ready() -> void:
    monitoring = true
    monitorable = true
    collision_layer = SpriteConstants.COLLISION_LAYERS.PICKUPS
    # Connect the signals for detecting walls. Player handles pickup detection to reduce overhead.
    connect("body_entered", _on_body_entered)

    # This line converts the collision_layer propery to the actual bit-mask (binary) value
	# print("Collision Layer: " + String.num_int64(collision_layer))


## Applies the pickup to the player. Should be overriden by any derived classes.
func apply_pickup_to_player(_player: Player) -> void:
    # This hasn't tripped so it might make this class "abstract" in a way, but maybe not a good idea? 
    assert(false, "Must override apply_pickup_to_player(player: Player) in subclass")


## Signals when we strike an obstacle that isn't the player.
func _on_body_entered(_body: Node2D) -> void:
    move_on_spawn = false
    disable_monitoring()

## Disables collision monitoring as deferred since it's blocked during collision (when we need to disable it)
func disable_monitoring() -> void: set_deferred("monitoring", false)