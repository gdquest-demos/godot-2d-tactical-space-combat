extends Node2D

const Projectile = preload("Projectile.tscn")

var _rng := RandomNumberGenerator.new()
var _mean_position := Vector2.ZERO
#var _spawner: Path2D = null


func setup(mean_position: Vector2) -> void:
#func setup(spawner: Path2D) -> void:
#	_spawner = spawner
	_mean_position = mean_position


func _ready() -> void:
	_rng.randomize()


func _on_Weapon_projectile_exited(physics_layer: int, params: Dictionary) -> void:
	var projectile: RigidBody2D = Projectile.instance()
	var spawn_position := Utils.randvf_circle(_rng, projectile.MAX_DISTANCE)
	var direction: Vector2 = (params.target_position - spawn_position).normalized()
	projectile.collision_layer = physics_layer
	projectile.position = spawn_position
	projectile.linear_velocity = direction * projectile.linear_velocity.length()
	projectile.rotation = direction.angle()
	projectile.params = params
	add_child(projectile)
