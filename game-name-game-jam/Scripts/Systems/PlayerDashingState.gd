extends State

# Called once at the end of a state transition
func _enter(host : Node):
	host._disableBasicAttack()
	host._cancelFlowAttack()
	host._disableHealth()
	host._animDash()

# Called with every physics tick
func _step(host : Node, delta : float):
	host._flowHandler(delta)
	host._dashHandler(delta)
	host._lookaheadHandler(delta)
	host._spriteReform(delta)
	host._afterImageUpdater()
	host._slideCall()
	
	
	if host.isInCutscene:
		return "Cutscene"
	elif not host.isDashing:
		if host.is_on_floor():
			return "Grounded"
		else:
			return "Airborne"

# Called once at the beginning of a state transition
func _exit(host):
	host._enableHealth()
