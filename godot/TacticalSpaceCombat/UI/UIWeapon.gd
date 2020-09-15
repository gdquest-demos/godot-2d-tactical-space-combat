class_name UIWeapon
extends VBoxContainer

signal targeting_done(target)

onready var progress_bar: ProgressBar = $ProgressBar
onready var button: Button = $Button

var _weapon


# weapon: Weapon
func setup(weapon) -> void:
	_weapon = weapon
	_weapon.connect("charge_changed", self, "_on_Weapon_charge_changed")


func _ready() -> void:
	button.text = _weapon.label


func _select_target_async() -> void:
	Events.connect("room_clicked", self, "_on_Events_room_clicked")
	Input.set_default_cursor_shape(Input.CURSOR_CROSS)
	var target: Room = yield(self, "targeting_done")
	if target:
		_weapon.target = target
	button.pressed = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	Events.disconnect("room_clicked", self, "_on_Events_room_clicked")


func _on_Weapon_charge_changed(new_value: float) -> void:
	progress_bar.value = new_value


func _on_Button_toggled(button_pressed: bool) -> void:
	if button_pressed:
		_select_target_async()


func _on_Button_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") and button.pressed:
		emit_signal("targeting_done", null)


func _on_Events_room_clicked(room: Room) -> void:
	emit_signal("targeting_done", room)
