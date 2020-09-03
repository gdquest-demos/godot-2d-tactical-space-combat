extends VBoxContainer


export(float, 0) var charge_time := 2.0

var is_charging: bool = false setget set_is_charging

onready var progress_bar: ProgressBar = $ProgressBar
onready var button: Button = $Button
onready var tween: Tween = $Tween


func _ready() -> void:
	self.is_charging = true


func _on_Button_toggled(is_pressed: bool) -> void:
	Input.set_default_cursor_shape(Input.CURSOR_CROSS if is_pressed else Input.CURSOR_ARROW)


func _on_Tween_tween_all_completed() -> void:
	self.is_charging = false


func set_is_charging(val: bool) -> void:
	is_charging = val
	button.disabled = is_charging
	tween.stop_all()
	if is_charging:
		tween.interpolate_property(progress_bar, "value", 0, 100, charge_time)
		tween.start()
