extends Node

enum States {IDLE, WALKING, JUMPING}

var state = States.IDLE

func change_state(newState):
	state = newState

func _physics_process(delta):
	match state:
		States.IDLE:
			idle()
		States.WALKING:
			walking()
		States.JUMPING:
			jumping()

func idle():
	print("idle")
	if Input.is_action_pressed("ui_left"):
		change_state(States.WALKING)

func walking():
	print("walking")
	if Input.is_action_pressed("ui_up"):
		change_state(States.JUMPING)
	if !Input.is_action_pressed("ui_left"):
		change_state(States.IDLE)

func jumping():
	print("rjumpgg")
	if !Input.is_action_pressed("ui_up"):
		change_state(States.IDLE)
