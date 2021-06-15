extends Node2D

signal targeted(msg)

const LINE_DEFAULT := PoolVector2Array([Vector2.INF, Vector2.INF])

var _is_targeting := false
var _targeting_length := 0
var _rng := RandomNumberGenerator.new()
var _rooms: Node2D = null
var _shield: Area2D = null
var _shield_polygon := PoolVector2Array()

onready var tween: Tween = $Tween
onready var area: Area2D = $Area2D
onready var line: Line2D = $Line2D
onready var target_line: Line2D = $TargetLine2D


func setup(color: Color, rooms: Node2D, shield: Area2D) -> void:
	_rooms = rooms
	_shield = shield
	line.default_color = color
	target_line.default_color = color
	if _shield != null:
		_shield_polygon = _shield.polygon.polygon
		_shield_polygon = _shield.transform.xform(_shield_polygon)


func _ready() -> void:
	_rng.randomize()
	target_line.points = LINE_DEFAULT
	line.points = LINE_DEFAULT


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouse and _is_targeting):
		return

	if event.is_action_pressed("left_click"):
		target_line.points[0] = get_local_mouse_position()
	elif target_line.points[0] != Vector2.INF and event is InputEventMouseMotion:
		var offset: Vector2 = get_local_mouse_position() - target_line.points[0]
		offset = offset.clamped(_targeting_length)
		target_line.points[1] = target_line.points[0] + offset
		target_line.points = target_line.points
	elif event.is_action_released("left_click") and target_line.points[1] != Vector2.INF:
		_is_targeting = false
		emit_signal("targeted", {"type": Controller.Type.LASER})


func _on_Controller_targeting(msg: Dictionary) -> void:
	match msg:
		{"targeting_length": var targeting_length, "is_targeting": var is_targeting}:
			_is_targeting = is_targeting
			_targeting_length = targeting_length
			if _is_targeting:
				target_line.points = LINE_DEFAULT
		{"targeting_length": var targeting_length}:
			target_line.points = _rooms.get_laser_points(targeting_length)
			target_line.points = target_line.points
			emit_signal("targeted", {"type": Controller.Type.LASER})


func _on_Weapon_fire_started(params: Dictionary) -> void:
	if target_line.points[0] == Vector2.INF or target_line.points[1] == Vector2.INF:
		return

	area.set_deferred("monitorable", true)
	area.params = params

	line.points[0] = _rooms.mean_position + Utils.randvf_circle(_rng, Projectile.MAX_DISTANCE)
	tween.interpolate_method(
		self, "_swipe_laser", target_line.points[0], target_line.points[1], params.duration
	)
	tween.start()


func _on_Weapon_fire_stopped() -> void:
	tween.remove_all()
	line.points = LINE_DEFAULT
	area.set_deferred("monitorable", false)
	area.position = Vector2.ZERO


func _swipe_laser(offset: Vector2) -> void:
	line.points[1] = offset
	if _shield != null and _shield.hitpoints > 0:
		for points in Geometry.clip_polyline_with_polygon_2d(line.points, _shield_polygon):
			line.points = points
	area.position = line.points[1]
