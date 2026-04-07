extends State

# Called once at the end of a state transition
func _enter(host : Node):
	host.set_floor_snap_length(0.0)

# Called with every physics tick
func _step(host : Node, delta : float):
	host._flowHandler(delta)
	host._directionHandler()
	host._spriteFlipper()
	host._spriteAirDeform()
	host._baseMovement(delta)
	host._jumpHandler(delta)
	host._doubleJumpCheck()
	host._gravity()
	host._dashCheck(delta)
	host._dashRecovery()
	host._stompCheck()
	host._boostDecay()
	host._lookaheadHandler(delta)
	host._basicAttackCheck()
	host._basicAttackHandler(delta)
	host._flowAttackCheck(delta)
	host._attackRefresh(delta)
	host._parryCheck(delta)
	host._slideCall()
	
	if not host.isAttacking:
		if !host.canDoubleJump:
			host._animDJump()
		elif host.isJumping:
			host._animJump()
		else:
			host._animFall()
	
	if host.isInCutscene:
		return "Cutscene"
	elif host.isParrying:
		return "Parry"
	elif host.isFlowAttacking:
		return "Flowing"
	elif host.isStomping:
		return "Stomping"
	elif host.isDashing:
		return "Dashing"
	elif host.is_on_floor():
		const SQUASH = 1.4
		const STRETCH = 0.6
		
		host._spriteDeform(SQUASH, STRETCH)
		host._spawnLandParticles()
		
		return "Grounded"

# Called once at the beginning of a state transition
func _exit(host):
	host.set_floor_snap_length(1.0)
