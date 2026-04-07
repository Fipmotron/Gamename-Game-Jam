extends Area2D

@export var flowAmount : float
@export var particles : PackedScene

func _onEntered(area: Area2D) -> void:
	if area.owner is Player:
		area.owner.flowState += flowAmount
		
		call_deferred("_spawnParticles")
		
		queue_free()

func _spawnParticles():
	pass
