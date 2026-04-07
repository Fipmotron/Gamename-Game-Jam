extends Sprite2D

@onready var animationPlayer := $AnimationPlayer

func _ready() -> void:
	animationPlayer.play("Animation")

func _onFinish(_anim_name: StringName) -> void:
	queue_free()
