class_name Unit
extends KinematicBody

# signals

# enums
enum MOVEMENT_STATE {WANDER, CHASE}

# constants

# exported variables
export var team_id := "GOOD"
export var speed := 1

# variables
var _ignore
var movement_state = MOVEMENT_STATE.WANDER
var potential_targets := []
var target:KinematicBody = null
var _wander_timer_not_started := true
var _is_first_run := true

# onready variables
onready var sight_range := $Range


func _physics_process(delta:float)->void:
	var velocity = Vector2.LEFT*speed
	if movement_state == MOVEMENT_STATE.CHASE and target != null:
		look_at(target.transform.origin, Vector3.UP)
		rotation.y += PI
		velocity = velocity.rotated(0.25*TAU)
		if not _wander_timer_not_started:
			_wander_timer_not_started = true
	elif movement_state == MOVEMENT_STATE.WANDER and _wander_timer_not_started:
		$DirectionChangeTimer.start()
		_wander_timer_not_started = false
	velocity = velocity.rotated(rotation.y)
	velocity *= delta
	_ignore = move_and_collide(Vector3(velocity.x, 0, velocity.y))


func _on_Range_body_entered(body:Node)->void:
	if body.is_in_group("UNIT"):
		if body.team_id != team_id:
			potential_targets.append(body)
			if target == null:
				target = body


func _on_Range_body_exited(body:Node)->void:
	if potential_targets.has(body):
		potential_targets.erase(body)


func _on_DirectionChangeTimer_timeout()->void:
	if target != null:
		movement_state = MOVEMENT_STATE.CHASE
		$DirectionChangeTimer.stop()
	else:
		rotation.y = randf()*TAU
