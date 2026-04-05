extends State

# Called once at the end of a state transition
func _enter(host : Node):
	host._disableBasicAttack()
	host._cancelFlowAttack()

# Called with every physics tick
func _step(host : Node, delta : float):
	host._flowHandler(delta)
	host._dashHandler(delta)
	host._lookaheadHandler(delta)
	host._slideCall()
	
	if not host.isDashing:
		if host.is_on_floor():
			return "Grounded"
		else:
			return "Airborne"

# Called once at the beginning of a state transition
func _exit(_host):
	pass
