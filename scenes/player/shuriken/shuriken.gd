class_name Sword
extends CharacterBody3D

enum State { FLYING, DROPPED }

@export var fly_speed: float = 14.0
@export var max_fly_distance: float = 9.0
@export var spin_speed: float = 15.0
@export var damage: int = 1

var state: State = State.FLYING
var fly_direction: Vector3 = Vector3.ZERO
var _distance_traveled: float = 0.0

@onready var sprite: Sprite3D = $Sprite3D
@onready var hit_area: HitArea3D = $HitArea3D
@onready var pickup_area: Area3D = $PickupArea3D

func _ready() -> void:
	if sprite:
		sprite.rotation_degrees = Vector3(-45.0, 0.0, 0.0)
	if hit_area:
		hit_area.damage = damage
		hit_area.hitted.connect(_on_hit_target)
	if pickup_area:
		pickup_area.body_entered.connect(_on_pickup_body_entered)

func launch(direction: Vector3) -> void:
	fly_direction = direction.normalized()
	state = State.FLYING
	_distance_traveled = 0.0
	velocity = fly_direction * fly_speed

func _physics_process(delta: float) -> void:
	match state:
		State.FLYING:
			if sprite:
				sprite.rotate_object_local(Vector3.FORWARD, spin_speed * delta)
				
			var move_step := velocity * delta
			var collision := move_and_collide(move_step)
			_distance_traveled += move_step.length()
			
			if collision != null or _distance_traveled >= max_fly_distance:
				drop_to_ground()
				
		State.DROPPED:
			if not is_on_floor():
				velocity.y -= 24.0 * delta
				move_and_slide()
			else:
				velocity = Vector3.ZERO
				
			if sprite:
				sprite.position.y = 0.2 + sin(Time.get_ticks_msec() * 0.006) * 0.05

func drop_to_ground() -> void:
	if state == State.DROPPED:
		return
	state = State.DROPPED
	velocity = Vector3.DOWN * 2.0
	
	if hit_area:
		hit_area.set_deferred("monitoring", false)
		hit_area.set_deferred("monitorable", false)
		var shape := hit_area.get_node_or_null("CollisionShape3D") as CollisionShape3D
		if shape:
			shape.set_deferred("disabled", true)
			
	if sprite:
		sprite.rotation_degrees = Vector3(-45.0, 0.0, -45.0)

func _on_hit_target(_area: Area3D) -> void:
	drop_to_ground()

func _on_pickup_body_entered(body: Node3D) -> void:
	if state != State.DROPPED:
		return
	if body.has_method("pick_up_sword"):
		body.pick_up_sword()
		queue_free()
