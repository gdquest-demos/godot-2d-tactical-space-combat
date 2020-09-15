extends Node2D


var _rng := RandomNumberGenerator.new()

onready var scene_tree: SceneTree = get_tree()
onready var ship_player: Node2D = $ShipPlayer
onready var ship_enemy: Node2D = $ViewportContainer/Viewport/ShipEnemy
onready var spawner: PathFollow2D = $ViewportContainer/Viewport/PathSpawner/Spawner
onready var projectiles: Node2D = $ViewportContainer/Viewport/Projectiles
onready var ui: Control = $UI


func _ready() -> void:
	_rng.randomize()
	
	var weapons: Array = ship_player.weapons.get_children()
	ui.setup(weapons)
	for weapon in weapons:
		weapon.connect("projectile_exited", self, "_on_Weapon_projectile_exited")

	for unit in ship_player.units.get_children():
		var ui_unit: ColorRect = ui.Unit.instance()
		ui_unit.connect("selected", self, "_on_UIUnit_selected")
		ui_unit.connect("selected", unit, "set_is_selected", [true])
		unit.connect("selected", ui_unit, "_on_Unit_selected")
		ui.units.add_child(ui_unit)
		ui_unit.setup(unit.colors.default)


func _on_Weapon_projectile_exited(Projectile: PackedScene, target_global_position: Vector2) -> void:
	spawner.unit_offset = _rng.randf()
	var direction: Vector2 = (target_global_position - spawner.global_position).normalized()
	var projectile: RigidBody2D = Projectile.instance()
	projectile.global_position = spawner.global_position
	projectile.linear_velocity = direction * projectile.linear_velocity.length()
	projectile.rotation = direction.angle()
	projectiles.add_child(projectile)


func _on_UIUnit_selected() -> void:
	for unit in ship_player.units.get_children():
		unit.is_selected = false
