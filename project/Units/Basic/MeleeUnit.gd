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


func _process(_delta:float)->void:
	if movement_state == MOVEMENT_STATE.DEAD:
		return
	if can_hit and not is_cooling_down:
		var damage_dealt = damage
		if effective_attack_against.has(target.unit_name.to_upper()):
			damage_dealt *= 2
		target.hit(damage_dealt, unit_name)
		is_cooling_down = true
		$AttackDelayTimer.start(swing_delay)
	if movement_state == MOVEMENT_STATE.WANDER:
		$AttackDelayTimer.stop()
		can_hit = false
		is_cooling_down = false


func _on_HitArea_body_entered(body:Node)->void:
	if movement_state != MOVEMENT_STATE.DEAD:
		if body == target:
			can_hit = true
			movement_state = MOVEMENT_STATE.STATIONARY


func _on_HitArea_body_exited(body:Node)->void:
	if movement_state != MOVEMENT_STATE.DEAD:
		if body == target:
			can_hit = false
			movement_state = MOVEMENT_STATE.CHASE


func _on_AttackDelayTimer_timeout()->void:
	if movement_state == MOVEMENT_STATE.DEAD:
		$AttackDelayTimer.stop()
	else:
		is_cooling_down = false
