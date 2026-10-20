extends EnemyState

@export var drop_interval: float = 3.0
var _timer_drop: float = 0.0

func _enter() -> void:
	obj.change_animation("move")
	_timer_drop = drop_interval

func _update(delta: float) -> void:
	var step: Vector3 = obj.forward() * obj.movement_speed
	obj.velocity.x = step.x
	obj.velocity.z = step.z
	obj.velocity.y = 0.0
	
	if absf(obj.global_position.x - obj.start_x) >= obj.patrol_distance:
		if obj.global_position.x > obj.start_x and obj.direction == "right":
			obj.change_direction("left")
		elif obj.global_position.x < obj.start_x and obj.direction == "left":
			obj.change_direction("right")

	if obj.is_touch_wall():
		obj.turn_around()

	_timer_drop -= delta
	if _timer_drop <= 0.0 or (obj.found_player != null and _timer_drop <= drop_interval - 1.0):
		change_state(fsm.states.shoot)
