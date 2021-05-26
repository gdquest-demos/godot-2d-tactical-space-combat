class_name Weapon
extends Sprite

const MIN_CHARGE := 0
const MAX_CHARGE := 100

export var weapon_name := ""
export var charge_time := 2.0
export (int, 0, 5) var attack := 2
export (float, 0, 1) var chance_fire := 0.0
export (float, 0, 1) var chance_hull_breach := 0.0

var modifier := 1.0 setget set_modifier
var is_charging := false setget set_is_charging

var _charge := MIN_CHARGE

onready var tween: Tween = $Tween


func _ready() -> void:
	tween.connect("tween_all_completed", self, "set_is_charging", [false])
	self.is_charging = true


func set_is_charging(value: bool) -> void:
	is_charging = value
	if is_charging:
		tween.interpolate_property(self, "_charge", MIN_CHARGE, MAX_CHARGE, charge_time)
		tween.start()


func set_modifier(value: float) -> void:
	modifier = value
	tween.speed = modifier
