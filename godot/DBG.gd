extends Node2D


func _ready() -> void:
	var v := Vector2(1, -1)
	print(is_equal_approx(v.dot(v), 2))
