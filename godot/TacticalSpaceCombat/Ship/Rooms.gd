class_name Rooms
extends Node2D


signal targeted(msg)

var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()


func _on_Controller_targeting(msg: Dictionary) -> void:
	match msg:
		{"index": var index}:
			var r := _rng.randi_range(0, get_child_count() - 1)
			var room: Room = get_child(r)
			emit_signal("targeted", {"index": index, "target_position": room.position})


func get_laser_points(targeting_length: float) -> Array:
	var r1 := _rng.randi_range(0, get_child_count() - 1)
	var rs_remaining := []
	for room_index in range(get_child_count()):
		if room_index != r1:
			rs_remaining.push_back(room_index)
	var index = _rng.randi_range(0, rs_remaining.size() - 1)
	var r2 = rs_remaining[index]

	var point1: Vector2 = get_child(r1).get_random_vector()
	var point2: Vector2 = get_child(r2).get_random_vector()
	point2 = point1 + (point2 - point1).clamped(targeting_length)
	return [point1, point2]
