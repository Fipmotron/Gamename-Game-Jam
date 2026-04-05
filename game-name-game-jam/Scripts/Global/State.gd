extends Node

class_name State

# Called once at the end of a state transition
func _enter(_host : Node):
	pass

# Called with every physics tick
func _step(_host : Node, _delta : float):
	pass

# Called once at the beginning of a state transition
func _exit(_host):
	pass
