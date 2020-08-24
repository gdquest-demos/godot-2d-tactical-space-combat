extends Node2D


var _pathfinder: FTLLikePathFinder = FTLLikePathFinder.new()

onready var scene_tree: SceneTree = get_tree()
onready var ship: Node2D = $Ship
onready var tilemap: TileMap = $Ship/TileMap
onready var path: Path2D = $Path2D


func _ready() -> void:
	for room in scene_tree.get_nodes_in_group("room"):
		room.setup(tilemap)
		for offset in room:
			tilemap.set_cellv(offset, 0)
	
	_pathfinder.setup(tilemap)
	for point in _pathfinder.find_path($Position1.position, $Position2.position):
		path.curve.add_point(tilemap.map_to_world(point) + tilemap.cell_size / 2.0)
