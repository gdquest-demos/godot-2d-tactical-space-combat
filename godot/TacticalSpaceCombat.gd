extends Node2D

var _rng := RandomNumberGenerator.new()

onready var ship_player: Node2D = $ShipPlayer
onready var spawner: PathFollow2D = $ViewportContainer/Viewport/PathSpawner/Spawner
onready var projectiles: Node2D = $ViewportContainer/Viewport/Projectiles
onready var ui: Control = $UI


func _ready() -> void:
	_rng.randomize()

	var weapons: Array = ship_player.weapons.get_children()
	var units: Array = ship_player.get_units()
	ui.setup(weapons, units)

	for weapon in weapons:
		weapon.connect("projectile_exited_screen", self, "_on_Weapon_projectile_exited_screen")


func _on_Weapon_projectile_exited_screen(Projectile: PackedScene, target_global_position: Vector2) -> void:
	_spawn_projectile(Projectile, target_global_position)


func _spawn_projectile(Projectile: PackedScene, target_global_position: Vector2) -> void:
	spawner.unit_offset = _rng.randf()
	var direction: Vector2 = (target_global_position - spawner.global_position).normalized()
	var projectile: RigidBody2D = Projectile.instance()
	projectile.global_position = spawner.global_position
	projectile.linear_velocity = direction * projectile.linear_velocity.length()
	projectile.rotation = direction.angle()
	projectiles.add_child(projectile)
