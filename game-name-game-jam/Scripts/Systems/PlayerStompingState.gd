extends Node

# Called once at the end of a state transition
func _enter(host : Node):
	host._disableBasicAttack()
	host._cancelFlowAttack()

# Called with every physics tick
func _step(host : Node, delta : float):
	host._flowHandler(delta)
	host._directionHandler()
	host._stompHandler(delta)
	host._lookaheadHandler(delta)
	host._slideCall()
	
	if not host.isStomping:
		return "Grounded"

# Called once at the beginning of a state transition
func _exit(host):
	host._stompBoost()
