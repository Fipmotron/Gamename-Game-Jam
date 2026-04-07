extends Camera2D

@export_category("Following")
@export var followNode : Node2D

@export_category("Screen Shake")
var isShaking : bool
var shakeStrength : float
var shakeDecay : float
var shakeTimer : float
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	SignalManager.connect("shakeScreen", Callable(self, "_setScreenShake"))
	SignalManager.connect("cameraToPlayer", Callable(self, "_cameraToPlayer"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if followNode != null:
		global_position = followNode.global_position
	
	if isShaking:
		shakeTimer -= delta
		
		shakeStrength = lerp(shakeStrength, 0.0, shakeDecay * delta)
		
		offset = Vector2(rng.randf_range(-shakeStrength, shakeStrength), rng.randf_range(-shakeStrength, shakeStrength))
		
		if shakeTimer <= 0.0:
			isShaking = false

func _setScreenShake(strength : float, time : float, decay):
	shakeTimer = time
	shakeStrength = strength
	shakeDecay = decay
	isShaking = true

func _cameraToPlayer(player : Node2D):
	drag_left_margin = 0.0
	drag_right_margin = 0.0
	
	followNode = player

func _resetCameraSettings():
	const MARGIN = 0.1
	
	drag_left_margin = MARGIN
	drag_right_margin = MARGIN
