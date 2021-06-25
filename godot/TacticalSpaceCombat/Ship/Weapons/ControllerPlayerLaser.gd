class_name ControllerPlayerLaser
extends ControllerPlayer


func _on_Ship_targeted(msg: Dictionary) -> void:
	._on_Ship_targeted(msg)
	_ui_weapon_button.pressed = false

	match msg:
		{"type": Type.LASER, "success": true}:
			weapon.fire()


func _on_UIWeaponButton_gui_input(event: InputEvent) -> void:
	._on_UIWeaponButton_gui_input(event)
	if event.is_action_pressed("right_click"):
		weapon.has_targeted = false


func _on_UIWeaponButton_toggled(is_pressed: bool) -> void:
	._on_UIWeaponButton_toggled(is_pressed)
	var msg := {"is_targeting": is_pressed, "targeting_length": weapon.targeting_length}
	emit_signal("targeting", msg)
