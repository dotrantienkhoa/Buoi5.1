extends PlayerState

const BASE_CARRY_SPEED_SCALE := 0.6
const LIFT_DURATION := 0.18
const MAX_CHARGE_TIME := 1.0

var _is_lifting: bool = false
var _lift_tween: Tween = null
var _charge_time: float = 0.0

func _enter() -> void:
	obj.stop_horizontal()
	_charge_time = 0.0
	_is_lifting = true
	
	obj.held.be_picked_up(obj.hold_point)
	
	_lift_tween = create_tween()
	_lift_tween.tween_property(obj.held, "position", Vector3.ZERO, LIFT_DURATION)
	_lift_tween.finished.connect(func(): _is_lifting = false)
	
	obj.change_animation("carry_idle")

func _exit() -> void:
	if _lift_tween != null and _lift_tween.is_valid():
		_lift_tween.kill()
	
	if obj.held != null:
		obj.held.be_dropped(obj.held.global_position)
		obj.held = null

func _update(delta: float) -> void:
	if _is_lifting:
		return
	
	if Input.is_action_pressed("carry"):
		_charge_time += delta
	
	if Input.is_action_just_released("carry"):
		var charge_ratio: float = clampf(1.0 + (_charge_time / MAX_CHARGE_TIME), 1.0, 2.0)
		obj.held.be_thrown(obj.forward(), charge_ratio)
		obj.held = null
		change_state(fsm.states.throw)
		return
	
	var weight_scale: float = 1.0
	if "carry_speed_scale" in obj.held:
		weight_scale = obj.held.carry_speed_scale
		
	var actual_speed: float = BASE_CARRY_SPEED_SCALE * weight_scale
	var is_moving := move_by_input(actual_speed)
	
	if is_moving:
		obj.change_animation("carry")
	else:
		obj.change_animation("carry_idle")
