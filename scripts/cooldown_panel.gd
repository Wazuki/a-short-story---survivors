extends Panel

# Onready only calls when it is *added to the scene tree*
# @onready var icon = $Icon
# @onready var name_text = %NameText
# @onready var level_text = %LevelText
# @onready var cooldown_progress_bar = %CooldownProgressBar

func initialize(texture: AtlasTexture, weapon_name: String, cooldown: float) -> void:
	# Initialize the cooldown panel's icon and name (all should start at level 1) as well as the cooldown progress bar's values
	%Icon.texture = texture
	%NameText.text = weapon_name
	%LevelText.text = "Level: 1"

	%CooldownProgressBar.max_value = cooldown
	%CooldownProgressBar.value = 0.0

func _process(delta: float) -> void:
	# Increase the cooldown progress bar each update til it hits its max value.
	if %CooldownProgressBar.value < %CooldownProgressBar.max_value:
		%CooldownProgressBar.value += clampf(delta, 0, %CooldownProgressBar.max_value)

# Reset the cooldown (typically because the weapon fired.)
func reset_cooldown() -> void:
	if %FiringText.visible:
		%FiringText.visible = false
		%CooldownProgressBar.visible = true
	%CooldownProgressBar.value = 0

func begin_attack_sequence() -> void:
	%CooldownProgressBar.visible = false
	%FiringText.visible = true

func update_level_text(level: int) -> void: %LevelText.text = "Level: " + str(level)
