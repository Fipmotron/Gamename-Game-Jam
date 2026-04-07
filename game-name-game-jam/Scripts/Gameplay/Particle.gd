extends GPUParticles2D

func _ready() -> void:
	emitting = true

func _onFinished() -> void:
	queue_free()
