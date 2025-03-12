extends Panel

@onready var icon = %Icon
@onready var name_text = %NameText
@onready var level_text = %LevelText
@onready var cooldown_progress_bar = %CooldownProgressBar

func initialize(texture: AtlasTexture, name: String, cooldown: float) -> void:
    # Initialize the cooldown panel's icon and name (all should start at level 1) as well as the cooldown progress bar's values
    icon.texture = texture
    name_text.text = name
    level_text = "Level: 1"

    cooldown_progress_bar.max_value = cooldown

func _process(delta: float) -> void:
    # Increase the cooldown progress bar each update til it hits its max value.
    if cooldown_progress_bar.value < cooldown_progress_bar.max_value:
        cooldown_progress_bar.value += clampf(delta, 0, cooldown_progress_bar.max_value)

# Reset the cooldown (typically because the weapon fired.)
func reset_cooldown() -> void:
    cooldown_progress_bar.value = 0