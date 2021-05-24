extends Area2D

signal opened

var is_open := false setget set_is_open
var rooms := []

var _units := 0

onready var sprite: Sprite = $Sprite
onready var timer: Timer = $Timer


func _ready() -> void:
	connect("area_entered", self, "_on_area_entered_exited", [true])
	connect("area_exited", self, "_on_area_entered_exited", [false])
	timer.connect("timeout", self, "set_is_open", [true])


func _on_area_entered_exited(area: Area2D, has_entered: bool) -> void:
	if area.is_in_group("unit"):
		_units += 1 if has_entered else -1

		match [_units, has_entered]:
			[0, false]:
				self.is_open = false

			[1, true]:
				timer.start()

	elif area.is_in_group("room") and has_entered:
		rooms.push_back(area)


func set_is_open(value: bool) -> void:
	is_open = value
	if is_open:
		sprite.frame = 1
		emit_signal("opened")
	else:
		sprite.frame = 0
