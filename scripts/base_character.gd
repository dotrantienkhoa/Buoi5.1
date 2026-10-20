class_name BaseCharacter
extends CharacterBody3D

## Three conventions in this lesson:
##  - The facing direction is a string, one of "down"/"up"/"left"/"right".
##  - Sprite3D sits OUTSIDE the Direction node. Topdown expresses facing by switching
##    animations (suffixed _down/_left/_right/_up), without touching the parent node at all.
##  - Animation is driven by AnimationPlayer, not AnimatedSprite3D. Both the frame and the
##    Sprite3D.flip_h flip flag are keyed inside the animation; this script never touches
##    the sprite, it only picks the animation name.

## The Y-axis rotation of the Direction node for each facing direction. A character's front is its
## local +Z (Vector3.MODEL_FRONT) and the topdown camera sits toward +Z, so yaw 0 faces "down"
## (toward the camera) and PI faces "up".
const DIRECTION_YAW: Dictionary = {
	"up": PI,
	"left": -PI / 2,
	"down": 0.0,
	"right": PI / 2,
}

## The opposite direction, used by turn_around().
const OPPOSITE_DIRECTION: Dictionary = {
	"up": "down",
	"down": "up",
	"left": "right",
	"right": "left",
}

@export var movement_speed: float = 2.5
@export var gravity: float = 24.0
@export var direction: String = "down"

@export var attack_damage: int = 1
@export var max_health: int = 3
var health: int = max_health

## Turn off to make the character stand absolutely still: no gravity, no move_and_slide(). Used
## while it's being carried — as a child of HoldPoint it already follows the carrier; leaving
## gravity on would make it slip out of hand, and leaving move_and_slide() on would let its own FSM
## just walk it away right out of the carrier's hand.
var movement_enabled: bool = true

var jump_speed: float = 12.0
var fsm: FSM = null
var current_animation = null

@onready var sprite: Sprite3D = $Sprite3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var _next_animation = null
var _next_direction: String = "down"
var _played_direction: String = ""

func _ready() -> void:
	_next_direction = direction
	_apply_direction()

func _physics_process(delta: float) -> void:
	_check_changed_animation()

	if fsm != null:
		fsm._update(delta)
	_update_movement(delta)
	_check_changed_direction()


func _update_movement(delta: float) -> void:
	if not movement_enabled:
		return
	# Add the gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()

# Pick the facing direction from the input vector: whichever axis is stronger wins
static func direction_from_input(input: Vector2) -> String:
	if absf(input.x) > absf(input.y):
		return "right" if input.x > 0.0 else "left"
	return "down" if input.y > 0.0 else "up"

func turn_around() -> void:
	if _next_direction != direction:
		return
	_next_direction = OPPOSITE_DIRECTION[direction]

func is_left() -> bool:
	return direction == "left"

func is_right() -> bool:
	return direction == "right"

func turn_left() -> void:
	_next_direction = "left"

func turn_right() -> void:
	_next_direction = "right"

func turn_up() -> void:
	_next_direction = "up"

func turn_down() -> void:
	_next_direction = "down"

func jump() -> void:
	velocity.y = jump_speed

func stop_move() -> void:
	velocity = Vector3.ZERO

# Stop horizontal movement, keep the falling velocity as-is
func stop_horizontal() -> void:
	velocity.x = 0.0
	velocity.z = 0.0

func change_animation(new_animation: String) -> void:
	_next_animation = new_animation

func change_direction(new_direction: String) -> void:
	_next_direction = new_direction

# The actual animation name to run on AnimationPlayer, e.g. "run" + "left" -> "run_left"
func get_animation_name() -> String:
	if current_animation == null:
		return ""
	return "%s_%s" % [current_animation, direction]

func _check_changed_animation() -> void:
	var need_play: bool = false
	if _next_animation != current_animation:
		current_animation = _next_animation
		need_play = true
	# Changing direction must also replay the animation, since each direction is its own animation
	if direction != _played_direction:
		_played_direction = direction
		need_play = true
	if need_play and anim_player != null and current_animation != null:
		anim_player.play(get_animation_name())

func _check_changed_direction() -> void:
	if _next_direction != direction:
		direction = _next_direction
		_on_changed_direction()
		_apply_direction()

# Rotate the Direction node to the facing direction. The sprite doesn't need flipping here: the
# _left animation already keys flip_h = true, and _check_changed_animation() replays the animation
# on direction change.
func _apply_direction() -> void:
	$Direction.rotation.y = DIRECTION_YAW[direction]

func _on_changed_direction() -> void:
	pass


func take_damage(damage: int) -> void:
	health -= damage

## The facing vector, in the XZ plane. A character's front is its local +Z (Vector3.MODEL_FRONT),
## so rotating MODEL_FRONT around the Y axis by exactly the Direction node's yaw gives the facing.
##
## The 2D version could just write `obj.direction * speed` because direction was an int ±1. Here
## direction is a STRING, so anywhere that needs "move forward" has to call this function instead.
func forward() -> Vector3:
	return Vector3.MODEL_FRONT.rotated(Vector3.UP, DIRECTION_YAW[direction])

## The facing direction toward a position: whichever XZ axis has the larger difference wins. Same
## convention as direction_from_input(): +X is "right", +Z is "down". The difference along Y is
## ignored — an enemy standing at the foot of a platform should still turn to face the fox, not tilt
## up to the sky.
static func direction_to(from: Vector3, to: Vector3) -> String:
	var delta := to - from
	if absf(delta.x) > absf(delta.z):
		return "right" if delta.x > 0.0 else "left"
	return "down" if delta.z > 0.0 else "up"

## Can be picked up when it has both the Carried and Thrown states, and isn't currently in either
## one (something already being carried or already in flight can't be picked up again). To make
## anything pickable, just add those two states to it — no flag, no group needed.
func can_be_carried() -> bool:
	if fsm == null or not fsm.states.has("carried") or not fsm.states.has("thrown"):
		return false
	return fsm.current_state != fsm.states.carried and fsm.current_state != fsm.states.thrown
