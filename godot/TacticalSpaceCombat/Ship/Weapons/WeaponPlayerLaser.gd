class_name WeaponPlayerLaser
extends WeaponPlayer


signal fire_started(points, duration, params)
signal fire_stopped
signal targeting(points)

const TARGET_LINE_DEFAULT := PoolVector2Array([Vector2.INF, Vector2.INF])
const TARGETTING_LENGTH := 160

export(int, 0, 5) var attack := 1

var _is_targeting := false
var _points := TARGET_LINE_DEFAULT

onready var timer: Timer = $Timer
onready var line: Line2D = $Line2D


func _ready() -> void:
	timer.connect("timeout", self, "emit_signal", ["fire_stopped"])
	timer.connect("timeout", self, "_set_is_charging", [true])
	timer.connect("timeout", line, "set_visible", [false])


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouse and _is_targeting):
		return
	
	if event.is_action_pressed("left_click"):
		_points[0] = event.position
	elif _points[0] != Vector2.INF and event is InputEventMouseMotion:
		var offset: Vector2 = event.position - _points[0]
		offset = offset.clamped(TARGETTING_LENGTH)
		_points[1] = _points[0] + offset
	elif event.is_action_released("left_click"):
		_ui_weapon_button.pressed = false
		if not _is_charging:
			_fire()
	
	if _points[1] != Vector2.INF:
		emit_signal("targeting", _points)


func _on_UIWeaponButton_toggled(is_pressed: bool) -> void:
	._on_UIWeaponButton_toggled(is_pressed)
	_is_targeting = is_pressed
	if _is_targeting:
		_points = TARGET_LINE_DEFAULT
		emit_signal("targeting", _points)


func _fire() -> void:
	line.visible = true
	timer.start()
	emit_signal("fire_started", _points, timer.wait_time, {"attack": attack})


func _set_is_charging(value: bool) -> void:
	._set_is_charging(value)
	if not (_is_targeting or _is_charging) and _points[1] != Vector2.INF:
		_fire()
