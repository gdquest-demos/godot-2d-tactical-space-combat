extends Node2D


onready var rooms: Node2D = $Rooms
onready var path: Path2D = $Path2D
onready var nav: Navigation2D = $Navigation2D
onready var navpoly: NavigationPolygonInstance = $Navigation2D/NavigationPolygonInstance


func _ready() -> void:
	navpoly.navpoly = polys_to_navpoly($Rooms)
	
	for point in nav.get_simple_path($StartPosition2D.position, $EndPosition2D.position):
		path.curve.add_point(point)


static func polys_to_navpoly(node_polys: Node2D) -> NavigationPolygon:
	var out := NavigationPolygon.new()
	for node_poly in node_polys.get_children():
		var poly: PoolVector2Array = node_poly.get_node("Floor").polygon
		if node_poly.has_node("Device"):
			var device_poly: Polygon2D = node_poly.get_node("Device")
			poly = Geometry.exclude_polygons_2d(poly, device_poly.transform.xform(device_poly.polygon))[0]
		poly = node_poly.transform.xform(poly)
		out.add_outline(poly)
	out.make_polygons_from_outlines()
	return out
