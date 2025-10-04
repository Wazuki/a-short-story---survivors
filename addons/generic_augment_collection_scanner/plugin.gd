@tool
extends EditorPlugin

var plugin

func _enter_tree() -> void:
	# Initialize the plugin and add it to the editor. Preload the script and create a new instance (using .new() because this is not a packed scene.)
	plugin = preload("res://addons/generic_augment_collection_scanner/generic_augment_collection_scanner.gd").new()
	add_inspector_plugin(plugin)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_inspector_plugin(plugin) # Remove the plugin from the inspector when the editor exits.
