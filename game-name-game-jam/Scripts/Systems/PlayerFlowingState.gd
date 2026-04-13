extends State

# Called once at the end of a state transition
func _enter(host : Node):
	host._disableBasicAttack()
	host._enableFlowHitbox()
	host._spriteFlipper()

# Called with every physics tick
func _step(host : Node, delta : float):
	host._flowHandler(delta)
	host._flowAttackHandler(delta)
	host._lookaheadHandler(delta)
	host._afterImageUpdater()
	host._spriteReform(10)
	host._slideCall()
	
	if host.isDead:
		return "Death"
	elif host.isInCutscene:
		return "Cutscene"
	elif not host.isFlowAttacking:
		if host.is_on_floor():
			return "Grounded"
		else:
			return "Airborne"

# Called once at the beginning of a state transition
func _exit(host):
	host._disableFlowHitbox()
