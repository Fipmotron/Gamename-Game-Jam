extends Area2D

@export var sfx : PackedScene

@export var flowAmount : float
@export var particles : PackedScene

func _onEntered(area: Area2D) -> void:
	if area.owner is Player:
		area.owner.flowState += flowAmount
		
		call_deferred("_spawnParticles")
		
		queue_free()

func _spawnParticles():
	var _sfx = sfx.instantiate()
	_sfx.pitch_scale = randf_range(0.75, 1.25)
	get_tree().root.add_child(_sfx)
	_sfx.global_position = global_position 
