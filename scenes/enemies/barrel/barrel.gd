extends EnemyCharacter

@export var bullet_speed: float = 12.0
@onready var bullet_factory: Node3DFactory = $Direction/BulletFactory

func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Idle)
	super._ready()

func fire(angle_offset_deg: float = 0.0, base_dir: Vector3 = Vector3.ZERO) -> void:
	var target_dir: Vector3 = base_dir
	if target_dir == Vector3.ZERO:
		if found_player != null:
			target_dir = found_player.global_position - bullet_factory.global_position
			target_dir.y = 0.0 
			target_dir = target_dir.normalized()
		else:
			target_dir = forward()

	var shoot_dir: Vector3 = target_dir.rotated(Vector3.UP, deg_to_rad(angle_offset_deg))
	var bullet := bullet_factory.create() as RigidBody3D
	if bullet != null:
		bullet.apply_impulse(shoot_dir * bullet_speed)
