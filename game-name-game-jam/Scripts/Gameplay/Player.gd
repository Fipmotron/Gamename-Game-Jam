extends CharacterBody2D

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
var lastStoredDirection : float
var dashTimer : float
var dashCooldownTimer : float
var canDash : bool
var isDashing : bool

@export_category("Stomp Movement")
@export var stompForce : float
@export var stompCooldownTime : float
@export var stompBoostSpeed : float
@export var stompBoostDecay : float
var stompCooldownTimer : float
var isStomping : bool

@export_category("Attack Varibles")
@export var flowAttackTime : float
@export var flowAttackSpeed : float
@export var basicAttackTime : float
@export var flowAttackCooldownTime : float
@export var attackCooldownTime : float
@onready var slashHitbox := $Hitboxes/SlashHitboxComponent
@onready var flowHitbox := $Hitboxes/FlowHitboxComponent
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

@export_category("Health Varibles")
@export var hitTime : float
@export var deathTime : float
@onready var healthObject := $HealthComponent
var deathTimer : float
var hitTimer : float
var isHit : bool
var isDead : bool

func _ready() -> void:
	maxSpeed = baseMaxSpeed
	
	flowState = maxFlowState

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
		isJumping = true
		jumpTimer = jumpTime
		jumpBufferTimer = 0.0
		coyoteTimer = 0.0

func _doubleJumpCheck():
	if Input.is_action_just_pressed("Jump") and canDoubleJump:
		isJumping = true
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
	else:
		isDashing = false

func _dashRecovery():
	maxSpeed = move_toward(maxSpeed, baseMaxSpeed, dashSpeedRecovery)

func _stompCheck():
	if Input.is_action_just_pressed("Stomp"):
		isStomping = true
		isJumping = false
		stompCooldownTimer = stompCooldownTime

func _stompHandler(delta : float):
	if is_on_floor():
		stompCooldownTimer -= delta
		
		if stompCooldownTimer <= 0.0:
			isStomping = false
	else:
		velocity.x = 0.0
		velocity.y = stompForce 

func _stompBoost():
	maxSpeed = stompBoostSpeed
	velocity.x = lastStoredDirection * maxSpeed * flowMultiplier

func _stompDecay():
	maxSpeed = move_toward(maxSpeed, baseMaxSpeed, stompBoostDecay)

func _basicAttackCheck():
	if Input.is_action_just_pressed("Basic Attack") and canAttack and not (isStomping or isDashing):
		_enableBasicAttack()

func _basicAttackHandler(delta : float):
	if isAttacking:
		attackTimer -= delta
		
		if attackTimer <= 0.0:
			_disableBasicAttack()

func _enableBasicAttack():
	const DISTANCE_AWAY_FROM_PLAYER = 24.0
	
	if lastStoredDirection > 0.0:
		slashHitbox.get_child(0).position.x = DISTANCE_AWAY_FROM_PLAYER
	else:
		slashHitbox.get_child(0).position.x = -DISTANCE_AWAY_FROM_PLAYER
	
	isAttacking = true
	canAttack = false
	attackTimer = basicAttackTime
	attackCooldownTimer = attackCooldownTime
	
	slashHitbox.monitorable = true
	slashHitbox.monitoring = true

func _disableBasicAttack():
	isAttacking = false
	
	slashHitbox.monitorable = false
	slashHitbox.monitoring = false

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

func _attackRefresh(delta : float):
	if not canAttack and not isAttacking:
		attackCooldownTimer -= delta
		
		if attackCooldownTimer <= 0.0:
			canAttack = true
	
	if not isFlowAttacking:
		flowAttackCooldownTimer -= delta

func _flowHandler(delta : float):
	#print("Flow State: ", flowState)
	
	if flowState > 0.0:
		flowState -= delta
		
		flowMultiplier = baseFlowMultipler
	else:
		flowMultiplier =  flowDecayMultuplier

func _lookaheadHandler(delta : float):
	cameraFollower.position = cameraFollower.position.lerp(velocity.normalized() * radius, delta * followSpeed)

func _slideCall():
	move_and_slide()

func _hit(damageTaken : float, _knockback : float):
	if flowState > 0.0:
		healthObject.health += damageTaken
	else:
		isHit = true

func _death(damageTaken : float, _knockback : float):
	if flowState > 0.0:
		healthObject.health += damageTaken
	else:
		isDead = true
