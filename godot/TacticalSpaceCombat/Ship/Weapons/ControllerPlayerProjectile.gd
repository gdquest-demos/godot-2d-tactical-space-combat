class_name ControllerPlayerProjectile
extends ControllerPlayer


func _ready() -> void:
	weapon.setup(Global.Layers.SHIPAI)


func _on_Ship_targeted(msg: Dictionary) -> void:
	._on_Ship_targeted(msg)
	if msg.index == get_index():
		_ui_weapon_button.pressed = false

	match msg:
		{"type": Type.PROJECTILE, ..}:
			weapon.fire()


func _on_UIWeaponButton_gui_input(event: InputEvent) -> void:
	._on_UIWeaponButton_gui_input(event)
	if event.is_action_pressed("right_click"):
		weapon.target_position = Vector2.INF
		emit_signal("targeting", {"index": get_index()})
		emit_signal("targeting", {"index": -1})


func _on_UIWeaponButton_toggled(is_pressed: bool) -> void:
	._on_UIWeaponButton_toggled(is_pressed)
	var index := -1
	if is_pressed:
		index = get_index()
		weapon.target_position = Vector2.INF
	emit_signal("targeting", {"index": index})
