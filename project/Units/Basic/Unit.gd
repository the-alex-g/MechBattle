class_name Unit
extends KinematicBody

# signals
signal dead

# enums
enum MOVEMENT_STATE {WANDER, CHASE, STATIONARY, DEAD}

# constants

# exported variables
export var team_id := "GOOD"
export var unit_name := ""
export var effective_attack_against := [] # all uppercase
export var effective_defense_against := [] # all uppercase
export var speed := 1
export var health := 10

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
	if movement_state == MOVEMENT_STATE.DEAD or movement_state == MOVEMENT_STATE.STATIONARY:
		return
	var velocity = Vector2.ZERO
	if movement_state == MOVEMENT_STATE.CHASE and target != null:
		var target_position:Vector3 = target.get_global_transform().origin
		var vector := target_position-get_global_transform().origin
		look_at(target_position, Vector3.UP)
		rotation.y += 0.5*TAU
		vector = vector.normalized()
		velocity = Vector2(vector.x, vector.z)
	elif movement_state == MOVEMENT_STATE.WANDER:
		if _wander_timer_not_started:
			print("OVERRIDE")
			$DirectionChangeTimer.start()
			_wander_timer_not_started = false
		velocity = Vector2.LEFT
		velocity = velocity.rotated(rotation.y)
	velocity *= delta*speed
	_ignore = move_and_collide(Vector3(velocity.x, 0, velocity.y))


func _on_Range_body_entered(body:Node)->void:
	if body.is_in_group("UNIT"):
		if body.team_id != team_id:
			potential_targets.append(body)
			if target == null:
				target = body
				_ignore = body.connect("dead", self, "_on_target_dead")


func _on_target_dead()->void:
	target.disconnect("dead", self, "_on_target_dead")
	potential_targets.erase(target)
	if potential_targets.size() > 0:
		target = potential_targets[randi()%potential_targets.size()]
	else:
		target = null
		movement_state = MOVEMENT_STATE.WANDER
		_wander_timer_not_started = true


func _on_Range_body_exited(body:Node)->void:
	if potential_targets.has(body):
		potential_targets.erase(body)


func _on_DirectionChangeTimer_timeout()->void:
	if target != null:
		movement_state = MOVEMENT_STATE.CHASE
		$DirectionChangeTimer.stop()
	else:
		rotation.y = randf()*TAU


func hit(damage_taken:int, name_of_unit:String)->void:
	if effective_defense_against.has(name_of_unit.to_upper()):
		damage_taken /= 2
	health -= damage_taken
	if health <= 0:
		emit_signal("dead")
		movement_state = MOVEMENT_STATE.DEAD
