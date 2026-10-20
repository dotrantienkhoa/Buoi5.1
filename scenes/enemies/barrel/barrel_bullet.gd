extends RigidBody3D

@export var max_range: float = 8.0
@export var lifetime: float = 2.5

var _spawn_pos: Vector3
var _initialized: bool = false

func _ready() -> void:
	$HitArea3D.hitted.connect(_on_hitted)
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _physics_process(_delta: float) -> void:
	if not _initialized:
		_spawn_pos = global_position
		_initialized = true
		return

	if global_position.distance_to(_spawn_pos) >= max_range:
		queue_free()

func _on_hitted(_area: Area3D) -> void:
	queue_free()

func _on_body_entered(_body: Node3D) -> void:
	queue_free()
