class_name Fire
extends Hazard

signal attacked(attack, position)
signal spread(position)

export (float, 0.0, 1.0) var chance_attack := 0.1
export (float, 0.0, 1.0) var chance_spread := 0.05
export (int, 0, 100) var o2_damage := 30

var _rng := RandomNumberGenerator.new()

onready var timer: Timer = $Timer
onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	timer.connect("timeout", self, "_on_Timer_timeout")
	_rng.randomize()


func _on_Timer_timeout() -> void:
	if _rng.randf() < chance_attack:
		emit_signal("attacked", attack, position)

	if _rng.randf() < chance_spread:
		emit_signal("spread", position)


func _set_hitpoints(value: int) -> void:
	._set_hitpoints(value)

	var animation := "high"
	if _hitpoints < THRESHOLD.low:
		animation = "low"
	elif _hitpoints < THRESHOLD.medium:
		animation = "medium"

	if animation_player.current_animation != animation:
		animation_player.play(animation)
