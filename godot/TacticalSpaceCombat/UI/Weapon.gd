extends VBoxContainer


signal fired

export(float, 0) var charge_time := 6.0

var is_charging: bool = false setget set_is_charging

onready var scene_tree: SceneTree = get_tree()
onready var progress_bar: ProgressBar = $ProgressBar
onready var button: Button = $Button
onready var tween: Tween = $Tween


func _ready() -> void:
	self.is_charging = true


func _on_Button_toggled(is_pressed: bool) -> void:
	var cursor := Input.CURSOR_ARROW
	if is_pressed:
		for room in scene_tree.get_nodes_in_group("target"):
			room.remove_from_group("target")
			room.sprite_target.visible = false
		cursor = Input.CURSOR_CROSS
	elif not (is_pressed or is_charging):
		for room in scene_tree.get_nodes_in_group("target"):
			self.is_charging = true
			emit_signal("fired")
	Input.set_default_cursor_shape(cursor)


func set_is_charging(val: bool) -> void:
	is_charging = val
	tween.stop_all()
	if is_charging:
		tween.interpolate_property(progress_bar, "value", 0, 100, charge_time)
		tween.start()
	else:
		for room in scene_tree.get_nodes_in_group("target"):
			if room.sprite_target.visible:
				set_is_charging(true)
				emit_signal("fired")
