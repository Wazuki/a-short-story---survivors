class_name EnemyDatabase
extends Resource

@export var enemy_data: Array[EnemyStats]
#const ENEMY_DATA_PATH = "res://data/characters/enemies/"

var enemy_stat_dict = {}

## Opens the enemy data array and assigns each enemy to its type in the dictionary.
func initialize() -> void:
	for data in enemy_data:
		if enemy_stat_dict.has(data.get_type()): 
			print_debug("Warning! Duplicate enemy type detected! Skipping " + data.character_name)
		else:
			data.initialize()
			enemy_stat_dict.set(data.get_type(), data)
			#print_debug("Processed " + data.character_name)



# # Open the enemy data folder and assign each enemy to its type in the dictionary.
# func initialize() -> void:
# 	var enemy_dir = DirAccess.open(ENEMY_DATA_PATH)
# 	# Iterate through each file. If it's an EnemyStats file, add it to the enemy stats dictionary.
# 	if enemy_dir: # If the directory exists
# 		enemy_dir.list_dir_begin() # Initialize the list of paths.
# 		var file_name = enemy_dir.get_next() # Capture the next file name.
# 		# While the file name is not blank (e.g., the end of the directory), check if they're a resource. If so, load it into the stat_dict.
# 		while file_name != "":
# 			if file_name.ends_with(".tres"):
# 				var path = ENEMY_DATA_PATH + file_name
# 				var res = load(path)
# 				if res is EnemyStats:
# 					res.initialize()
# 					enemy_stat_dict[res.get_type()] = res
# 			file_name = enemy_dir.get_next()
# 		enemy_dir.list_dir_end()

## Returns the EnemyStats object from the array of enemy types (loaded from the directory)[br]
## See [EnemyStats.EnemyType] for a list of enemy types.
func init_from_type(t: EnemyStats.EnemyType) -> EnemyStats:
	#print_debug("Deploying statblock " + enemy_stat_dict[t].character_name)
	return enemy_stat_dict[t]
