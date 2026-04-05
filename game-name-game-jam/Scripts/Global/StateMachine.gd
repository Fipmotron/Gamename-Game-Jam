extends Node

@onready var states : Dictionary[String, Node]
@onready var host := get_parent()
var currentState : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		states.set(child.name, child)
	
	currentState = get_child(0).name
	
	print(states)

func _physics_process(delta: float) -> void:
	var stateName = states[currentState]._step(host, delta)
	
	if stateName:
		_changeState(stateName)

func _changeState(stateName : String):
	if stateName == currentState:
		return
	
	states[currentState]._exit(host)
	currentState = stateName
	states[currentState]._enter(host)
	
	print(stateName)
