extends Node2D

signal targeted(msg)

var mean_position := Vector2.INF

var _rng := RandomNumberGenerator.new()
var _rooms_count := 0


func _ready() -> void:
	_rng.randomize()
	_rooms_count = get_child_count()
	mean_position = _get_mean_position()


func _on_Controller_targeting(msg: Dictionary) -> void:
	var r := _rng.randi_range(0, _rooms_count - 1)
	var room: Room = get_child(r)
	msg.type = Controller.Type.PROJECTILE
	msg.target_position = room.position
	emit_signal("targeted", msg)


func get_laser_points(targeting_length: float) -> Array:
	var room_index_first := _rng.randi_range(0, _rooms_count - 1)
	var remaining := []
	for room_index in range(_rooms_count):
		if room_index != room_index_first:
			remaining.push_back(room_index)
	var index = _rng.randi_range(0, remaining.size() - 1)
	var room_index_second = remaining[index]

	var point1: Vector2 = get_child(room_index_first).randv()
	var point2: Vector2 = get_child(room_index_second).randv()
	point2 = point1.move_toward(point2, targeting_length)
	return [point1, point2]


func _get_mean_position() -> Vector2:
	var out := Vector2.ZERO
	for room in get_children():
		out += room.position

	if _rooms_count > 0:
		out /= _rooms_count
	return out
