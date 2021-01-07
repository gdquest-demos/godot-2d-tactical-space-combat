extends Node2D


signal targeted(msg)

var _swipe_start := Vector2.ZERO
var _rng := RandomNumberGenerator.new()
var _rooms: Rooms
var _spawner: Path2D

onready var area: Area2D = $Area2D
onready var line: Line2D = $Line2D
onready var target_line: Line2D = $TargetLine2D
onready var tween: Tween = $Tween


func setup(rooms: Rooms, spawner: Path2D) -> void:
	_rooms = rooms
	_spawner = spawner


func _ready() -> void:
	_rng.randomize()


func _on_Controller_targeting(msg: Dictionary) -> void:
	var points: PoolVector2Array = msg.get("points", [])
	match msg:
		{"targeting_length": var targeting_length}:
			points = _rooms.get_laser_points(targeting_length)
			emit_signal("targeted", {"points": points})
	target_line.points = points


func _on_Weapon_fire_started(points: PoolVector2Array, duration: float, params: Dictionary) -> void:
	area.set_deferred("monitorable", true)
	area.params = params
	_swipe_start = _spawner.interpolate(_rng.randf())
	tween.interpolate_method(self, "_swipe_laser", points[0], points[1], duration)
	tween.start()


func _on_Weapon_fire_stopped() -> void:
	tween.remove(self, "_swipe_laser")
	area.set_deferred("monitorable", false)
	area.position = Vector2.ZERO
	line.points = []


func _swipe_laser(offset: Vector2) -> void:
	area.position = offset
	line.points = [_swipe_start, offset]
