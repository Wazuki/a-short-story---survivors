extends Resource
class_name SpriteConstants ## Tracks the sprite

#Be kind to yourself future me.
## For ordering sprites on the Ordering -> z_index proprety. Sprite layering. [br]
## Remember[code]z_as_relative[/code] should be set to [i]false[/i] because it adds the parent's z-index to ours.
enum Z_INDEX { 
    TERRAIN = -99, 
    LIGHTNING_STRIKE = 5,
    SLAM = 10,
    WALDOS = 20,
    INNER_WALDOS = 21,
    EXPERIENCE = 30,
    HEALTH_PICKUP = 35,
    LIGHT_BLADE = 60,
    CHAIN_LIGHTNING = 80,
    PLAYER = 100,
    ENEMY = 100, 
    ARROW = 150,
    }

## Collision layers use bit-masks, not integers.[br]
enum COLLISION_LAYERS {
    PLAYER = 000001,
    ENEMY = 000010,
    ENEMY_AVOIDANCE = 000100,
    PICKUPS = 001000
}