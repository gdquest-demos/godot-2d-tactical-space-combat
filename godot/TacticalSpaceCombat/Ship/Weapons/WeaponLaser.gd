class_name WeaponLaser
extends Weapon


signal fire_started(points, duration, params)
signal fire_stopped
signal targeting(points)

const TARGET_LINE_DEFAULT := PoolVector2Array([Vector2.INF, Vector2.INF])
const TARGETTING_LENGTH := 160

var _is_targeting := false
var _points := TARGET_LINE_DEFAULT

onready var timer: Timer = $Timer
onready var line: Line2D = $Line2D


func _ready() -> void:
	timer.connect("timeout", self, "emit_signal", ["fire_stopped"])
	timer.connect("timeout", self, "_set_is_charging", [true])
	timer.connect("timeout", line, "set_visible", [false])


func _fire() -> void:
	timer.start()
	line.visible = true
	emit_signal("fire_started", _points, timer.wait_time, {"attack": attack})


func _set_is_charging(value: bool) -> void:
	._set_is_charging(value)
	if not (_is_targeting or _is_charging or _points[1] == Vector2.INF):
		_fire()
