extends Area2D

class_name DetectionComponent

@export var reciver : Node2D

@export_category("Signals")
signal detected
signal undetected

func _ready() -> void:
	if reciver != null:
		connect("detected", Callable(reciver, "_onDetect"))
		connect("undetected", Callable(reciver, "_onUndetect"))

func _onDetection(area: Area2D) -> void:
	emit_signal("detected", area.owner)

func _onUndetected(area: Area2D) -> void:
	emit_signal("undetected", area.owner)
