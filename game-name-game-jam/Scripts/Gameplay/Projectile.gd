extends CharacterBody2D

class_name Projectile

@export var deathSFX : PackedScene

@export_category("References")
@onready var sprite := $Sprite2D
@onready var explodeIndicator := $ExplodeIndicator
@onready var hitBox := $HitboxComponent

@export_category("Bomb")
@export var persistTime : float
var persistTimer : float
var explodeTimer : float

@export_category("Particles")
@export var deathParticles : PackedScene

var shooter : Enemy

func _physics_process(delta: float) -> void:
	if explodeTimer > 0.0:
		explodeTimer -= delta
		
		if explodeTimer <= 0.0:
			_explode()
	
	if persistTimer > 0.0:
		persistTimer -= delta
		
		if persistTimer <= 0.0:
			_destroy()

func _explode():
	sprite.visible = false
	explodeIndicator.visible = false
	hitBox.get_child(0).disabled = false
	persistTimer = persistTime
	call_deferred("_spawnDeathParticles")
	
	const SHAKE_STRENGTH = 20.0
	const SHAKE_TIME = 0.1
	const SHAKE_DECAY = 5.0
	
	SignalManager.emit_signal("shakeScreen", SHAKE_STRENGTH, SHAKE_TIME, SHAKE_DECAY)

func _destroy():
	queue_free()

func _spawnDeathParticles():
	var particle = deathParticles.instantiate()
	get_tree().root.add_child(particle)
	particle.global_position = global_position
	
	var sfx = deathSFX.instantiate()
	sfx.pitch_scale = randf_range(0.75, 1.25)
	get_tree().root.add_child(sfx)
	sfx.global_position = global_position 
