extends Control


var valkyrie_stats = {
	"health": 100,
	"speed": 200.0,
	"armor": 1.0,
}

var tank_stats = {
	"health": 200,
	"speed": 125.0,
	"armor": 5.0,
}

var characters = {
	"Valkyrie": valkyrie_stats,
	"Tank": tank_stats,
}

func init() -> void:
	# Add weapons
	valkyrie_stats.get_or_add("weapon", GameController.light_blade)
	tank_stats.get_or_add("weapon", GameController.slam)

	# Add spritesheest
	valkyrie_stats.get_or_add("spritesheet", preload("res://sprites/frames/valkyrie_sprite_frames.tres"))
	tank_stats.get_or_add("spritesheet", preload("res://sprites/frames/tank_sprite_frames.tres"))
	

func _on_character_select_button_pressed(character :String) -> void:
	# print_debug("Selected " + character)
	GameController.select_character(characters[character])
	
