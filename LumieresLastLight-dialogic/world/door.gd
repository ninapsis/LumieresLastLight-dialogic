class_name Door
extends Area2D

var active = false
var player_in_area = false  # Track if the player is in the area

@export_file("*.tscn") var new_level_path
@export var connection: DoorConnection

@onready var right_cast = $RightCast
@onready var left_cast = $LeftCast

#func _ready():
	#connect("body_entered", Callable(self, "_on_body_entered"))
	#connect("body_exited", Callable(self, "_on_body_exited"))

func get_direction():
	if left_cast.is_colliding():
		return -1
	if right_cast.is_colliding():
		return 1
	return 0

func _physics_process(delta):
	var player = MainInstances.player as Player
	if not player is Player: return
	if not active: return
	if not player_in_area: return
	if Input.is_action_just_pressed("dialogic_default_action") and player_in_area:
		Events.door_entered.emit(self)

func _on_timer_timeout():
	active = true

func _on_body_entered(body: PhysicsBody2D):
	if body.is_in_group("Player"):  # Assuming your player is in a group named "Player"
		player_in_area = true

func _on_body_exited(body: PhysicsBody2D):
	if body.is_in_group("Player"):
		player_in_area = false
