extends EnemyState

@export var shoot_delay: float = 0.2
@export var burst_interval: float = 0.2
@export var burst_angles: Array[float] = [-20.0, 0.0, 20.0]
@export var lock_aim: bool = true

var _fire_timer: float = 0.0
var _shots_fired: int = 0
var _base_target_dir: Vector3 = Vector3.ZERO

func _enter() -> void:
	obj.change_animation("shoot")
	obj.stop_move()
	_shots_fired = 0
	_fire_timer = shoot_delay
	
	if lock_aim and obj.found_player != null:
		_base_target_dir = obj.found_player.global_position - obj.bullet_factory.global_position
		_base_target_dir.y = 0.0
		_base_target_dir = _base_target_dir.normalized()
	else:
		_base_target_dir = Vector3.ZERO

	var anim_name: String = "shoot_%s" % obj.direction
	var anim_len: float = 0.6
	if obj.anim_player.has_animation(anim_name):
		anim_len = obj.anim_player.get_animation(anim_name).length

	var burst_time: float = shoot_delay + (burst_angles.size() - 1) * burst_interval + 0.3
	timer = maxf(anim_len, burst_time)

func _update(delta: float) -> void:
	if _shots_fired < burst_angles.size():
		_fire_timer -= delta
		if _fire_timer <= 0.0:
			var angle: float = burst_angles[_shots_fired]
			obj.fire(angle, _base_target_dir)
			_shots_fired += 1
			_fire_timer = burst_interval
	
	if update_timer(delta):
		change_state(fsm.states.idle)
