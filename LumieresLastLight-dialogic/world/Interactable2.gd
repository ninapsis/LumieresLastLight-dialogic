extends Area2D
var player_in_area = false

# Called when the node enters the scene tree for the first time.
#func _ready():
	#connect("body_entered", self, "_on_Area2D_body_entered")
	#connect("body_exited", self, "_on_Area2D_body_exited")

func _input(event: InputEvent):
	if Dialogic.current_timeline != null:
		return
	#if event is InputEventKey and event.keycode == KEY_ENTER and event.pressed:
	if Input.is_action_just_pressed("dialogic_default_action") and player_in_area:
		print("unhh")
		Dialogic.start('timeline2')
		get_viewport().set_input_as_handled()

func _on_body_entered(body):
	if body.name == "Player":
		player_in_area = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_area = false
