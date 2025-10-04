@tool
extends EditorInspectorPlugin

var dir:String = ""

func _can_handle(object: Object) -> bool:
	return object is GenericAugmentCollection

func _parse_begin(object: Object) -> void:
	# Add a repopulate button to the inspector.
	var button = Button.new()
	button.text = "Repopulate"
	button.pressed.connect(_on_repopulate_pressed)
	add_custom_control(button)

func _on_repopulate_pressed() -> void:
	print_debug("Repopulate button pressed")
	# If the directory is not set, prompt the user to select one.
	if dir == "":
		print_debug("No directory set, prompting user")
		var file_dialog = EditorFileDialog.new()
		file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
		file_dialog.title = "Select Generic Augment Directory"
		file_dialog.filters = ["*"]
		file_dialog.current_path = "res://"
		file_dialog.dir_selected.connect(_repopulate)
		EditorInterface.get_base_control().add_child(file_dialog)
		file_dialog.popup_file_dialog()
	else:
		print_debug("Directory already set, repopulating")
		_repopulate(dir)

	# if dir == "":
	# 	print_debug("No directory set, opening file dialog")
	# 	var file_dialog = FileDialog.new()
	# 	file_dialog.mode = FileDialog.FILE_MODE_OPEN_DIR
	# 	file_dialog.title = "Select Generic Augment Directory"
	# 	file_dialog.filters = ["*"]
	# 	file_dialog.current_path = "res://"
	# 	file_dialog.popup_centered()
	# 	file_dialog.dir_selected.connect(self._repopulate)
	# 	file_dialog.show()
	# else:
	# 	_repopulate(dir)

## Scans the specified directory for GenericAugment files and repopulates the collection.
func _repopulate(path) -> void:
	
	# Check if the path is empty. If so, we use the current directory emitted by the file dialog.
	if dir == "":
		dir = path
		print_debug("Selected directory: %s" % dir)
	else:
		print_debug("Repopulating from directory: %s" % dir)

	var dir_access = DirAccess.open(dir)

	# If, for some reason, we can't access the directory, we log a warning and return after resetting the directory.
	if dir_access == null: 
		push_warning("Error opening directory: {0}".format(dir))
		dir = ""
		return

	var files = dir_access.get_files()
	# If there are no files in the directory, we log a warning and reset the directory.
	if files.size() == 0: 
		push_warning("No files found in directory: {0}".format(dir))
		dir = ""
		return

	var augment_collection = GenericAugmentCollection.new()
	for file in files:
		if file.get_extension() == "tres":
			print_debug("Loading augment from file: %s" % file)
			augment_collection.collection.append(load(dir + "/" + file) as GenericAugment)

	print_debug("Loaded %d augments from directory: %s" % [augment_collection.collection.size(), dir])

	var collection = EditorInterface.get_inspector().get_edited_object() as GenericAugmentCollection
	if collection:
		collection.collection = augment_collection.collection
		print_debug("Updated collection in inspector with %d augments" % collection.collection.size())
	else:
		push_warning("No collection found in inspector to update.")