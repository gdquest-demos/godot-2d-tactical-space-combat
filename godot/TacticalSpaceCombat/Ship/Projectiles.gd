extends Node2D

const Projectile = preload("Weapons/Projectile.tscn")

var _rng := RandomNumberGenerator.new()
var _mean_position := Vector2.INF


func setup(mean_position: Vector2) -> void:
	_mean_position = mean_position


func _ready() -> void:
	_rng.randomize()


func _on_Weapon_projectile_exited(params: Dictionary) -> void:
	var projectile: RigidBody2D = Projectile.instance()
	var spawn_position := _mean_position + Utils.randvf_circle(_rng, projectile.MAX_DISTANCE)
	var direction: Vector2 = (params.target_position - spawn_position).normalized()
	projectile.collision_layer = params.physics_layer
	projectile.position = spawn_position
	projectile.linear_velocity = direction * projectile.linear_velocity.length()
	projectile.rotation = direction.angle()
	projectile.max_distance *= 2
	projectile.params = params
	add_child(projectile)
