extends Node2D


var _pathfinder: FTLLikePathFinder = FTLLikePathFinder.new()

onready var scene_tree: SceneTree = get_tree()
onready var ship: Node2D = $Ship
onready var tilemap: TileMap = $Ship/TileMap
onready var path: Path2D = $Ship/Unit/Path2D


func _ready() -> void:
	for room in scene_tree.get_nodes_in_group("room"):
		room.setup(tilemap)
		room.render()
	
	_pathfinder.setup(tilemap)
	for point in _pathfinder.find_path(ship.get_node("Position1").position, ship.get_node("Position2").position):
		path.curve.add_point(tilemap.map_to_world(point) + tilemap.cell_size / 2.0)
