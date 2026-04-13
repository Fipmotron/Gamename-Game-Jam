extends Control

@export var levelOne : PackedScene
@export var levelTwo : PackedScene
@export var levelThree : PackedScene
@export var levelFour : PackedScene
@export var levelFive : PackedScene

@onready var mainPanel := $MainPanel
@onready var mainPanelTweening := $MainPanel/TweenChildren
@onready var optionsPanel := $OptionsPanel
@onready var optionsPanelTweening := $OptionsPanel/TweenChildren
@onready var masterSlider := $OptionsPanel/TweenChildren/MasterSlider
@onready var sfxSlider := $OptionsPanel/TweenChildren/SFXSlider
@onready var musicSlider := $OptionsPanel/TweenChildren/MusicSlider
@onready var fullscreenToggle := $OptionsPanel/TweenChildren/Fullscreen
@onready var vsyncToggle := $OptionsPanel/TweenChildren/VSync
@onready var levelPanel := $LevelSelectPanel
@onready var levelPanelTweening := $LevelSelectPanel/TweenChildren
@onready var transitionLayer := $TransitionLayer
@onready var transitionPlayer := $TransitionLayer/Transition/AnimationPlayer

func _ready() -> void:
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
	
	for child in levelPanelTweening.get_children():
		child._tween()
	
	for child in optionsPanelTweening.get_children():
		child._tween()

func _onTransitionLevelSelect() -> void:
	$Press.play()
	
	for child in mainPanelTweening.get_children():
		child._tween()
		await get_tree().create_timer(0.1).timeout
	
	await get_tree().create_timer(0.1).timeout
	levelPanel.visible = true
	mainPanel.visible = false
	
	for child in levelPanelTweening.get_children():
		child._tween()
		await get_tree().create_timer(0.1).timeout

func _onTransitionOptionsPanel() -> void:
	$Press.play()
	
	for child in mainPanelTweening.get_children():
		child._tween()
		await get_tree().create_timer(0.1).timeout
	
	mainPanel.visible = false
	optionsPanel.visible = true
	
	for child in optionsPanelTweening.get_children():
		child._tween()
		await get_tree().create_timer(0.1).timeout


func _onTransitionMainPanelOptions() -> void:
	$Press.play()
	
	for child in optionsPanelTweening.get_children():
		child._tween()
		await get_tree().create_timer(0.1).timeout
	
	mainPanel.visible = true
	optionsPanel.visible = false
	
	for child in mainPanelTweening.get_children():
		child._tween()
		await get_tree().create_timer(0.1).timeout


func _onTransitionMainPanelLevel() -> void:
	$Press.play()
	
	for child in levelPanelTweening.get_children():
		child._tween()
		await get_tree().create_timer(0.1).timeout
	
	await get_tree().create_timer(0.1).timeout
	mainPanel.visible = true
	levelPanel.visible = false

	for child in mainPanelTweening.get_children():
		child._tween()
		await get_tree().create_timer(0.1).timeout

func _onCloseGame() -> void:
	$Press.play()
	
	get_tree().quit()


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

func _onPlayLevelOne():
	$Press.play()
	
	transitionLayer.visible = true
	transitionPlayer.play("FadeIn")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_packed(levelOne)

func _onPlayLevelTwo():
	$Press.play()
	
	transitionLayer.visible = true
	transitionPlayer.play("FadeIn")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_packed(levelTwo)

func _onPlayLevelThree():
	$Press.play()
	
	transitionLayer.visible = true
	transitionPlayer.play("FadeIn")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_packed(levelThree)

func _onPlayLevelFour():
	$Press.play()
	
	transitionLayer.visible = true
	transitionPlayer.play("FadeIn")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_packed(levelFour)

func _onPlayLevelFive():
	$Press.play()
	
	transitionLayer.visible = true
	transitionPlayer.play("FadeIn")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_packed(levelFive)
