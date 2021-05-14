extends Area2D


signal opened

var is_open := false setget set_is_open
var rooms := []

## Keep track of the number of units passing this door right now.
var _units := 0

onready var sprite: Sprite = $Sprite
onready var timer: Timer = $Timer


func _ready() -> void:
	connect("area_entered", self, "_on_area_entered_exited", [true])
	connect("area_exited", self, "_on_area_entered_exited", [false])
	timer.connect("timeout", self, "set_is_open", [true])


func _on_area_entered_exited(area: Area2D, has_entered: bool) -> void:
	if area.is_in_group("unit"):
		# Add or subtract 1 to `_units` based on `has_entered`.
		_units += 1 if has_entered else -1

		# Only if we meet both conditions execute the code.
		match [_units, has_entered]:
			[0, false]: self.is_open = false
			[1, true]: timer.start()
	elif area.is_in_group("room") and has_entered:
		rooms.push_back(area)

## When the first unit is detect start the timer.
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("unit"):
		_units += 1
		if _units == 1:
			timer.start()
		print("entered: ", _units)
	elif area.is_in_group("room"):
		rooms.push_back(area)


## Set `is_open` to `false` after units pass the door.
func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("unit"):
		_units -= 1
		if _units == 0:
			self.is_open = false
		print("exited: ", _units)


## Update `is_open` and `sprite.frame`. Emit the `opened` signal
## when `is_open` is `true`.
func set_is_open(value: bool) -> void:
	is_open = value
	if is_open:
		sprite.frame = 1
		emit_signal("opened")
	else:
		sprite.frame = 0
