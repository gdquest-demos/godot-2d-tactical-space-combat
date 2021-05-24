extends Node2D

const Projectile = preload("Projectile.tscn")

var _rng := RandomNumberGenerator.new()
var _spawner: Path2D = null


func setup(spawner: Path2D) -> void:
	_spawner = spawner


func _ready() -> void:
	_rng.randomize()


func _on_Weapon_projectile_exited(physics_layer: int, params: Dictionary) -> void:
	var spawn_position: Vector2 = _spawner.interpolate(_rng.randf())
	var direction: Vector2 = (params.target_position - spawn_position).normalized()
	var projectile: RigidBody2D = Projectile.instance()
	projectile.collision_layer = physics_layer
	projectile.position = spawn_position
	projectile.linear_velocity = direction * projectile.linear_velocity.length()
	projectile.rotation = direction.angle()
	projectile.params = params
	add_child(projectile)
