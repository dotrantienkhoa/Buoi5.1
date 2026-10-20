extends EnemyState

var _dropped: bool = false
var _drop_delay: float = 0.4

func _enter() -> void:
	obj.change_animation("atk")
	_dropped = false
	timer = 0.6

func _update(delta: float) -> void:
	var step: Vector3 = obj.forward() * (obj.movement_speed * 0.5)
	obj.velocity.x = step.x
	obj.velocity.z = step.z
	obj.velocity.y = 0.0

	if not _dropped and timer <= (0.6 - _drop_delay):
		obj.drop_bullet()
		_dropped = true

	if update_timer(delta):
		change_state(fsm.states.fly)
