class_name WeaponLaser
extends Weapon


signal fire_started(points, duration)
signal fire_stopped
signal targeting(points)

const TARGET_LINE_DEFAULT := PoolVector2Array([Vector2.INF, Vector2.INF])
const TARGETTING_LENGTH := 160

var _targets := {}
var _is_targeting := false

onready var target_line: Line2D = $TargetLine2D
onready var timer: Timer = $Timer


func _ready() -> void:
	timer.connect("timeout", self, "emit_signal", ["fire_stopped"])
	timer.connect("timeout", self, "_set_is_charging", [true])
	target_line.points = [Vector2.INF, Vector2.INF]


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouse and _is_targeting):
		return
	
	if event.is_action_pressed("left_click"):
		target_line.points[0] = global_transform.xform_inv(event.position)
	elif target_line.points[0] != Vector2.INF and event is InputEventMouseMotion:
		var offset: Vector2 = global_transform.xform_inv(event.position) - target_line.points[0]
		offset = offset.clamped(TARGETTING_LENGTH)
		target_line.points[1] = target_line.points[0] + offset
	elif event.is_action_released("left_click"):
		_ui_weapon_button.pressed = false
		if not _is_charging:
			_fire()
	
	emit_signal("targeting", global_transform.xform(target_line.points))


func _on_UIWeaponButton_toggled(is_pressed: bool) -> void:
	._on_UIWeaponButton_toggled(is_pressed)
	_is_targeting = is_pressed
	if _is_targeting:
		target_line.points = TARGET_LINE_DEFAULT


func _on_WeaponLaserPlayerArea_area_entered_exited(area: Area2D, has_entered: bool) -> void:
	if area.is_in_group("room"):
		if has_entered:
			_targets[area] = null
		else:
			_targets.erase(area)


func _fire() -> void:
	timer.start()
	emit_signal("fire_started", global_transform.xform(target_line.points), timer.wait_time)


func _set_is_charging(value: bool) -> void:
	._set_is_charging(value)
	if target_line.points[1] != Vector2.INF and not _is_charging:
		_fire()
