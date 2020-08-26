extends Node2D


onready var scene_tree: SceneTree = get_tree()
onready var ship: Node2D = $Ship
onready var rooms: Node2D = $Ship/Rooms
onready var tilemap: TileMap = $Ship/TileMap
onready var unit: Path2D = $Ship/Unit


func _ready() -> void:
	for room in rooms.get_children():
		room.setup(tilemap)
		room.render()
	tilemap.setup()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		var point1: Vector2 = unit.path_follow.position
		var point2: Vector2 = ship.transform.xform_inv(event.position)
		var path: PoolVector2Array = tilemap.find_path(point1, point2)
		unit.walk(path)
