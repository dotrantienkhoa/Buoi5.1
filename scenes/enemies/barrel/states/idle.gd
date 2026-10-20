extends EnemyState

@export var shoot_interval: float = 1.5

func _enter() -> void:
	obj.change_animation("idle")
	timer = shoot_interval

func _update(delta: float) -> void:
	if obj.found_player != null:
		obj.change_direction(BaseCharacter.direction_to(
			obj.global_position, obj.found_player.global_position))
		
		if update_timer(delta):
			change_state(fsm.states.shoot)
	else:
		timer = shoot_interval
