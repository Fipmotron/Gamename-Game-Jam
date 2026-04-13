extends State

# Called once at the end of a state transition
func _enter(_host : Node):
	pass

# Called with every physics tick
func _step(host : Node, delta : float):
	host._flowHandler(delta)
	host._directionHandler()
	host._spriteFlipper()
	host._baseMovement(delta)
	host._groundCheck(delta)
	host._jumpCheck(delta)
	host._gravity()
	host._dashCheck(delta)
	host._dashRecovery()
	host._boostDecay()
	host._lookaheadHandler(delta)
	host._basicAttackCheck()
	host._basicAttackHandler(delta)
	host._flowAttackCheck(delta)
	host._attackRefresh(delta)
	host._spriteReform(delta)
	host._parryCheck(delta)
	host._afterImageUpdater()
	host._slideCall()
	
	if not host.isAttacking:
		if host.direction != 0.0:
			host._animRun()
		else:
			host._animIdle()
	
	
	if host.isDead:
		return "Death"
	elif host.isInCutscene:
		return "Cutscene"
	elif host.isParrying:
		return "Parry"
	elif host.isFlowAttacking:
		return "Flowing"
	elif host.isDashing:
		return "Dashing"
	elif host.isJumping or host.coyoteTimer <= 0.0:
		return "Airborne"

# Called once at the beginning of a state transition
func _exit(_host):
	pass
