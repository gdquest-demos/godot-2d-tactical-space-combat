class_name ControllerPlayerProjectile
extends ControllerPlayer


func _ready() -> void:
	weapon.physics_layer = Global.Layers.SHIPAI


func _on_UIWeaponButton_toggled(is_pressed: bool) -> void:
	._on_UIWeaponButton_toggled(is_pressed)
	var index := -1
	if is_pressed:
		index = get_index()
		weapon.target_position = Vector2.INF
	elif not (is_pressed or weapon.is_charging or weapon.target_position == Vector2.INF):
		weapon.fire()
	emit_signal("targeting", {"index": index})


func _on_Ship_targeted(msg: Dictionary) -> void:
	._on_Ship_targeted(msg)
	var index: int = msg.get("index", -1)
	if index == get_index():
		_ui_weapon_button.pressed = false
