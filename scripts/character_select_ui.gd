extends Control


var valkyrie_stats = {
	"health": 100,
	"speed": 150.0,
	"armor": 1.0,
}

var tank_stats = {
	"health": 200,
	"speed": 100.0,
	"armor": 5.0,
}

var huntress_stats = {
	"health": 75,
	"speed": 200.0,
	"armor": 0.1,
}

var characters = {
	"Valkyrie": valkyrie_stats,
	"Tank": tank_stats,
	"Huntress": huntress_stats,
}

func init() -> void:
	# Add weapons
	valkyrie_stats.get_or_add("weapon", GameController.light_blade)
	tank_stats.get_or_add("weapon", GameController.slam)
	huntress_stats.get_or_add("weapon", GameController.arrow)

	# Add spritesheest
	valkyrie_stats.get_or_add("spritesheet", preload("res://sprites/frames/valkyrie_sprite_frames.tres"))
	tank_stats.get_or_add("spritesheet", preload("res://sprites/frames/tank_sprite_frames.tres"))
	huntress_stats.get_or_add("spritesheet", preload("res://sprites/frames/huntress_sprite_frames.tres"))
	

func _on_character_select_button_pressed(character :String) -> void:
	# print_debug("Selected " + character)
	GameController.select_character(characters[character])
	
