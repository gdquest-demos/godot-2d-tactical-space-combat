class_name WeaponEnemyLaser
extends WeaponEnemy


signal fire_started(points, duration, params)
signal fire_stopped
signal targeting

const TARGETTING_LENGTH := 160

export(int, 0, 5) var attack := 1

var _points := []

onready var timer: Timer = $Timer
onready var line: Line2D = $Line2D


func _ready() -> void:
	timer.connect("timeout", self, "emit_signal", ["fire_stopped"])
	timer.connect("timeout", self, "_set_is_charging", [true])
	timer.connect("timeout", line, "set_visible", [false])
	
	yield(get_tree(), "idle_frame")
	emit_signal("targeting")


func _on_Ship_targeted(msg: Dictionary) -> void:
	match msg:
		{"start": var start, "direction": var direction}:
			var end: Vector2 = start + TARGETTING_LENGTH * direction
			_points = [start, end]


func _fire() -> void:
	line.visible = true
	timer.start()
	emit_signal("fire_started", _points, timer.wait_time, {"attack": attack})
	emit_signal("targeting")


func _set_is_charging(value: bool) -> void:
	._set_is_charging(value)
	if not (_points.empty() or _is_charging):
		_fire()
