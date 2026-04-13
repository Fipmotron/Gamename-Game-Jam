extends CharacterBody2D

@export var sfx : PackedScene
@export var particles : PackedScene

func _onDeath(_damage: float):
	const SHAKE_STRENGTH = 10.0
	const SHAKE_TIME = 0.1
	const SHAKE_DECAY = 5.0
	
	call_deferred("_spawnParticles")
	SignalManager.emit_signal("shakeScreen", SHAKE_STRENGTH, SHAKE_TIME, SHAKE_DECAY)
	queue_free()

func _spawnParticles():
	var _sfx = sfx.instantiate()
	_sfx.pitch_scale = randf_range(0.75, 1.25)
	get_tree().root.add_child(_sfx)
	_sfx.global_position = global_position 
