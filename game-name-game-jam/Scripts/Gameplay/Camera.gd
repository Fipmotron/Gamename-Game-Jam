extends Camera2D

@export var followNode : Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if followNode != null:
		global_position = followNode.global_position
