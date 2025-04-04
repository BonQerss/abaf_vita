extends Node2D

export var apply_scale_from_json: bool = true
export var import_data_path: String = "res://Sprites/godot_import_data.json" # Adjust the path

func _ready():
	if apply_scale_from_json:
		var file = File.new()
		if file.open(import_data_path, File.READ) == OK:
			var json_text = file.get_as_text()
			file.close()
			
			var parse_result = JSON.parse(json_text)
			if typeof(parse_result.result) == TYPE_DICTIONARY:
				var import_data = parse_result.result
				
				for node in get_tree().get_nodes_in_group("scalable_textures"):
					if node is Sprite and node.texture:
						var texture_name = node.texture.get_path().get_file()
						var folder_name = node.texture.get_path().get_base_dir().get_file()
						
						if import_data.has(folder_name) and import_data[folder_name].has(texture_name):
							var scale_x = import_data[folder_name][texture_name]["godot_scale_x"]
							var scale_y = import_data[folder_name][texture_name]["godot_scale_y"]
							node.scale = Vector2(scale_x, scale_y)
						else:
							printerr("Warning: Scale data not found for texture:", texture_name, " in folder:", folder_name)
			else:
				printerr("Error: Failed to parse JSON file:", import_data_path)
		else:
			printerr("Error: Could not open import data file:", import_data_path)
