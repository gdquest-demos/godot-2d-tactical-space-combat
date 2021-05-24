class_name WeaponLaser
extends Weapon

signal fire_started(duration, params)
signal fire_stopped

export (int, 0, 250) var targeting_length := 140

var targeted := false

onready var timer: Timer = $Timer
onready var line: Line2D = $Line2D


func _ready() -> void:
	timer.connect("timeout", self, "emit_signal", ["fire_stopped"])
	timer.connect("timeout", self, "set_is_charging", [true])
	timer.connect("timeout", line, "set_visible", [false])


func fire() -> void:
	targeted = false
	var params := {
		"chance_fire": chance_fire, "chance_hull_breach": chance_hull_breach, "attack": attack
	}
	timer.start()
	line.visible = true
	emit_signal("fire_started", timer.wait_time, params)


func set_is_charging(value: bool) -> void:
	.set_is_charging(value)
	if not is_charging and targeted:
		fire()
