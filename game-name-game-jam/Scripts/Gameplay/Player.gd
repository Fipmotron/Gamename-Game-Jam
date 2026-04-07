extends CharacterBody2D

class_name Player

@export_category("Camera Movement")
@export var followSpeed : float
@export var radius : float
@onready var cameraFollower := $CameraHolder/CameraFollower

@export_category("Flow State")
@export var maxFlowState : float
@export var baseFlowMultipler : float
@export var flowDecayMultuplier : float
var flowState : float
var flowMultiplier : float

@export_category("Base Movement")
@export var baseMaxSpeed : float
@export var acceleration : float
@export var decceleration : float
var direction : float
var maxSpeed : float

@export_category("Air Movement")
@export var gravity : float
@export var jumpGravity : float
@export var terminalVelocity : float
@export var jumpForce : float
@export var doubleJumpForce : float
@export var jumpTime : float
@export var coyoteTime : float
@export var jumpBufferTime : float
var jumpTimer : float
var coyoteTimer : float
var jumpBufferTimer : float
var isJumping : bool
var hasJumped : bool
var canDoubleJump : bool

@export_category("Dash Movement")
@export var dashSpeed : float
@export var dashSpeedRecovery : float
@export var dashTime : float
@export var dashCooldownTime : float
var lastStoredDirection := 1.0
var dashTimer : float
var dashCooldownTimer : float
var canDash : bool
var isDashing : bool

@export_category("Stomp Movement")
@export var stompForce : float
@export var stompCooldownTime : float
@export var stompBoostSpeed : float
@export var boostDecay : float
var stompCooldownTimer : float
var isStomping : bool
var playedStompParticles : bool

@export_category("Attack Varibles")
@export var flowAttackTime : float
@export var flowAttackSpeed : float
@export var basicAttackTime : float
@export var flowAttackCooldownTime : float
@export var attackCooldownTime : float
@onready var slashHitbox := $Hitboxes/SlashHitboxComponent
@onready var flowHitbox := $Hitboxes/FlowHitboxComponent
@onready var stompHitbox := $Hitboxes/StompHitboxComponent
@onready var parryHitbox := $Hitboxes/ParryHitboxComponent
var flowStartPosition : Vector2
var flowEndPosition : Vector2
var attackTimer : float
var flowAttackTimer : float
var flowAttackCooldownTimer : float
var attackCooldownTimer : float
var canFlowAttack : bool
var canAttack : bool
var isFlowAttacking : bool
var isAttacking : bool

@export_category("Parry Varibles")
@export var parryTime : float
@export var parryResponseTime : float
@export var parryCooldownTime : float
@export var parryBoostSpeed : float
@onready var parryDetector := $ParryDetectionComponent
var parryTimer : float
var parryResponseTimer : float
var parryCooldownTimer : float
var parryBoostDirection : float
var isParrying : bool
var canParryBoost : bool
var madeContact : bool
var contactNode : Node2D

@export_category("Health Varibles")
@export var hitTime : float
@export var deathTime : float
@onready var healthComponent := $HealthComponent
var deathTimer : float
var hitTimer : float
var isHit : bool
var isDead : bool

@export_category("Animation Varibles")
@onready var sprite := $Sprite2D
@onready var animationTree := $AnimationPlayer/AnimationTree
var mainStatemachine
var groundStatemachine
var airStatemachine
var attackStatemachine
var otherStatemachine
var cutsceneStatemachine

@export_category("Particle Varibles")
@export var runParticles : PackedScene
@export var jumpLineParticles : PackedScene
@export var jumpPuffParticles : PackedScene
@export var stompLineParticles : PackedScene
@export var stompBubbleParticles : PackedScene
@export var stompAnimationParticles : PackedScene
@export var dashLineParticles : PackedScene
@export var dashPuffParticles : PackedScene
@export var deathParticles : PackedScene

@export_category("Cutscene Varibles")
var isInCutscene : bool

func _ready() -> void:
	maxSpeed = baseMaxSpeed
	
	flowState = maxFlowState
	
	mainStatemachine = animationTree.get("parameters/playback")
	groundStatemachine = animationTree.get("parameters/Grounded/playback")
	airStatemachine = animationTree.get("parameters/Airborne/playback")
	attackStatemachine = animationTree.get("parameters/Attacking/playback")
	otherStatemachine = animationTree.get("parameters/Other/playback")
	cutsceneStatemachine = animationTree.get("parameters/Cutscene/playback")
	
	SignalManager.connect("endLevel", Callable(self, "_endLevel"))

func _directionHandler():
	direction = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	
	if direction != 0.0:
		lastStoredDirection = direction

func _baseMovement(delta : float):
	# Turn instant clause
	if direction > 0.0 and velocity.x < 0.0 or direction < 0.0 and velocity.x > 0.0:
		velocity.x *= -1
	
	if direction != 0.0:
		velocity.x += ((acceleration * flowMultiplier) * direction) * delta
	else:
		velocity.x = move_toward(velocity.x, 0.0, decceleration)
	
	velocity.x = clampf(velocity.x, -maxSpeed * flowMultiplier, maxSpeed * flowMultiplier)

func _gravity():
	if not isJumping and not is_on_floor():
		velocity.y += gravity 
	elif hasJumped:
		velocity.y += jumpGravity
	
	velocity.y = clampf(velocity.y, -terminalVelocity, terminalVelocity)

func _groundCheck(delta : float):
	if not is_on_floor() and coyoteTimer > 0.0:
		coyoteTimer -= delta
	else:
		coyoteTimer = coyoteTime
		canDoubleJump = true
		hasJumped = false

func _jumpCheck(delta : float):
	if Input.is_action_just_pressed("Jump"):
		jumpBufferTimer = jumpBufferTime
	
	if jumpBufferTimer > 0.0:
		jumpBufferTimer -= delta
	
	if jumpBufferTimer > 0.0 and coyoteTimer > 0.0:
		_spawnJumpParticles()
		isJumping = true
		jumpTimer = jumpTime
		jumpBufferTimer = 0.0
		coyoteTimer = 0.0

func _doubleJumpCheck():
	if Input.is_action_just_pressed("Jump") and canDoubleJump:
		isJumping = true
		_spawnJumpParticles()
		canDoubleJump = false
		jumpTimer = jumpTime

func _jumpHandler(delta : float):
	if isJumping:
		jumpTimer -= delta
		
		if canDoubleJump:
			velocity.y = -jumpForce * flowMultiplier
		else:
			velocity.y = -doubleJumpForce * flowMultiplier
		
		if jumpTimer <= 0.0 or Input.is_action_just_released("Jump"):
			isJumping = false
			hasJumped = true

func _dashCheck(delta : float):
	if Input.is_action_just_pressed("Dash") and canDash:
		isDashing = true
		isJumping = false
		canDash = false
		dashTimer = dashTime
		dashCooldownTimer = dashCooldownTime
	
	if dashCooldownTimer > 0.0 and not isDashing:
		dashCooldownTimer -= delta
	elif dashCooldownTimer <= 0.0 and not isDashing:
		canDash = true

func _dashHandler(delta : float):
	if dashTimer > 0.0:
		maxSpeed = dashSpeed
		velocity.x = maxSpeed * lastStoredDirection * flowMultiplier
		velocity.y = 0.0
		dashTimer -= delta
		_spawnDashParticles()
	else:
		isDashing = false

func _dashRecovery():
	maxSpeed = move_toward(maxSpeed, baseMaxSpeed, dashSpeedRecovery)

func _enableHealth():
	healthComponent.get_child(0).disabled = false

func _disableHealth():
	healthComponent.get_child(0).disabled = true

func _stompCheck():
	if Input.is_action_just_pressed("Stomp"):
		isStomping = true
		isJumping = false
		stompCooldownTimer = stompCooldownTime

func _stompHandler(delta : float):
	if is_on_floor():
		if !playedStompParticles:
			const SHAKE_STRENGTH = 50.0
			const SHAKE_TIME = 0.25
			const SHAKE_DECAY = 5.0
			
			SignalManager.emit_signal("shakeScreen", SHAKE_STRENGTH, SHAKE_TIME, SHAKE_DECAY)
			_spawnStompRecoveryParticles()
			playedStompParticles = true
		
		stompCooldownTimer -= delta
		
		_animStompRec()
		
		_spriteDeform(1.75, 0.35)
		
		if stompCooldownTimer <= 0.0:
			isStomping = false
			playedStompParticles = false
	else:
		_animStomp()
		
		_spawnStompFallParticles()
		
		_spriteAirDeform()
		
		velocity.x = 0.0
		velocity.y = stompForce 

func _stompBoost():
	maxSpeed = stompBoostSpeed
	velocity.x = lastStoredDirection * maxSpeed * flowMultiplier

func _boostDecay():
	maxSpeed = move_toward(maxSpeed, baseMaxSpeed, boostDecay)

func _enableStompAttack():
	stompHitbox.get_child(0).disabled = false

func _disableStompAttack():
	stompHitbox.get_child(0).disabled = true

func _basicAttackCheck():
	if Input.is_action_just_pressed("Basic Attack") and canAttack and not (isStomping or isDashing):
		_enableBasicAttack()

func _basicAttackHandler(delta : float):
	if isAttacking:
		attackTimer -= delta
		
		if attackTimer <= 0.0:
			_disableBasicAttack()

func _enableBasicAttack():
	const DISTANCE_AWAY_FROM_PLAYER = 32.0
	
	if lastStoredDirection > 0.0:
		slashHitbox.get_child(0).position.x = DISTANCE_AWAY_FROM_PLAYER
	else:
		slashHitbox.get_child(0).position.x = -DISTANCE_AWAY_FROM_PLAYER
	
	_animSlash()
	
	isAttacking = true
	canAttack = false
	attackTimer = basicAttackTime
	attackCooldownTimer = attackCooldownTime
	
	slashHitbox.get_child(0).disabled = false

func _disableBasicAttack():
	isAttacking = false
	
	slashHitbox.get_child(0).disabled = true

func _flowAttackCheck(_delta : float):
	if Input.is_action_just_pressed("Flow Attack") and flowState > 0.0 and not isFlowAttacking and flowAttackCooldownTimer <= 0.0:
		isFlowAttacking = true
		flowAttackTimer = flowAttackTime
		flowStartPosition = global_position
		flowEndPosition = get_global_mouse_position()

func _flowAttackHandler(delta : float):
	var flowDirection = (flowEndPosition - flowStartPosition).normalized()
	
	velocity = flowDirection * flowAttackSpeed
	flowAttackTimer -= delta
	
	if flowAttackTimer <= 0.0:
		_cancelFlowAttack()

func _cancelFlowAttack():
	isFlowAttacking = false
	flowAttackTimer = 0.0
	flowAttackCooldownTimer = flowAttackCooldownTime

func _enableFlowHitbox():
	flowHitbox.get_child(0).disabled = false

func _disableFlowHitbox():
	flowHitbox.get_child(0).disabled = true

func _attackRefresh(delta : float):
	if not canAttack and not isAttacking:
		attackCooldownTimer -= delta
		
		if attackCooldownTimer <= 0.0:
			canAttack = true
	
	if not isFlowAttacking:
		flowAttackCooldownTimer -= delta

func _parryCheck(delta : float):
	if Input.is_action_just_pressed("Parry") and parryCooldownTimer <= 0.0:
		parryTimer = parryTime
		parryDetector.get_child(0).disabled = false
		isParrying = true
	
	if parryCooldownTimer > 0.0:
		parryCooldownTimer -= delta

func _parryHandler(delta : float):
	if madeContact:
		parryHitbox.get_child(0).disabled = false
		
		if contactNode is Projectile:
			contactNode.shooter._onDeath(0.0)
			
			if (global_position - contactNode.shooter.global_position).normalized().x > 0.0:
				parryBoostDirection = 1 
			elif (global_position - contactNode.shooter.global_position).normalized().x < 0.0:
				parryBoostDirection = -1 
			
			global_position = contactNode.shooter.global_position
			contactNode._destroy()
		elif contactNode is Enemy:
			if (global_position - contactNode.global_position).normalized().x > 0.0:
				parryBoostDirection = 1 
			elif (global_position - contactNode .global_position).normalized().x < 0.0:
				parryBoostDirection = -1 
			
			global_position = contactNode.global_position
			contactNode._onDeath(0.0)
		else:
			print("What happened? - Parry Handler, Player.gd")
		
		
		madeContact = false
		parryResponseTimer = parryResponseTime
		
	elif parryResponseTimer > 0.0:
		parryResponseTimer -= delta
		
		if parryResponseTimer <= 0.0:
			parryDetector.get_child(0).disabled = true
			parryHitbox.get_child(0).disabled = true
			isParrying = false
	elif parryTimer > 0.0:
		parryTimer -= delta
		
	else:
		parryCooldownTimer = parryCooldownTime
		parryDetector.get_child(0).disabled = true
		parryHitbox.get_child(0).disabled = true
		isParrying = false

func _parryBoost():
	if canParryBoost:
		maxSpeed = parryBoostSpeed
		velocity.x = maxSpeed * parryBoostDirection
		canParryBoost = false

func _onDetect(object : Node2D):
	print("PARRY")
	
	madeContact = true
	contactNode = object

func _flowHandler(delta : float):
	#print("Flow State: ", flowState)
	
	if flowState > 0.0:
		flowState -= delta
		
		flowMultiplier = baseFlowMultipler
	else:
		flowMultiplier =  flowDecayMultuplier
	
	flowState = clampf(flowState, 0.0, maxFlowState)

func _lookaheadHandler(delta : float):
	cameraFollower.position = cameraFollower.position.lerp(velocity.normalized() * radius, delta * followSpeed)

func _slideCall():
	move_and_slide()

func _spriteFlipper():
	if direction > 0.0:
		sprite.flip_h = false
	elif direction < 0.0:
		sprite.flip_h = true

func _spriteAirDeform():
	sprite.scale.y = remap(abs(velocity.y), 0, abs(jumpForce), 0.75, 1.75)
	sprite.scale.x = remap(abs(velocity.y), 0, abs(jumpForce), 1.25, 0.75)

func _spriteStompDeform():
	sprite.scale.y = remap(abs(velocity.y), 0, abs(stompForce), 0.75, 1.75)
	sprite.scale.x = remap(abs(velocity.y), 0, abs(stompForce), 1.25, 0.75)

func _spriteDeform(x : float, y : float):
	sprite.scale.x = x
	sprite.scale.y = y

func _spriteReform(delta : float):
	const REFORM_TIME = 3
	
	sprite.scale.x = move_toward(sprite.scale.x, 1, REFORM_TIME * delta)
	sprite.scale.y = move_toward(sprite.scale.y, 1, REFORM_TIME * delta)

func _animIdle():
	mainStatemachine.travel("Grounded")
	groundStatemachine.travel("Idle")

func _animRun():
	mainStatemachine.travel("Grounded")
	groundStatemachine.travel("Run")

func _animJump():
	mainStatemachine.travel("Airborne")
	airStatemachine.travel("Jump")

func _animFall():
	mainStatemachine.travel("Airborne")
	airStatemachine.travel("Fall")

func _animDJump():
	mainStatemachine.travel("Airborne")
	airStatemachine.travel("Double Jump")

func _animStomp():
	mainStatemachine.travel("Airborne")
	airStatemachine.travel("Stomp")

func _animStompRec():
	mainStatemachine.travel("Grounded")
	groundStatemachine.travel("StompRecovery")

func _animDash():
	mainStatemachine.travel("Other")
	otherStatemachine.travel("Dash")

func _animSlash():
	mainStatemachine.travel("Attacking")
	
	var rng = RandomNumberGenerator.new()
	var num = rng.randi_range(1, 3)
	
	attackStatemachine.travel("Slash_" + str(num))

func _animParry():
	mainStatemachine.travel("Other")
	otherStatemachine.travel("Parry")

func _spawnRunParticles():
	var particle = runParticles.instantiate()
	get_tree().root.add_child(particle)
	particle.global_position = sprite.global_position

func _spawnDashParticles():
	var particle = dashLineParticles.instantiate()
	get_tree().root.add_child(particle)
	particle.global_position = sprite.global_position
	particle = dashPuffParticles.instantiate()
	get_tree().root.add_child(particle)
	particle.global_position = sprite.global_position

func _spawnStompFallParticles():
	var particle = stompLineParticles.instantiate()
	get_tree().root.add_child(particle)
	particle.global_position = sprite.global_position
	particle = dashPuffParticles.instantiate()
	get_tree().root.add_child(particle)
	particle.global_position = sprite.global_position

func _spawnStompRecoveryParticles():
	var particle = jumpPuffParticles.instantiate()
	get_tree().root.add_child(particle)
	particle.global_position = sprite.global_position
	particle = stompBubbleParticles.instantiate()
	get_tree().root.add_child(particle)
	particle.global_position = sprite.global_position
	particle = stompAnimationParticles.instantiate()
	get_tree().root.add_child(particle)
	particle.global_position = sprite.global_position

func _spawnJumpParticles():
	var particle = jumpLineParticles.instantiate()
	get_tree().root.add_child(particle)
	particle.global_position = sprite.global_position
	particle = jumpPuffParticles.instantiate()
	get_tree().root.add_child(particle)
	particle.global_position = sprite.global_position

func _spawnLandParticles():
	var particle = jumpPuffParticles.instantiate()
	get_tree().root.add_child(particle)
	particle.global_position = sprite.global_position

func _spawnDeathParticles():
	pass

func _endLevel():
	isInCutscene = true
	
	mainStatemachine.travel("Cutscene")
	
	SignalManager.emit_signal("cameraToPlayer", self)

func _resetVelocity():
	velocity = Vector2.ZERO

func _onHit(damageTaken : float):
	print("PLAYER HIT")
	
	if flowState > 0.0:
		healthComponent.health += damageTaken
	else:
		isHit = true

func _onDeath(damageTaken : float):
	print("PLAYER DEATH")
	
	if flowState > 0.0:
		healthComponent.health += damageTaken
	else:
		isDead = true
