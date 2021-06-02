extends Node2D

signal targeted(msg)

var mean_position := Vector2.INF

var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	mean_position = _get_mean_position()


func _on_Controller_targeting(msg: Dictionary) -> void:
	match msg:
		{"type": Controller.Type.PROJECTILE, ..}:
			var r := _rng.randi_range(0, get_child_count() - 1)
			var room: Room = get_child(r)
			msg.target_position = room.position
			emit_signal("targeted", msg)


func get_laser_points(targeting_length: float) -> Array:
	var r1 := _rng.randi_range(0, get_child_count() - 1)
	var rs_remaining := []
	for room_index in range(get_child_count()):
		if room_index != r1:
			rs_remaining.push_back(room_index)
	var index = _rng.randi_range(0, rs_remaining.size() - 1)
	var r2 = rs_remaining[index]

	var point1: Vector2 = get_child(r1).randv()
	var point2: Vector2 = get_child(r2).randv()
	point2 = point1 + (point2 - point1).clamped(targeting_length)
	return [point1, point2]


func _get_mean_position() -> Vector2:
	var out := Vector2.ZERO
	for room in get_children():
		out += room.position

	var count := get_child_count()
	if count > 0:
		out /= count
	return out
