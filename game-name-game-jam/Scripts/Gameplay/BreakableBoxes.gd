extends CharacterBody2D

@export var particles : PackedScene

func _onDeath(_damage: float):
	call_deferred("_spawnParticles")
	queue_free()

func _spawnParticles():
	pass
