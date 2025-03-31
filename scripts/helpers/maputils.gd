class_name MapUtils


static func is_point_on_tilemap(tile_map_layer: TileMapLayer, pos: Vector2) -> bool:
	
	var map_pos = tile_map_layer.local_to_map(pos)
	var cell = tile_map_layer.get_cell_tile_data(map_pos)
	# print_debug("Cell: " + str(cell))
	return cell == null # If the cell is null we're off the map - return true, go back to the loop, and try again.
	# return false # We want this to return false in the end because the loop will run until we find a cell that is ON the map. True continues the loop!
