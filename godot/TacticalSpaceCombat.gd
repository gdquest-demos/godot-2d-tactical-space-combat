extends Node2D

const Projectile = preload("TacticalSpaceCombat/Ship/Weapons/Projectile.tscn")
const UIUnit = preload("TacticalSpaceCombat/UI/UIUnit.tscn")
const UISystem = preload("TacticalSpaceCombat/UI/UISystem.tscn")
const UIWeapons = preload("TacticalSpaceCombat/UI/UIWeapons.tscn")
const UIWeapon = preload("TacticalSpaceCombat/UI/UIWeapon.tscn")

var _rng := RandomNumberGenerator.new()
var _swipe_laser_start := Vector2.ZERO

onready var scene_tree: SceneTree = get_tree()
onready var tween: Tween = $Tween
onready var ship_player: Node2D = $ShipPlayer
onready var viewport_container: ViewportContainer = $ViewportContainer
onready var ship_enemy: Node2D = $ViewportContainer/Viewport/ShipEnemy
onready var spawner: PathFollow2D = $ViewportContainer/Viewport/PathSpawner/Spawner
onready var projectiles: Node2D = $ViewportContainer/Viewport/Projectiles
onready var weapon_laser_player: Node2D = $ViewportContainer/Viewport/WeaponLaserPlayer
onready var weapon_laser_player_area: Area2D = $ViewportContainer/Viewport/WeaponLaserPlayer/WeaponLaserArea2D
onready var weapon_laser_player_shape: SegmentShape2D = $ViewportContainer/Viewport/WeaponLaserPlayer/WeaponLaserArea2D/CollisionShape2D.shape
onready var weapon_laser_player_line: Line2D = $ViewportContainer/Viewport/WeaponLaserPlayer/LaserLine2D
onready var ui: Control = $UI
onready var ui_units: VBoxContainer = $UI/Units
onready var ui_systems: HBoxContainer = $UI/Systems
onready var ui_doors: MarginContainer = $UI/Systems/Doors


func _ready() -> void:
	_rng.randomize()
	
	if ship_player.has_node("Shield"):
		var ui_shield := UISystem.instance()
		ui_shield.get_node("Button").text = "S"
		ui_systems.add_child(ui_shield)
	
	ui_doors.get_node("Button").connect("pressed", ship_player, "_on_UIDoorsButton_pressed")
	for weapon in ship_player.weapons.get_children():
		if weapon is WeaponProjectile:
			weapon.connect("projectile_exited", self, "_on_WeaponProjectile_projectile_exited")
			for room in ship_enemy.rooms.get_children():
				weapon.connect("targeting", room, "_on_WeaponProjectile_targeting")
				room.connect("targeted", weapon, "_on_Room_targeted")
		elif weapon is WeaponLaser:
			weapon.connect("targeting", self, "_on_WeaponLaser_targeting")
			weapon.connect("fire_started", self, "_on_WeaponLaser_fire_started")
			weapon.connect("fire_stopped", self, "_on_WeaponLaser_fire_stopped")
			weapon_laser_player_area.connect("area_entered", weapon, "_on_WeaponLaserPlayerArea_area_entered_exited", [true])
			weapon_laser_player_area.connect("area_exited", weapon, "_on_WeaponLaserPlayerArea_area_entered_exited", [false])
		
		if not ui_systems.has_node("Weapons"):
			ui_systems.add_child(UIWeapons.instance())
		
		var ui_weapon: VBoxContainer = UIWeapon.instance()
		ui_systems.get_node("Weapons").add_child(ui_weapon)
		weapon.setup(ui_weapon)
	
	for unit in ship_player.units.get_children():
		var ui_unit: ColorRect = UIUnit.instance()
		ui_units.add_child(ui_unit)
		unit.setup(ui_unit)


# Spawn a projectile shot by the player into the enemy viewport
func _on_WeaponProjectile_projectile_exited(physics_layer: int, target_global_position: Vector2) -> void:
	spawner.unit_offset = _rng.randf()
	var direction: Vector2 = (target_global_position - spawner.global_position).normalized()
	var projectile: RigidBody2D = Projectile.instance()
	projectile.collision_layer = physics_layer
	projectile.global_position = spawner.global_position
	projectile.linear_velocity = direction * projectile.linear_velocity.length()
	projectile.rotation = direction.angle()
	projectiles.add_child(projectile)
	projectile.setup(_rng, target_global_position)


func _on_WeaponLaser_targeting(points: PoolVector2Array) -> void:
	points = viewport_container.get_global_transform().xform_inv(points)
	weapon_laser_player_shape.a = points[0]
	weapon_laser_player_shape.b = points[1]


func _on_WeaponLaser_fire_started(points: PoolVector2Array, duration: float) -> void:
	points = viewport_container.get_global_transform().xform_inv(points)
	spawner.unit_offset = _rng.randf()
	_swipe_laser_start = spawner.global_position
	tween.interpolate_method(self, "_swipe_laser", points[0], points[1], duration)
	tween.start()


func _on_WeaponLaser_fire_stopped() -> void:
	weapon_laser_player_line.points = []
	tween.stop_all()


func _swipe_laser(offset: Vector2) -> void:
	weapon_laser_player_line.points = [_swipe_laser_start, offset]
