extends Node2D


signal targeted(msg)

var _swipe_start := Vector2.ZERO
var _rng := RandomNumberGenerator.new()
var _viewport_transform := Transform2D.IDENTITY
var _rooms: Rooms = null
var _spawner: Path2D = null
var _shield: Area2D = null

onready var area: Area2D = $Area2D
onready var line: Line2D = $Line2D
onready var target_line: Line2D = $TargetLine2D
onready var tween: Tween = $Tween


func setup(viewport_transform: Transform2D, rooms: Rooms, spawner: Path2D, shield: Area2D) -> void:
	_viewport_transform = viewport_transform
	_rooms = rooms
	_spawner = spawner
	_shield = shield


func _ready() -> void:
	_rng.randomize()


func _on_Controller_targeting(msg: Dictionary) -> void:
	var points: PoolVector2Array = msg.get("points", [])
	points = _viewport_transform.xform_inv(points)
	match msg:
		{"targeting_length": var targeting_length}:
			points = _rooms.get_laser_points(targeting_length)
			emit_signal("targeted", {"points": points})
	target_line.points = points


func _on_Weapon_fire_started(points: PoolVector2Array, duration: float, params: Dictionary) -> void:
	_swipe_start = _spawner.interpolate(_rng.randf())
	points = _viewport_transform.xform_inv(points)
	area.set_deferred("monitorable", true)
	area.params = params
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
	if _shield != null and _shield.is_on:
		var polygon: PoolVector2Array = _shield.polygon.polygon
		polygon = _shield.transform.xform(polygon)
		for points in Geometry.clip_polyline_with_polygon_2d(line.points, polygon):
			line.points = points
