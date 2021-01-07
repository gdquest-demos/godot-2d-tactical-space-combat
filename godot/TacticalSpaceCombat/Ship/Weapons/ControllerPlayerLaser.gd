class_name ControllerPlayerLaser
extends ControllerPlayer


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouse and weapon.is_targeting):
		return

	if event.is_action_pressed("left_click"):
		weapon.points[0] = event.position
	elif weapon.points[0] != Vector2.INF and event is InputEventMouseMotion:
		var offset: Vector2 = event.position - weapon.points[0]
		offset = offset.clamped(weapon.targeting_length)
		weapon.points[1] = weapon.points[0] + offset
	elif event.is_action_released("left_click"):
		_ui_weapon_button.pressed = false
		if not weapon.is_charging:
			weapon.fire()

	if weapon.points[1] != Vector2.INF:
		emit_signal("targeting", {"points": weapon.points})


func _on_UIWeaponButton_toggled(is_pressed: bool) -> void:
	._on_UIWeaponButton_toggled(is_pressed)
	weapon.is_targeting = is_pressed
	if weapon.is_targeting:
		weapon.points = weapon.TARGET_LINE_DEFAULT
		emit_signal("targeting", {"points": weapon.points})


func get_class() -> String:
	return "ControllerPlayerLaser"
