class_name Ship
extends Node2D


signal attached_shield
signal hit_points_changed(hit_points, is_player)
signal targeted(msg)

const Projectile = preload("Weapons/Projectile.tscn")

export(int, 0, 30) var hit_points := 30

var evasion := 0.0
var has_sensors := false

# This dictionary keeps track of the crew locations.
var _slots := {}
var _rng := RandomNumberGenerator.new()

var _shield: Area2D = null

onready var scene_tree: SceneTree = get_tree()
onready var tilemap: TileMap = $TileMap
onready var rooms: Node2D = $Rooms
onready var fires: Node2D = $Fires
onready var doors: Node2D = $Doors
onready var weapons: Node2D = $Weapons
onready var units: Node2D = $Units
onready var spawner: Path2D = $Spawner
onready var projectiles: Node2D = $Projectiles
onready var laser: Node2D = $Laser
onready var laser_area: Area2D = $Laser/Area2D
onready var laser_line: Line2D = $Laser/Line2D
onready var laser_target_line: Line2D = $Laser/TargetLine2D


func _ready() -> void:
	_rng.randomize()
	
	for unit in units.get_children():
		for door in doors.get_children():
			door.connect("opened", unit, "set_is_walking", [true])
		
		# store position of unit
		var position_map := tilemap.world_to_map(unit.path_follow.position)
		_slots[position_map] = unit
	
	for room in rooms.get_children():
		room.setup(tilemap)
		room.connect("area_entered", self, "_on_RoomArea2D_area_entered")
		room.connect("modifier_changed", self, "_on_Room_modifier_changed")
		room.hit_area.connect(
			"body_entered", self, "_on_RoomHitArea2D_body_entered",
			[room.position, room.top_left, room.bottom_right]
		)
		for point in room:
			tilemap.set_cellv(point, 0)
		
		if room.type == Room.Type.SENSORS:
			has_sensors = true
	
	if has_node("Shield"):
		_shield = $Shield
		_shield.position = _get_mean_position()
	
	tilemap.setup(rooms, doors)
	fires.setup(tilemap)


func _on_WeaponProjectile_targeting(index: int) -> void:
	var r := _rng.randi_range(0, rooms.get_child_count() - 1)
	var room: Room = rooms.get_child(r)
	room.emit_signal("targeted", index, room.position)


func _on_WeaponProjectile_projectile_exited(physics_layer: int, params: Dictionary) -> void:
	var spawn_position: Vector2 = spawner.interpolate(_rng.randf())
	var direction: Vector2 = (params.target_position - spawn_position).normalized()
	var projectile: RigidBody2D = Projectile.instance()
	projectile.collision_layer = physics_layer
	projectile.position = spawn_position
	projectile.linear_velocity = direction * projectile.linear_velocity.length()
	projectile.rotation = direction.angle()
	projectile.params = params
	projectiles.add_child(projectile)


func _on_WeaponLaser_targeting() -> void:
	var r1 := _rng.randi_range(0, rooms.get_child_count() - 1)
	var rs_remaining := []
	for room_index in range(rooms.get_child_count()):
		if room_index != r1:
			rs_remaining.push_back(room_index)
	var index = _rng.randi_range(0, rs_remaining.size() - 1)
	var r2 = rs_remaining[index]
	
	var point1: Vector2 = rooms.get_child(r1).get_random_vector()
	var point2: Vector2 = rooms.get_child(r2).get_random_vector()
	emit_signal("targeted", {"start": point1, "direction": (point2 - point1).normalized()})


func _on_Room_modifier_changed(type: int, value: float) -> void:
	match type:
		Room.Type.HELM:
			evasion = value
		Room.Type.WEAPONS:
			for weapon in weapons.get_children():
				weapon.modifier = value


func _on_RoomHitArea2D_body_entered(
		body: RigidBody2D,
		room_position: Vector2,
		room_top_left: Vector2,
		room_bottom_right: Vector2
	) -> void:
	if not room_position.is_equal_approx(body.params.target_position) or _rng.randf() < evasion:
		return
	
	if _rng.randf() < body.params.chance_fire:
		var offset := Utils.randvi_range(_rng, room_top_left, room_bottom_right - Vector2.ONE)
		fires.add_fire(offset, true)
	
	if _rng.randf() < body.params.chance_hull_damage:
		# TODO break oxigen
		pass
	
	_take_damage(body.params.attack)
	body.queue_free()


func _on_RoomArea2D_area_entered(area: Area2D) -> void:
	if ((_shield != null and _shield.hit_points == 0 and area.is_in_group("laser"))
		or (_shield == null and area.is_in_group("laser"))
	):
		_take_damage(area.params.attack)


func _on_FireTimer_timeout() -> void:
	for room in rooms.get_children():
		for fire in _get_fires(room):
			for unit in room.units:
				fire.take_damage(unit.attack)
			break
	
	for fire in fires.get_fires():
		if _rng.randf() < fire.chance_attack:
			_take_damage(fire.attack)


func _on_UIDoorsButton_pressed() -> void:
	var has_opened_doors := false
	for door in doors.get_children():
		if door.is_open:
			has_opened_doors = true
			break
	
	for door in doors.get_children():
		door.is_open = not has_opened_doors


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		for unit in units.get_children():
			unit.is_selected = false
	elif event.is_action_pressed("right_click"):
		for unit in scene_tree.get_nodes_in_group("selected-unit"):
			var point1: Vector2 = tilemap.world_to_map(unit.path_follow.position)
			for room in scene_tree.get_nodes_in_group("selected-room"):
				var point2: Vector2 = room.get_slot(_slots, unit)
				if is_inf(point2.x):
					break
				
				var path: Curve2D = tilemap.find_path(point1, point2)
				Utils.erase_value(_slots, unit)
				_slots[point2] = unit
				unit.walk(path)


func _take_damage(value: int) -> void:
	hit_points -= value
	hit_points = max(0, hit_points)
	emit_signal("hit_points_changed", hit_points, is_in_group("player"))


func _get_mean_position() -> Vector2:
	var out := Vector2.ZERO
	if rooms.get_child_count() > 0:
		for room in rooms.get_children():
			out += room.position
		out /= rooms.get_child_count()
	return out


func _get_fires(room: Room) -> Array:
	var out := []
	for fire in fires.get_fires():
		if room.has_point(tilemap.world_to_map(fire.position)):
			out.append(fire)
	return out
