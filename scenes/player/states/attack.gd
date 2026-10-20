extends PlayerState

const LUNGE_SPEED := 2.5 

func _enter() -> void:
	obj.change_animation("attack")
	
	var lunge: Vector3 = obj.forward() * LUNGE_SPEED
	obj.velocity.x = lunge.x
	obj.velocity.z = lunge.z
	
	_hit_shape().disabled = false
	
	obj.anim_player.animation_finished.connect(_on_animation_finished)

func _exit() -> void:
	obj.stop_horizontal()
	
	_hit_shape().disabled = true
	
	if obj.anim_player.animation_finished.is_connected(_on_animation_finished):
		obj.anim_player.animation_finished.disconnect(_on_animation_finished)

func _update(_delta: float) -> void:
	pass

func _on_animation_finished(_anim_name: StringName) -> void:
	change_state(fsm.previous_state)

func _hit_shape() -> CollisionShape3D:
	return obj.get_node("Direction/HitArea3D/CollisionShape3D")
