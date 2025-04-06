class_name LevelUpAugment
extends Augment
# LevelUpAugment is a subclass of Augment used to apply level-up effects to the player.

# The level-up UI needs 3 things: an icon, a name, and a description
@export_category("UI Elements")
@export var icon: AtlasTexture ## The icon that will be displayed in the level-up UI
@export var augment_name: String ## The name of the augment.
@export var description: String ## The description of the augment.
