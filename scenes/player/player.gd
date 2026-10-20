class_name Player
extends BaseCharacter

var is_invulnerable: bool = false

@onready var hold_point: Marker3D = $HoldPoint
@onready var grab_area: Area3D = $Direction/GrabArea3D
var held: BaseCharacter = null
@export var has_sword: bool = true
@export var fall_limit_y: float = -8.0
@export var fall_damage: int = 1
@export var respawn_at_last_safe_ground: bool = true

var spawn_position: Vector3 = Vector3.ZERO
var last_safe_position: Vector3 = Vector3.ZERO
var _safe_ground_timer: float = 0.0
var _invulnerability_tween: Tween = null

func _ready() -> void:
	spawn_position = global_position
	last_safe_position = global_position
	fsm = FSM.new(self, $States, $States/Idle)
	super._ready()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if is_on_floor():
		_safe_ground_timer += delta
		if _safe_ground_timer >= 0.2:
			last_safe_position = global_position
	else:
		_safe_ground_timer = 0.0
		
	if global_position.y < fall_limit_y and fsm.current_state != fsm.states.dead:
		respawn()

func respawn() -> void:
	if fall_damage > 0:
		take_damage(fall_damage)
		if health <= 0:
			movement_enabled = false
			velocity = Vector3.ZERO
			stop_move()
			if held != null:
				held.be_dropped(global_position)
				held = null
			fsm.change_state(fsm.states.dead)
			return

	velocity = Vector3.ZERO
	stop_move()
	
	if held != null:
		held.be_dropped(global_position)
		held = null
		
	has_sword = true
	
	var target_pos := last_safe_position if (respawn_at_last_safe_ground and last_safe_position != Vector3.ZERO) else spawn_position
	global_position = target_pos + Vector3.UP * 0.1
	
	var stage := find_parent("Stage")
	if stage:
		var camera_rig := stage.find_child("CameraRig", true, false) as CameraRig
		if camera_rig and camera_rig.has_method("_snap_to_target"):
			camera_rig._snap_to_target()
			
	fsm.change_state(fsm.states.idle)
	_trigger_respawn_invulnerability()

func _trigger_respawn_invulnerability(duration: float = 1.5) -> void:
	is_invulnerable = true
	if _invulnerability_tween and _invulnerability_tween.is_valid():
		_invulnerability_tween.kill()
	if sprite:
		sprite.modulate.a = 1.0
		
	_invulnerability_tween = create_tween()
	var loops := 6
	var step_time := duration / (loops * 2.0)
	for i in range(loops):
		_invulnerability_tween.tween_property(sprite, "modulate:a", 0.3, step_time)
		_invulnerability_tween.tween_property(sprite, "modulate:a", 1.0, step_time)
	_invulnerability_tween.finished.connect(func():
		is_invulnerable = false
		if sprite:
			sprite.modulate.a = 1.0
	)

func throw_sword() -> void:
	if not has_sword:
		return
	has_sword = false
	var sword_scene: PackedScene = preload("res://scenes/player/shuriken/shuriken.tscn")
	var sword: Node3D = sword_scene.instantiate()
	
	var stage := find_parent("Stage")
	var container := stage.find_child("Bullets", true, false) if stage else null
	if container != null:
		container.add_child(sword)
	else:
		get_parent().add_child(sword)
		
	sword.global_position = global_position + Vector3.UP * 0.8 + forward() * 0.4
	if sword.has_method("launch"):
		sword.launch(forward())

func pick_up_sword() -> void:
	has_sword = true


func _on_hurt_area_3d_hurt(_direction: Vector3, damage: float) -> void:
	if is_invulnerable:
		return
	fsm.current_state.take_damage(int(damage))

## Tìm vật thể gần nhất trong phạm vi GrabArea3D có thể nhấc được
func get_grab_target() -> BaseCharacter:
	if grab_area == null:
		return null
		
	var bodies := grab_area.get_overlapping_bodies()
	var closest_target: BaseCharacter = null
	var min_distance: float = INF
	
	for body in bodies:
		if body is BaseCharacter and body.can_be_carried():
			var dist := global_position.distance_to(body.global_position)
			if dist < min_distance:
				min_distance = dist
				closest_target = body
				
	return closest_target
