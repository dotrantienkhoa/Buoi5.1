extends PlayerState

func _enter() -> void:
	obj.change_animation("throw")
	obj.stop_horizontal()
	timer = 0.25

func _update(_delta: float) -> void:
	if update_timer(_delta):
		change_state(fsm.states.idle)
