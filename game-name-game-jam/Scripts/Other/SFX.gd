extends AudioStreamPlayer2D

func _onFinish():
	queue_free()
