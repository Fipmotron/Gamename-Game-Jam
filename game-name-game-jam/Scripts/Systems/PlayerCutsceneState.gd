extends Node

# Called once at the end of a state transition
func _enter(host : Node):
	host._resetVelocity()

# Called with every physics tick
func _step(host : Node, _delta : float):
	host._spriteReform(10)
	
	if not host.isInCutscene:
		if host.is_on_floor():
			return "Grounded"
		else:
			return "Airborne"

# Called once at the beginning of a state transition
func _exit(_host):
	pass
