extends Node


## Provides easy access to physics layers & masks from code.
enum Layers { NONE }

var winner_is_player := false


func _ready() -> void:
	var label := 'layer_names/2d_physics/layer_%d'
	for i in range(1, 21):
		var layer_name: String = ProjectSettings.get_setting(label % i)
		if layer_name != '':
			# We call `<<` the left-shift bit-wise operator. It shifts the
			# bits to the left by adding zeros to the right hand side.
			# So `1 << 3 == 0b1000` which in decimals means 8. The `0b` prefix
			# instructs Godot that this is a binary value.
			#
			# 1 << 1 == 2
			# 1 << 3 == 8
			#
			# Thus `1 << x` is the same as `2 to the power of x`.
			Layers[layer_name.to_upper()] = 1 << (i - 1)
