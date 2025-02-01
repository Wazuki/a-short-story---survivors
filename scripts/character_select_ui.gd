extends Control

const TANK_UNLOCK_VAL = 5000
const HUNTRESS_UNLOCK_VAL = 1000
const TECHNICIAN_UNLOCK_VAL = 10000

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

var technician_stats = {
	"health": 150,
	"speed": 110.0,
	"armor": 3.0,
}

var characters = {
	"Valkyrie": valkyrie_stats,
	"Tank": tank_stats,
	"Huntress": huntress_stats,
	"Technician": technician_stats,
}

#var total_enemies_killed: int = 0
#var total_xp_gained: int = 0
#var total_damage_done: float = 0.0

func init() -> void:
	# Add weapons
	valkyrie_stats.get_or_add("weapon", GameController.light_blade)
	tank_stats.get_or_add("weapon", GameController.slam)
	huntress_stats.get_or_add("weapon", GameController.arrow)
	technician_stats.get_or_add("weapon", GameController.waldos)

	# Add spritesheest
	valkyrie_stats.get_or_add("spritesheet", preload("res://sprites/frames/valkyrie_sprite_frames.tres"))
	tank_stats.get_or_add("spritesheet", preload("res://sprites/frames/tank_sprite_frames.tres"))
	huntress_stats.get_or_add("spritesheet", preload("res://sprites/frames/huntress_sprite_frames.tres"))
	technician_stats.get_or_add("spritesheet", preload("res://sprites/frames/technician_sprite_frames.tres"))

	# Add unlock requirement UI elements
	tank_stats.get_or_add("unlock_reqs", {
		GameController.total_xp_gained: TANK_UNLOCK_VAL,
	})
	tank_stats.get_or_add("LockPanel", %LockPanel_Tank)
	tank_stats.get_or_add("ReqText", %RequirementsText_Tank)
	tank_stats.get_or_add("unlock_text_val", "ACQUIRE %s/" + str(tank_stats.unlock_reqs.values()[0]) + " KNOWLEDGE")

	huntress_stats.get_or_add("unlock_reqs", {
		GameController.total_enemies_killed: HUNTRESS_UNLOCK_VAL,
	})
	huntress_stats.get_or_add("LockPanel", %LockPanel_Huntress)
	huntress_stats.get_or_add("ReqText", %RequirementsText_Huntress)
	huntress_stats.get_or_add("unlock_text_val", "ELIMINATE %s/" + str(huntress_stats.unlock_reqs.values()[0]) + " FOES")

	technician_stats.get_or_add("unlock_reqs", {
		GameController.total_damage_done: TECHNICIAN_UNLOCK_VAL,
	})
	technician_stats.get_or_add("LockPanel", %LockPanel_Technician)
	technician_stats.get_or_add("ReqText", %RequirementsText_Technician)
	technician_stats.get_or_add("unlock_text_val", "ADMINISTER %s/" + str(technician_stats.unlock_reqs.values()[0]) + " WOUNDS")

	check_unlock_requiremets()
	

func _on_character_select_button_pressed(character :String) -> void:
	# print_debug("Selected " + character)
	GameController.select_character(characters[character])
	
func check_unlock_requiremets() -> void:
	# Check if the player has unlocked any characters
	for c in characters:
		if characters[c].has("unlock_reqs"):
			# Update the unlock requirements values before checking them.
			update_unlock_var(c)

			# print_debug(str(characters[c]["unlock_reqs"]))
			var unlock_var = characters[c]["unlock_reqs"].keys()[0]
			var unlock_threshold = characters[c]["unlock_reqs"].values()[0]
			# print_debug("Req: " + str(unlock_var), "Value: " + str(characters[c]["unlock_reqs"].values()[0]))
			if unlock_var >= unlock_threshold:
				# Unlock character
				characters[c]["LockPanel"].visible = false
			else: 
				var unlock_text:String = "[p align=center]"
				unlock_text += characters[c]["unlock_text_val"]
				# characters[c]["ReqText"].text = unlock_text.format({"{0}": str(unlock_var)})
				characters[c]["ReqText"].text = unlock_text % str(roundi(unlock_var))

func update_unlock_var(character: String) -> void:
	var val
	var threshold_val = characters[character]["unlock_reqs"].values()[0]
	# var threshold_val 
	match character:
		# Append a new key to the new value, then erase the old key
		"Tank":
			val = GameController.total_xp_gained
			# print_debug(character + ": " + str(characters["Tank"]["unlock_reqs"].keys()[0]))
		"Huntress":
			val = GameController.total_enemies_killed
		"Technician":
			val = GameController.total_damage_done	
	characters[character]["unlock_reqs"].clear()
	characters[character]["unlock_reqs"][val] = threshold_val		