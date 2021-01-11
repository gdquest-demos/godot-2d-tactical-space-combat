class_name Door
extends Area2D


# Emitted when doors open to trigger units to start moving
signal opened

var is_open := false setget set_is_open
var rooms := []

# Keep track of how many units are currently passing this door
var _units := 0

onready var sprite: Sprite = $Sprite
onready var timer: Timer = $Timer


func _ready() -> void:
	timer.connect("timeout", self, "set_is_open", [true])


# Starts the timer after which the door will open when the first unit is detected
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("unit"):
		_units += 1
		if _units == 1:
			timer.start()
	elif area.is_in_group("room"):
		rooms.push_back(area)


# After units pass the door, it'll close
func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("unit"):
		_units -= 1
		if _units == 0:
			self.is_open = false


func set_is_open(value: bool) -> void:
	is_open = value
	if is_open:
		sprite.frame = 1
		emit_signal("opened")
	else:
		sprite.frame = 0
