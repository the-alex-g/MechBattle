extends Unit

# signals

# enums

# constants

# exported variables
export var damage := 5
export var swing_delay := 1

# variables
var can_hit := false
var is_cooling_down := false

# onready variables
onready var _cooldown_timer = $AttackDelayTimer as Timer


func _process(_delta:float)->void:
	if is_dead or not active: # if dead, do nothing
		return
	
	if can_hit and not is_cooling_down:
		var damage_dealt = damage
		if effective_attack_against.has(target.unit_name.to_upper()):
			damage_dealt *= 2
		target.hit(damage_dealt, unit_name)
		is_cooling_down = true
		_cooldown_timer.start(swing_delay)
	
	if movement_state == MOVEMENT_STATE.WANDER:
		_cooldown_timer.stop()
		can_hit = false
		is_cooling_down = false


func _on_HitArea_body_entered(body:Node)->void:
		if body == target and not is_dead:
			can_hit = true
			movement_state = MOVEMENT_STATE.STATIONARY


func _on_HitArea_body_exited(body:Node)->void:
		if body == target and not is_dead:
			can_hit = false
			movement_state = MOVEMENT_STATE.CHASE


func _on_AttackDelayTimer_timeout()->void:
	if is_dead or not active:
		_cooldown_timer.stop()
		# if you're dead, stop the timer
	else:
		# otherwise, you can hit again
		is_cooling_down = false
