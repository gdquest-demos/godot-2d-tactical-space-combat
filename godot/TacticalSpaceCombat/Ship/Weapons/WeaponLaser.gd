class_name WeaponLaser
extends Weapon


signal fire_started(points, duration)
signal fire_stopped
signal targeting(points)

const TARGETTING_LENGTH := 160

var _targets := {}
var _is_targeting := false

onready var target_line: Line2D = $TargetLine2D
onready var laser_line: Line2D = $LaserLine2D
onready var timer: Timer = $Timer


func _ready() -> void:
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
		_fire(global_transform.xform(target_line.points))
		target_line.points = [Vector2.INF, Vector2.INF]
		_ui_weapon_button.pressed = false
	
	emit_signal("targeting", global_transform.xform(target_line.points))


func _on_UIWeaponButton_toggled(is_pressed: bool) -> void:
	_is_targeting = is_pressed
	var cursor := Input.CURSOR_CROSS if is_pressed else Input.CURSOR_ARROW
	Input.set_default_cursor_shape(cursor)


func _on_WeaponLaserPlayerArea_area_entered_exited(area: Area2D, has_entered: bool) -> void:
	if not area.is_in_group("room"):
		return
	
	if has_entered:
		_targets[area] = null
	else:
		_targets.erase(area)


func _on_Timer_timeout() -> void:
	laser_line.visible = false
	emit_signal("fire_stopped")


func _fire(target_points: PoolVector2Array) -> void:
	laser_line.visible = true
	timer.start()
	emit_signal("fire_started", target_points, timer.wait_time)


func _set_is_charging(value: bool) -> void:
	._set_is_charging(value)
	if _is_charging:
		tween.interpolate_property(_ui_weapon_progress_bar, "value", _ui_weapon_progress_bar.min_value, _ui_weapon_progress_bar.max_value, charge_time)
		tween.start()
	elif not _is_charging:
		_set_is_charging(true)
