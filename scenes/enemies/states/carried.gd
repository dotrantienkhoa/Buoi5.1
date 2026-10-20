class_name EnemyStateCarried
extends EnemyState

var _orig_layer: int = 0
var _orig_mask: int = 0

func _enter() -> void:
	obj.movement_enabled = false
	obj.stop_move()
	
	_orig_layer = obj.collision_layer
	_orig_mask = obj.collision_mask
	obj.collision_layer = 0
	obj.collision_mask = 0
	
	if obj.anim_player.has_animation("hurt_down"):
		obj.change_animation("run")

func _exit() -> void:
	obj.movement_enabled = true
	obj.collision_layer = _orig_layer
	obj.collision_mask = _orig_mask
