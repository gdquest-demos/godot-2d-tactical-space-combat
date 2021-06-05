extends Weapon

signal fire_started(params)
signal fire_stopped

export (int, 0, 250) var targeting_length := 140
export var color := Color("b0305c")

var has_targeted := false

onready var timer: Timer = $Timer
onready var line: Line2D = $Line2D


func _ready() -> void:
	timer.connect("timeout", self, "emit_signal", ["fire_stopped"])
	timer.connect("timeout", self, "set_is_charging", [true])
	timer.connect("timeout", line, "set_visible", [false])
	line.default_color = color


func fire() -> void:
	if not can_fire():
		return

	timer.start()
	has_targeted = false
	line.visible = true
	var params := {
		"duration": timer.wait_time,
		"chance_fire": chance_fire,
		"chance_hull_breach": chance_hull_breach,
		"attack": attack
	}
	emit_signal("fire_started", params)


func can_fire() -> bool:
	return not is_charging and has_targeted
