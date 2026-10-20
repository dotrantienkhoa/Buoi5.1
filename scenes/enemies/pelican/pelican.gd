class_name Pelican
extends EnemyCharacter

@export var patrol_distance: float = 6.0
@export var bullet_drop_speed: float = 2.0

@onready var bullet_factory: Node3DFactory = $Direction/BulletFactory
var start_x: float = 0.0

func _ready() -> void:
	gravity = 0.0
	start_x = global_position.x
	fsm = FSM.new(self, $States, $States/Fly)
	super._ready()

func drop_bullet() -> void:
	if bullet_factory != null:
		var bullet := bullet_factory.create() as RigidBody3D
		if bullet != null:
			bullet.apply_impulse(Vector3.DOWN * bullet_drop_speed)
