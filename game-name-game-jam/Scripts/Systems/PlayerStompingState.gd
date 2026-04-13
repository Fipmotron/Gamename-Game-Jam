extends Node

# Called once at the end of a state transition
func _enter(host : Node):
	host._disableBasicAttack()
	host._cancelFlowAttack()
	host._enableStompAttack()

# Called with every physics tick
func _step(host : Node, delta : float):
	host._flowHandler(delta)
	host._directionHandler()
	host._stompHandler(delta)
	host._lookaheadHandler(delta)
	host._afterImageUpdater()
	host._slideCall()
	
	if host.isDead:
		return "Death"
	elif host.isInCutscene:
		return "Cutscene"
	elif not host.isStomping:
		return "Grounded"

# Called once at the beginning of a state transition
func _exit(host):
	host._stompBoost()
	host._disableStompAttack()
