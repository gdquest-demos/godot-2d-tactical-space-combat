tool
extends EditorPlugin


func _enter_tree() -> void:
	var presets := PoolColorArray()
	var presets_raw := PoolStringArray()
	var presets_file := File.new()
	var presets_path: String = '{0}/presets.hex'.format([get_script().get_path().get_base_dir()])
	
	if presets_file.open(presets_path, File.READ) == OK:
		presets_raw = presets_file.get_as_text().split("\n")
		presets_file.close()

		for hex in presets_raw:
			if hex.is_valid_html_color():
				presets.push_back(Color(hex))
		
		get_editor_interface().get_editor_settings().set_project_metadata(
			"color_picker", "presets", presets
		)
