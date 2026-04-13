extends State

# Called once at the end of a state transition
func _enter(host : Node):
	host._resetVelocity()
	host._disableAfterImage()
	host._spriteInvisible()
	host._spawnDeathParticles()

# Called with every physics tick
func _step(host : Node, delta : float):
	host._deathHandler(delta)

# Called once at the beginning of a state transition
func _exit(_host):
	pass
