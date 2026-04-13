extends Area2D

@export var sfx : PackedScene

func _onEntered(_area: Area2D) -> void:
	SignalManager.emit_signal("endLevel")
	print("LEVEL END")
	
	var _sfx = sfx.instantiate()
	_sfx.pitch_scale = randf_range(0.75, 1.25)
	get_tree().root.add_child(_sfx)
	_sfx.global_position = global_position 
	
	queue_free()
