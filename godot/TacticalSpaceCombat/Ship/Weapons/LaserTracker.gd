extends Node2D

signal targeted(msg)

const TARGET_LINE_DEFAULT := PoolVector2Array([Vector2.INF, Vector2.INF])

var _swipe_start := Vector2.ZERO
var _is_targeting := false
var _points := TARGET_LINE_DEFAULT
var _targeting_length := 0
var _rng := RandomNumberGenerator.new()
var _rooms: Node2D = null
var _shield: Area2D = null
var _shield_polygon := PoolVector2Array()

onready var area: Area2D = $Area2D
onready var line: Line2D = $Line2D
onready var target_line: Line2D = $TargetLine2D
onready var tween: Tween = $Tween


func setup(rooms: Node2D, shield: Area2D, color: Color) -> void:
	_rooms = rooms
	_shield = shield
	line.default_color = color
	target_line.default_color = color
	if _shield != null:
		_shield_polygon = _shield.polygon.polygon
		_shield_polygon = _shield.transform.xform(_shield_polygon)


func _ready() -> void:
	_rng.randomize()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouse and _is_targeting):
		return

	if event.is_action_pressed("left_click"):
		_points[0] = get_local_mouse_position()
	elif _points[0] != Vector2.INF and event is InputEventMouseMotion:
		var offset: Vector2 = get_local_mouse_position() - _points[0]
		offset = offset.clamped(_targeting_length)
		_points[1] = _points[0] + offset
		target_line.points = _points
	elif event.is_action_released("left_click") and _points[1] != Vector2.INF:
		_is_targeting = false
		emit_signal("targeted", {"type": Controller.Type.LASER})


func _on_Controller_targeting(msg: Dictionary) -> void:
	match msg:
		{"targeting_length": var targeting_length, "is_targeting": var is_targeting}:
			_is_targeting = is_targeting
			_targeting_length = targeting_length
			if _is_targeting:
				_points = TARGET_LINE_DEFAULT
		{"targeting_length": var targeting_length}:
			_points = _rooms.get_laser_points(targeting_length)
			target_line.points = _points
			emit_signal("targeted", {"type": Controller.Type.LASER})


func _on_Weapon_fire_started(duration: float, params: Dictionary) -> void:
	if _points[0] == Vector2.INF or _points[1] == Vector2.INF:
		return

	_swipe_start = _rooms.mean_position + Utils.randvf_circle(_rng, Projectile.MAX_DISTANCE)
	area.set_deferred("monitorable", true)
	area.params = params
	tween.interpolate_method(self, "_swipe_laser", _points[0], _points[1], duration)
	tween.start()


func _on_Weapon_fire_stopped() -> void:
	tween.remove_all()
	area.set_deferred("monitorable", false)
	area.position = Vector2.ZERO
	line.points = []


func _swipe_laser(offset: Vector2) -> void:
	line.points = [_swipe_start, offset]
	if _shield != null and _shield.hitpoints > 0:
		for points in Geometry.clip_polyline_with_polygon_2d(line.points, _shield_polygon):
			line.points = points
	area.position = line.points[1]
