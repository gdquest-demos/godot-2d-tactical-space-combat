class_name WeaponEnemy
extends Sprite


export var charge_time := 2.0

var modifier := 1.0

var _is_charging := false setget _set_is_charging
var _min_charge := 0
var _max_charge := 100
var _charge := _min_charge

onready var tween: Tween = $Tween


func _ready() -> void:
	_set_is_charging(true)
	tween.connect("tween_all_completed", self, "_set_is_charging", [false])


func _set_is_charging(value: bool) -> void:
	_is_charging = value
	if _is_charging:
		tween.interpolate_property(self, "_charge", _min_charge, _max_charge, charge_time * modifier)
		tween.start()
