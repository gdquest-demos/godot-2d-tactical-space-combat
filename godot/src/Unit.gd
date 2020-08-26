extends Path2D


var speed := 150

onready var path_follow: PathFollow2D = $PathFollow2D


func _ready() -> void:
	TSCEvents.connect("door_opened", self, "_on_Events_door_opened")
	set_process(false)


func _on_AreaUnit_area_entered(area: Area2D) -> void:
	set_process(false)


func _on_Events_door_opened() -> void:
	set_process(true)


func _process(delta: float) -> void:
	path_follow.offset += speed * delta
	if path_follow.offset >= curve.get_baked_length():
		set_process(false)


func walk(path: PoolVector2Array) -> void:
	if path.empty():
		return

	curve.clear_points()
	curve.add_point(path_follow.position)
	for point in path:
		curve.add_point(point)

	path_follow.offset = 0
	set_process(true)
