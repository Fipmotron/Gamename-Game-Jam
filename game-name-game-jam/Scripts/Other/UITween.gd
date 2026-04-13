extends Control

@export var changePosition : Vector2
@export var textChangePosition : Vector2
var startPosition : Vector2
var state := 0

func _ready() -> void:
	startPosition = position

func _tween():
	match state:
		1:
			var tween = create_tween()
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.set_trans(Tween.TRANS_BACK)
			tween.tween_property(self, "global_position", startPosition, 0.25)
			state = 0
		0:
			var tween = create_tween()
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.set_trans(Tween.TRANS_BACK)
			tween.tween_property(self, "global_position", changePosition, 0.25)
			state = 1


func _onButtonPress() -> void:
	var text = get_node("Label")
	
	var textStartPosition = text.position
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(text, "position", textChangePosition, 0.1)
	await get_tree().create_timer(0.05).timeout
	var tween2 = create_tween()
	tween2.set_ease(Tween.EASE_IN_OUT)
	tween2.set_trans(Tween.TRANS_SINE)
	tween2.tween_property(text, "position", textStartPosition, 0.1)
