extends Control

@onready var health_bar := %HPProgressBar ## Reference to the health bar node, a TextureProgressBar
@onready var xp_bar := %XPProgressBar ## Reference to the XP bar node, a TextureProgressBar
@onready var level_label := %LevelLabel ## Reference to the level label node, a RichTextLabel

func _ready() -> void:
	# Connect signals to the UI
	Events.ui_update_hp.connect(_on_player_health_changed)
	Events.ui_update_xp.connect(_on_player_gained_xp)
	Events.ui_update_level.connect(_on_player_gained_level)

func _on_player_health_changed(current_hp: float, max_hp: float) -> void:
	health_bar.value = current_hp / max_hp


func _on_player_gained_xp(xp: float, tnl: float) -> void:
	xp_bar.value = xp/tnl

func _on_player_gained_level(level: int) -> void:
	level_label.text = "Level: " + str(level)