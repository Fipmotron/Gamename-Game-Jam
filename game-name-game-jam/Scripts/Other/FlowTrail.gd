extends Line2D

@export var time : float
var timer : float
var isDying : bool

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isDying:
		timer -= delta
		
		modulate.a = move_toward(modulate.a, 0.0, delta)
		
		if timer <= 0.0:
			queue_free()

func _startDeath():
	isDying = true
	timer = time
