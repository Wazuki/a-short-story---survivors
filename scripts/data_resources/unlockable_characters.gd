extends Resource
class_name Unlockable_Characters

# A list of unlockable characters in the game

var valkyrie: Character
var tank: Character 
var huntress: Character
var technician: Character

# Name, Health, Armor, Speed, Starting Weapon,  Unlock Variable, Unlock Var Value for new characters
func _init() -> void:
	valkyrie = Character.new()
	tank = Character.new()
	huntress = Character.new()
	technician = Character.new()

	valkyrie.set_stats("Valkyrie", 100, 1.0, 150, Weapon.Type.LIGHT_BLADE) # Default character unlock
	tank.set_stats("Tank", 200, 5.0, 100, Weapon.Type.SLAM, TrackedVariables.Type.XP, 5000) # Tank needs 5000 XP to unlock
	huntress.set_stats("Huntress", 75, 0.1, 200, Weapon.Type.ARROW, TrackedVariables.Type.KILLS, 1000) # Huntress requires 1000 enemies killed
	technician.set_stats("Technician", 150, 3.0, 110, Weapon.Type.WALDOS, TrackedVariables.Type.DAMAGE, 10000) # Technician requires 10000 damage dealt
	
	load_textures()
	load_text()

func load_textures() -> void:
	# Spritesheets
	valkyrie.spritesheet = preload("res://sprites/frames/valkyrie_sprite_frames.tres")
	tank.spritesheet = preload("res://sprites/frames/tank_sprite_frames.tres")
	huntress.spritesheet = preload("res://sprites/frames/huntress_sprite_frames.tres")
	technician.spritesheet = preload("res://sprites/frames/technician_sprite_frames.tres")

	# Icons
	valkyrie.icon = preload("res://sprites/frames/valkyrie_icon.tres")
	tank.icon = preload("res://sprites/frames/tank_icon.tres")
	huntress.icon = preload("res://sprites/frames/huntress_icon.tres")
	technician.icon = preload("res://sprites/frames/technician_icon.tres")

func load_text() -> void:
	# Style guide: Each character desc should be four lines and start with "A.." and end with a line break.
	valkyrie.description = "An arranged marriage.\nA duel to the death.\nA blade of immense power.\nA new purpose.\n"
	tank.description = "TBD"
	huntress.description = "A bow of both worlds.\nTBD"
	technician.description = "A transhumanist cult.\nA dark secret discovered.\nA mass slaughter.\nA seach for redemption."


# Returns all the unlockable characters
func get_all_chars() -> Array[Character]:
	var chars: Array[Character]

	chars.append(valkyrie)
	chars.append(tank)
	chars.append(huntress)
	chars.append(technician)

	return chars
