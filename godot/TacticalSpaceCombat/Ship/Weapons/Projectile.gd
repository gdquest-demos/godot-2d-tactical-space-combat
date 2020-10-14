extends RigidBody2D


const TARGET_RANGE := 5
const HIT_CHANCE := 0.75

var _rng: RandomNumberGenerator
var _target_global_position: Vector2


func setup(rng: RandomNumberGenerator, target_global_position: Vector2) -> void:
	_rng = rng
	_target_global_position = target_global_position
	set_process(true)


func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	if (
		(global_position - _target_global_position).length() < TARGET_RANGE
		and _rng.randf() < HIT_CHANCE
	):
		queue_free()
