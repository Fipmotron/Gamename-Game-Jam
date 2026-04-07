extends CharacterBody2D

class_name Enemy

@export_category("Component References")
@export var detectionComponent : DetectionComponent
@export var hitboxComponent : Hitbox
@export var healthComponent : HealthComponent

@export_category("Amimation Varibles")
@onready var animationTree := $AnimationPlayer/AnimationTree
var playedAttack : bool
var stateMachine

@export_category("Particle Varibles")
@export var idleParticles : PackedScene
@export var deathParticles : PackedScene

@export_category("Health Varibles")
@export var deleteOnDeath : bool
@export var respawnOnDeath : bool
@export var respawnTime : float
var respawnTimer : float
var isDead : bool

@export_category("Attack Varibles")
@export var attackOnDetect : bool
@export var attackOnTimer : bool
@export var attackDelayTime : float
@export var attackBuildupTime : float
@export var attackTime : float
@export var attackCooldownTime : float
var attackDelayTimer : float
var attackBuildupTimer : float
var attackTimer : float
var attackCooldownTimer : float
var canAttack : bool

@export_category("Projectile Varibles")
@export var projectileOnDetect : bool

@export_category("Detection Varibles")
@export var maintainDetection : bool
@export var detectionTime : float
var detectionTimer : float
var isDetected : bool
var wasDetected : bool
var detectionReference : Node2D

func _ready() -> void:
	attackDelayTimer = attackDelayTime
	stateMachine = animationTree.get("parameters/playback")

func _physics_process(delta: float) -> void:
	_attackHandler(delta)
	_respawnHandler(delta)

func _attackHandler(delta : float):
	if canAttack and not attackOnTimer and wasDetected or canAttack and isDetected or attackTimer > 0.0 or canAttack and attackDelayTimer <= 0.0:
		if not playedAttack:
			stateMachine.travel("Attack")
			playedAttack = true
		
		if attackBuildupTimer > 0.0:
			attackBuildupTimer -= delta
			
			if attackBuildupTimer <= 0.0:
				_startAttack()
		
		if attackTimer > 0.0:
			attackTimer -= delta
			
			if attackTimer <= 0.0:
				_endAttack()
	
	if attackCooldownTimer > 0.0:
		attackCooldownTimer -= delta
		
		if attackCooldownTimer <= 0.0:
			attackDelayTimer = attackDelayTime
			canAttack = true
	
	if attackDelayTimer > 0.0 and attackOnTimer:
		attackDelayTimer -= delta
		
		if attackDelayTimer <= 0.0:
			attackBuildupTimer = attackBuildupTime

func _respawnHandler(delta : float):
	if respawnTimer > 0.0:
		respawnTimer -= delta
		
		if respawnTimer <= 0.0:
			_respawn()

func _startAttack():
	hitboxComponent.get_child(0).disabled = false
	attackTimer = attackTime

func _endAttack():
	hitboxComponent.get_child(0).set_deferred("disabled", true)
	attackCooldownTimer = attackCooldownTime
	attackBuildupTimer = attackBuildupTime
	playedAttack = false
	canAttack = false
	wasDetected = false

func _onHit(_damage : float):
	print("ENEMY HIT")

func _onDeath(_damage : float):
	print("ENENMY DEATH")
	
	_endAttack()
	detectionComponent.get_child(0).set_deferred("disabled", true)
	isDead = true
	isDetected = false
	wasDetected = false
	detectionReference = null
	
	if deleteOnDeath:
		call_deferred("_spawnDeathParticles")
		queue_free()
	elif respawnOnDeath:
		respawnTimer = respawnTime

func _spawnDeathParticles():
	var particles = deathParticles.instantiate()
	get_tree().root.add_child(particles)
	particles.global_position = global_position

func _respawn():
	pass

func _onDetect(spotted : Node2D):
	isDetected = true
	wasDetected = true
	
	#print(name, " HAS DETECTED: ", spotted)
	
	if attackOnDetect:
		canAttack = true
		attackBuildupTimer = attackBuildupTime
	
	if not maintainDetection:
		await get_tree().create_timer(detectionTime).timeout
		_onUndetect(spotted)
	
	detectionReference = spotted

func _onUndetect(_spotted : Node2D):
	isDetected = false
	
	#print(name, " HAS UN-DETECTED: ", spotted)
	
	detectionReference = null
