class_name Unit
extends KinematicBody

# signals
signal dead

# enums
enum MOVEMENT_STATE {WANDER, CHASE, STATIONARY}

# constants

# exported variables
export var team_id := "GOOD"
export var unit_name := ""
export var id := ""
export var effective_attack_against := [] # all uppercase
export var effective_defense_against := [] # all uppercase
export var speed := 1
export var health := 10

# variables
var _ignore
var movement_state = MOVEMENT_STATE.WANDER
var target:KinematicBody = null
var _wander_timer_not_started := true
var _is_first_run := true
var is_dead := false
var active := false

# onready variables
onready var _sight_range = $Range as Area
onready var _wander_timer = $DirectionChangeTimer as Timer
onready var _animation_player = $AnimationPlayer as AnimationPlayer


func _physics_process(delta:float)->void:
	if is_dead or not active or movement_state == MOVEMENT_STATE.STATIONARY:
		return
	
	var velocity = Vector2.ZERO
	
	if movement_state == MOVEMENT_STATE.CHASE and target != null:
		
		var target_position := target.get_global_transform().origin
		var position_difference := target_position - get_global_transform().origin
		
		look_at(target_position, Vector3.UP)
		rotation.y += TAU * 0.5
		position_difference = position_difference.normalized()
		velocity = Vector2(position_difference.x, position_difference.z)
		
	elif movement_state == MOVEMENT_STATE.WANDER:
		if _wander_timer_not_started:
			
			print(id + " start wandering")
			
			_wander_timer.start()
			_wander_timer_not_started = false
		
		velocity = Vector2.LEFT
		velocity = velocity.rotated(rotation.y)
	velocity *= delta*speed
	_ignore = move_and_collide(Vector3(velocity.x, 0, velocity.y))


func hit(damage_taken:int, name_of_unit:String)->void:
	if effective_defense_against.has(name_of_unit.to_upper()):
		damage_taken /= 2
	health -= damage_taken
	if health <= 0:
		emit_signal("dead")
		is_dead = true
		
		print(id + " is dead")
		
		_animation_player.play("Die")


func _on_Range_body_entered(body:Node)->void:
	if body.is_in_group("UNIT"):
		if body.team_id != team_id: # if the target is on a different team
			
			if target == null: # if you don't already have a target
				print(id + " target aquired: " + body.id)
				target = body
				_ignore = body.connect("dead", self, "_on_target_dead")
				
				movement_state = MOVEMENT_STATE.CHASE
				_wander_timer.stop()
				_wander_timer_not_started = true


func _on_target_dead()->void:
	print(id + " target defeated: " + target.id)
	
	target.disconnect("dead", self, "_on_target_dead")
	
	var overlapping_bodies:Array = _sight_range.get_overlapping_bodies()
	
	if overlapping_bodies.size() > 0:
		var potential_targets := []
		
		for body in overlapping_bodies:
			if body.is_in_group("UNIT"):
				if body.team_id != team_id and not body.is_dead:
					potential_targets.append(body)
		
		if potential_targets.size() > 0:
			var new_target_index = randi() % potential_targets.size()
			target = potential_targets[new_target_index]
			_ignore = target.connect("dead", self, "_on_target_dead")
			print(_ignore)
		
			print(id + " new target aquired: " + target.id)
	
		else:
			target = null
			movement_state = MOVEMENT_STATE.WANDER
	
	else:
		target = null
		movement_state = MOVEMENT_STATE.WANDER


func _on_DirectionChangeTimer_timeout()->void:
	rotation.y = randf()*TAU


func _on_game_start()->void:
	active = true
