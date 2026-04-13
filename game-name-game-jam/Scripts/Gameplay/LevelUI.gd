extends Control

@export_category("Flow Slider")
@onready var flowLayer := $FlowLayer
@onready var flowSlider := $FlowLayer/FlowSlider

@export_category("Pause")
@onready var pauseMenu := $PauseMenu/CanvasLayer
@onready var options := $PauseMenu/CanvasLayer/Background/Option
@onready var masterSlider := $PauseMenu/CanvasLayer/Background/Option/MasterSlider
@onready var sfxSlider := $PauseMenu/CanvasLayer/Background/Option/SFXSlider
@onready var musicSlider := $PauseMenu/CanvasLayer/Background/Option/MusicSlider
@onready var vsyncToggle := $PauseMenu/CanvasLayer/Background/Option/VSync
@onready var fullscreenToggle := $PauseMenu/CanvasLayer/Background/Option/Fullscreen

@export_category("Level Transition")
@onready var levelTransitionPlayer := $CanvasLevelTransition/LevelTransition/AnimationPlayer

@export_category("Level End")
@export var nextScene : String
@onready var levelEndBackground := $LevelEnd/CanvasLayer/Sprite2D
@onready var levelEndBackgroundAnimator := $LevelEnd/CanvasLayer/AnimationPlayer/AnimationTree
@onready var nextButton := $LevelEnd/CanvasLayer/NextButton
@onready var restartButton := $LevelEnd/CanvasLayer/RestartButton
@onready var quitButton := $LevelEnd/CanvasLayer/QuitButton
@onready var timerText := $LevelEnd/CanvasLayer/Timer
var levelTimer : float
var countTime : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.connect("endLevel", Callable(self, "_endLevel"))
	SignalManager.connect("restartLevel", Callable(self, "_restartLevel"))
	SignalManager.connect("flowTracker", Callable(self, "_flowSlider"))
	
	if FileAccess.file_exists("user://MasterSound.save"):
		var save = FileAccess.open("user://MasterSound.save", FileAccess.READ)
		var value = save.get_var()
		print("Master Music: ", value)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
		masterSlider.value = value
		save.close()
	
	if FileAccess.file_exists("user://SFXSound.save"):
		var save = FileAccess.open("user://SFXSound.save", FileAccess.READ)
		var value = save.get_var()
		print("SFX Music: ", value)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
		sfxSlider.value = value
		save.close()
	
	if FileAccess.file_exists("user://MusicSound.save"):
		var save = FileAccess.open("user://MusicSound.save", FileAccess.READ)
		var value = save.get_var()
		print("Value Music: ", value)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
		musicSlider.value = value
		save.close()
	
	if FileAccess.file_exists("user://VSync.save"):
		var save = FileAccess.open("user://VSync.save", FileAccess.READ)
		var value = save.get_var()
		print("Value VSync: ", value)
		
		vsyncToggle.button_pressed = value
		
		save.close()
	
	if FileAccess.file_exists("user://Fullscreen.save"):
		var save = FileAccess.open("user://Fullscreen.save", FileAccess.READ)
		var value = save.get_var()
		print("Value Fullscreen: ", value)
		
		fullscreenToggle.button_pressed = value
		
		save.close()
	
	
	levelTransitionPlayer.play("FadeOut")
	
	nextButton._tween()
	restartButton._tween()
	quitButton._tween()
	timerText._tween()
	
	countTime = true
	
	#for child in options.get_children():
	#	child._tween()

func _physics_process(delta: float) -> void:
	if countTime:
		levelTimer += delta

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		if pauseMenu.visible:
			_unpause()
		elif not pauseMenu.visible:
			flowLayer.visible = false
			pauseMenu.visible = true
			get_tree().paused = true
			options.visible = false
			countTime = false

func _flowSlider(meter):
	flowSlider.value = meter

func _unpause():
	$Press.play()
	flowLayer.visible = true
	pauseMenu.visible = false
	get_tree().paused = false
	countTime = true

func _endLevel():
	countTime = false
	flowLayer.visible = false
	levelEndBackground.visible = true
	levelEndBackgroundAnimator.active = true
	print(levelTimer)
	
	var minutes = 0
	var seconds = 0
	var milSec = 0
	
	minutes = fmod(levelTimer, 3600) / 60
	seconds = fmod(levelTimer, 60)
	milSec = fmod(levelTimer, 1) * 100
	
	timerText.text = "TIME: " + "%02d:" % minutes + "%02d." % seconds + "%03d" % milSec
	
	await get_tree().create_timer(0.6).timeout
	nextButton._tween()
	await get_tree().create_timer(0.1).timeout
	restartButton._tween()
	await get_tree().create_timer(0.1).timeout
	quitButton._tween()
	await get_tree().create_timer(0.1).timeout
	timerText._tween()

func _restart():
	$Press.play()
	SignalManager.emit_signal("restartLevel")
	await get_tree().create_timer(0.4).timeout
	get_tree().paused = false

func _restartLevel():
	levelTransitionPlayer.play("FadeIn")

func _options():
	$Press.play()
	
	if options.visible:
		options.visible = false
	else:
		options.visible = true

func _quit():
	$Press.play()
	
	levelTransitionPlayer.play("FadeIn")
	await get_tree().create_timer(0.5).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Transition Scenes/MainMenu.tscn")

func _nextScene():
	$Press.play()
	
	levelTransitionPlayer.play("FadeIn")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file(nextScene)

func _onMasterChange(value: float) -> void:
	$Tick.play()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	
	var save = FileAccess.open("user://MasterSound.save", FileAccess.WRITE)
	save.store_var(value)
	save.close()


func _onMusicChanged(value: float) -> void:
	$Tick.play()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
	
	var save = FileAccess.open("user://MusicSound.save", FileAccess.WRITE)
	save.store_var(value)
	save.close()


func _onSFXChange(value: float) -> void:
	$Tick.play()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
	
	var save = FileAccess.open("user://SFXSound.save", FileAccess.WRITE)
	save.store_var(value)
	save.close()

func _onFullscreen(toggled_on: bool) -> void:
	$Press.play()
	
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	var save = FileAccess.open("user://Fullscreen.save", FileAccess.WRITE)
	save.store_var(toggled_on)
	save.close()

func _onVSync(toggled_on: bool) -> void:
	$Press.play()
	
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	var save = FileAccess.open("user://VSync.save", FileAccess.WRITE)
	save.store_var(toggled_on)
	save.close()
