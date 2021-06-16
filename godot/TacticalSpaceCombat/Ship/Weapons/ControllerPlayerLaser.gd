class_name ControllerPlayerLaser
extends ControllerPlayer


func _on_Ship_targeted(msg: Dictionary) -> void:
	._on_Ship_targeted(msg)
	_ui_weapon_button.pressed = false

	match msg:
		{"type": Type.LASER, ..}:
			weapon.fire()


func _on_UIWeaponButton_toggled(is_pressed: bool) -> void:
	._on_UIWeaponButton_toggled(is_pressed)
	weapon.has_targeted = not is_pressed
	var msg := {"is_targeting": is_pressed, "targeting_length": weapon.targeting_length}
	emit_signal("targeting", msg)
