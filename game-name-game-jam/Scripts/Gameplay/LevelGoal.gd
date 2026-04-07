extends Area2D

func _onEntered(_area: Area2D) -> void:
	SignalManager.emit_signal("endLevel")
	print("LEVEL END")
	
	queue_free()
