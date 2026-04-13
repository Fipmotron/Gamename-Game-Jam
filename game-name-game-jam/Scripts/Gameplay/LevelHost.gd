extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.connect("restartLevel", Callable(self, "_restart"))

func _restart():
	await get_tree().create_timer(0.5).timeout
	get_tree().reload_current_scene()
