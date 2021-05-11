tool
extends EditorPlugin


func _enter_tree() -> void:
	var presets_file := File.new()
	if presets_file.open("res://presets.hex", File.READ) == OK:
		var presets := PoolColorArray()
		for hex in presets_file.get_as_text().split("\n"):
			if not hex.empty():
				presets.push_back(Color(hex))
		get_editor_interface().get_editor_settings().set_project_metadata(
			"color_picker", "presets", presets
		)
	presets_file.close()
