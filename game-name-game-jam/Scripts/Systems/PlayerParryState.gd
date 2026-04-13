extends Node

# Called once at the end of a state transition
func _enter(host : Node):
	host._resetVelocity()
	host._animParry()

# Called with every physics tick
func _step(host : Node, delta : float):
	host._flowHandler(delta)
	host._parryHandler(delta)
	host._spriteReform(delta)
	host._lookaheadHandler(delta)
	host._afterImageUpdater()
	host._slideCall()
	
	if host.isDead:
		return "Death"
	elif not host.isParrying:
		if host.is_on_floor():
			return "Grounded"
		else:
			return "Airborne"

# Called once at the beginning of a state transition
func _exit(host):
	host._parryBoost()
