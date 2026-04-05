extends State

# Called once at the end of a state transition
func _enter(_host : Node):
	pass

# Called with every physics tick
func _step(host : Node, delta : float):
	host._flowHandler(delta)
	host._directionHandler()
	host._baseMovement(delta)
	host._groundCheck(delta)
	host._jumpCheck(delta)
	host._gravity()
	host._dashCheck(delta)
	host._dashRecovery()
	host._stompDecay()
	host._lookaheadHandler(delta)
	host._basicAttackCheck()
	host._basicAttackHandler(delta)
	host._flowAttackCheck(delta)
	host._attackRefresh(delta)
	host._slideCall()
	
	if host.isFlowAttacking:
		return "Flowing"
	elif host.isDashing:
		return "Dashing"
	elif host.isJumping or host.coyoteTimer <= 0.0:
		return "Airborne"

# Called once at the beginning of a state transition
func _exit(_host):
	pass
