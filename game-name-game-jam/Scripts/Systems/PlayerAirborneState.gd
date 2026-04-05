extends State

# Called once at the end of a state transition
func _enter(host : Node):
	host.set_floor_snap_length(0.0)

# Called with every physics tick
func _step(host : Node, delta : float):
	host._flowHandler(delta)
	host._directionHandler()
	host._baseMovement(delta)
	host._jumpHandler(delta)
	host._doubleJumpCheck()
	host._gravity()
	host._dashCheck(delta)
	host._dashRecovery()
	host._stompCheck()
	host._stompDecay()
	host._lookaheadHandler(delta)
	host._basicAttackCheck()
	host._basicAttackHandler(delta)
	host._flowAttackCheck(delta)
	host._attackRefresh(delta)
	host._slideCall()
	
	if host.isFlowAttacking:
		return "Flowing"
	elif host.isStomping:
		return "Stomping"
	elif host.isDashing:
		return "Dashing"
	elif host.is_on_floor():
		return "Grounded"

# Called once at the beginning of a state transition
func _exit(host):
	host.set_floor_snap_length(1.0)
