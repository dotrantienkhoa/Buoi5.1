class_name EnemyStateThrown
extends EnemyState

const BASE_THROW_SPEED := 7.0
const THROW_ARC_SPEED := 5.0

var _throw_dir: Vector3 = Vector3.ZERO
var _charge_ratio: float = 1.0
var _hit_area: HitArea3D = null

func setup_throw(dir: Vector3, charge: float) -> void:
	_throw_dir = dir
	_charge_ratio = charge

func _enter() -> void:
	obj.movement_enabled = true
	
	obj.velocity = _throw_dir * (BASE_THROW_SPEED * _charge_ratio)
	obj.velocity.y = THROW_ARC_SPEED * sqrt(_charge_ratio)
	
	_create_hit_area()
	
	obj.change_animation("run")

func _exit() -> void:
	_remove_hit_area()

func _update(delta: float) -> void:
	if not obj.is_on_floor():
		obj.velocity.y -= obj.gravity * delta
	
	if obj.is_on_floor() and obj.velocity.y <= 0:
		change_state(fsm.states.run if fsm.states.has("run") else fsm.default_state)

func _create_hit_area() -> void:
	_hit_area = HitArea3D.new()
	_hit_area.name = "ThrowHitArea3D"
	_hit_area.damage = 2
	_hit_area.collision_layer = 0
	_hit_area.collision_mask = 16
	
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.6
	shape.shape = sphere
	shape.position.y = 0.5
	_hit_area.add_child(shape)
	
	_hit_area.hitted.connect(_on_hitted)
	obj.add_child(_hit_area)

func _remove_hit_area() -> void:
	if _hit_area != null:
		_hit_area.queue_free()
		_hit_area = null

func _on_hitted(_area: Area3D) -> void:
	if obj.anim_player.has_animation("hurt_down"):
		obj.change_animation("hurt")
	
	obj.velocity.x *= 0.2
	obj.velocity.z *= 0.2
