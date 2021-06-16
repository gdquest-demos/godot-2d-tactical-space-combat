class_name ControllerPlayerProjectile
extends ControllerPlayer


func setup(ui_weapon: VBoxContainer) -> void:
	.setup(ui_weapon)
	_ui_weapon_button.connect("gui_input", self, "_on_UIWeaponButton_gui_input")


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
	if event.is_action_pressed("right_click"):
		weapon.target_position = Vector2.INF
		_ui_weapon_button.pressed = false
		emit_signal("targeting", {"index": get_index()})


func _on_UIWeaponButton_toggled(is_pressed: bool) -> void:
	._on_UIWeaponButton_toggled(is_pressed)
	var index := -1
	if is_pressed:
		index = get_index()
		weapon.target_position = Vector2.INF
	emit_signal("targeting", {"index": index})
