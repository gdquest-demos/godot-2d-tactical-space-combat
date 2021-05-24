extends Node

enum Layers { NONE }

var winner_is_player := false


func _ready() -> void:
	var label := 'layer_names/2d_physics/layer_%d'
	for i in range(1, 21):
		var layer_name: String = ProjectSettings.get_setting(label % i)
		if layer_name != '':
			Layers[layer_name.to_upper()] = 1 << (i - 1)
