extends Area2D

class_name Hitbox

@export_category("Base Varibles")
@export var damage : float
@export var knockbackForce : float
@export var instaKill : bool

func _onEnter(area: Area2D) -> void:
	if area.owner is Player:
		area.owner.flowState = 0.0
		area.owner._onDeath(0.0)
