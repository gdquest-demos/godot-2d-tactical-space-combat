tool
extends Weapon

signal fire_started(params)
signal fire_stopped

export (int, 0, 250) var targeting_length := 140
export var color := Color("b0305c")

var has_targeted := false

onready var timer: Timer = $Timer
onready var line: Line2D = $Line2D


func _ready() -> void:
	if Engine.editor_hint:
		return

	timer.connect("timeout", self, "emit_signal", ["fire_stopped"])
	timer.connect("timeout", self, "set_is_charging", [true])
	timer.connect("timeout", line, "set_visible", [false])
	line.default_color = color


func _get_configuration_warning() -> String:
	var parent := get_parent()
	var is_verified := parent != null and parent is ControllerAILaser or parent is ControllerPlayerLaser
	return "" if is_verified else "WeaponLaser needs to be a parent of Controller*Laser"


func fire() -> void:
	if not can_fire():
		return

	timer.start()
	has_targeted = false
	line.visible = true
	var params := {
		"duration": timer.wait_time,
		"attack": attack,
		"chance_fire": chance_fire,
		"chance_breach": chance_breach
	}
	emit_signal("fire_started", params)


func can_fire() -> bool:
	return not is_charging and has_targeted
