extends Area2D

class_name HealthComponent

@export_category("Base Varibles")
@export var maxHealth : float
@export var flowAmount : float
var health : float

@export_category("Signal Varibles")
@export var reciver : Node2D
signal hit
signal death

func _ready() -> void:
	if reciver != null:
		connect("hit", Callable(reciver, "_onHit"))
		connect("death", Callable(reciver, "_onDeath"))

func _onHit(area : Area2D):
	if area is Hitbox:
		health -= area.damage
		
		if health <= 0.0:
			emit_signal("death", area.damage)
		else:
			emit_signal("hit", area.damage)
