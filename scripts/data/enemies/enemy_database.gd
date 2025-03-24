class_name EnemyDatabase
extends Resource


var enemy_stat_dict = {}

# Open the enemy data folder and assign each enemy to its type in the dictionary.
func initialize() -> void:
	var enemy_dir = DirAccess.open("res://scripts/data/enemies/")
	# Iterate through each file. If it's an EnemyStats file, add it to the enemy stats dictionary.
	if enemy_dir: # If the directory exists
		enemy_dir.list_dir_begin() # Initialize the list of paths.
		var file_name = enemy_dir.get_next() # Capture the next file name.
		# While the file name is not blank (e.g., the end of the directory), check if they're a resource. If so, load it into the stat_dict.
		while file_name != "":
			if file_name.ends_with(".tres"):
				var path = "res://scripts/data/enemies/" + file_name
				var res = load(path)
				if res is EnemyStats:
					res.initialize()
					enemy_stat_dict[res.get_type()] = res
			file_name = enemy_dir.get_next()
		enemy_dir.list_dir_end()

## Returns the EnemyStats object from the array of enemy types (loaded from the directory)[br]
## See [EnemyStats.EnemyType] for a list of enemy types.
func init_from_type(t: EnemyStats.EnemyType) -> EnemyStats:
	return enemy_stat_dict[t]
