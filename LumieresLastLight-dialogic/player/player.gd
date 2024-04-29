class_name Player
extends CharacterBody2D

enum States {IDLE, WALKING, JUMPING, HURT}

const DustEffectScene = preload("res://effects/dust_effect.tscn")
const JumpEffectScene = preload("res://effects/jump_effect.tscn")
const WallJumpEffectScene = preload("res://effects/wall_jump_effect.tscn")
#const StatesScene = preload("res://states.tscn")
const KnockbackStrength = 900


@export var acceleration = 512
@export var max_velocity = 80
@export var friction = 256
@export var air_friction = 64
@export var gravity = 200
@export var jump_force = 200
@export var max_fall_velocity = 128
@export var wall_slide_speed = 42
@export var max_wall_slide_speed = 128
@export var knockback_force = 100

var state_machine = States.IDLE
var air_jump = false
var state = move_state #THIS IS HOW I CHANGE THE PLAYERS BEHAVIOR BASED ON THE ROOM
var damage_direction : Vector2
var cooldown = 1.0


@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var player_blaster = $PlayerBlaster
@onready var fire_rate_timer = $FireRateTimer
@onready var drop_timer = $DropTimer
@onready var camera_2d = $Camera2D
@onready var hurtbox : = $Hurtbox
@onready var blinking_animation_player = $BlinkingAnimationPlayer
@onready var center = $PlayerCenter

func _ready():
	PlayerStats.no_health.connect(die)
	change_state(States.IDLE)

func _enter_tree():
	MainInstances.player = self

func _physics_process(delta):
	state.call(delta)
	match state_machine:
		States.IDLE:
			idle()
		States.WALKING:
			walking()
		States.JUMPING:
			jumping()
		States.HURT:
			hurt(delta)
	
	if Input.is_action_pressed("fire") and fire_rate_timer.time_left == 0:
		fire_rate_timer.start()
		player_blaster.fire_bullet()
	
	if (Input.is_action_just_pressed("firemissile") 
	and fire_rate_timer.time_left == 0
	and PlayerStats.missiles > 0):
		fire_rate_timer.start()
		player_blaster.fire_missile()
		PlayerStats.missiles -= 1
	
	cooldown -= delta
	if cooldown <= 0:
		print("not hurrrttt")
		change_state(States.IDLE)

func _exit_tree():
	MainInstances.player = null 

func idle():
	print("idle")
	if Input.is_action_pressed("ui_left"):
		change_state(States.WALKING)
	if Input.is_action_pressed("ui_right"):
		change_state(States.WALKING)
	if Input.is_action_pressed("ui_up"):
		change_state(States.JUMPING)

func walking():
	print("walking")
	if Input.is_action_pressed("ui_up"):
		change_state(States.JUMPING)
	if !Input.is_action_pressed("ui_left"):
		change_state(States.IDLE)
	if !Input.is_action_pressed("ui_right"):
		change_state(States.IDLE)

func jumping():
	print("rjumpgg")
	if !Input.is_action_pressed("ui_up"):
		change_state(States.IDLE)

func _on_hurtbox_entered(node):
	damage_direction = node.global_position - global_position

func hurt(delta):
	print("hurt")
	velocity = KnockbackStrength * damage_direction
	move_and_slide()

func move_state(delta):
	apply_gravity(delta)
	var input_axis = Input.get_axis("ui_left", "ui_right")
	if is_moving(input_axis):
		apply_acceleration(delta, input_axis)
	else:
		apply_friction(delta)
	jump_check()
	if Input.is_action_just_pressed("Crouch"):
		set_collision_mask_value(2, false)
		drop_timer.start()
	update_animations(input_axis)
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_edge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_edge:
		coyote_jump_timer.start()
	wall_check()

func change_state(newState):
	state_machine = newState

func wall_slide_state(delta):
	var wall_normal = get_wall_normal() #a normal is a vector that points away from us. if we are looking for left, the normal points to right. if we are on a left wall, the character will jump to the right
	animation_player.play("wall_slide")
	sprite_2d.scale.x = sign(wall_normal.x)
	velocity.y = clampf(velocity.y, -wall_slide_speed, max_wall_slide_speed)
	wall_jump_check(wall_normal.x)
	apply_wall_slide_gravity(delta)
	move_and_slide()
	wall_detach(delta, wall_normal.x)

func wall_check():
	if not is_on_floor() and is_on_wall():
		state = wall_slide_state
		air_jump = true
		create_dust_effect()

func wall_detach(delta, wall_axis):
	if Input.is_action_just_pressed("ui_right") and wall_axis == 1 :
		velocity.x = acceleration * delta
		state = move_state
	if Input.is_action_just_pressed("ui_left") and wall_axis == -1 :
		velocity.x = -acceleration * delta
		state = move_state
	
	if not is_on_wall() or is_on_floor():
		state = move_state

func wall_jump_check(wall_axis):
	if Input.is_action_just_pressed("ui_up"):
		Sound.play(Sound.jump, randf_range(0.8, 1.1), 5.0)
		velocity.x = wall_axis * max_velocity
		state = move_state
		jump(jump_force * 0.75, false)
		var wall_jump_effect_position = global_position + Vector2(wall_axis * 2, -2)
		var wall_jump_effect = Utils.instantiate_scene_on_world(WallJumpEffectScene, wall_jump_effect_position)
		wall_jump_effect.scale.x = wall_axis

func apply_wall_slide_gravity(delta):
	var slide_speed = wall_slide_speed
	if Input.is_action_pressed("Crouch"):
		slide_speed = max_wall_slide_speed
	velocity.y = move_toward(velocity.y, slide_speed, gravity * delta)
#	if Input.is_action_just_pressed("Crouch"):

func create_dust_effect():
	Sound.play(Sound.step, randf_range(0.8, 1.1), -5.0)
	Utils.instantiate_scene_on_world(DustEffectScene, global_position)

func is_moving(input_axis):
	return input_axis != 0

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, max_fall_velocity, gravity * delta)

func apply_acceleration(delta, input_axis):
	velocity.x = move_toward(velocity.x, input_axis * max_velocity, acceleration * delta) 

func apply_friction(delta):
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, air_friction * delta)

func jump_check():
	if is_on_floor():
		air_jump = true
	
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("ui_up"): #remove is on floor and you have double jumping. infinite even
			jump(jump_force)
	if not is_on_floor():
		if Input.is_action_just_released("ui_up") and velocity.y < -jump_force / 2:
			velocity.y = -jump_force / 2
		
		if Input.is_action_just_pressed("ui_up") and air_jump:
			jump(jump_force + 0.75)
			air_jump = false

func jump(force, create_effect = true):
	Sound.play(Sound.jump, randf_range(0.8, 1.1), 5.0)
	velocity.y = -force
	if create_effect:
		Utils.instantiate_scene_on_world(JumpEffectScene, global_position)

func update_animations(input_axis):
	sprite_2d.scale.x = sign(get_local_mouse_position().x) #this returns either -1 or 1 and it makes the character flip to the right side when walking 
	if abs(sprite_2d.scale.x) != 1: sprite_2d.scale.x = 1
	if is_moving(input_axis):
		animation_player.play("run")
		animation_player.speed_scale = input_axis * sprite_2d.scale.x
	else:
		animation_player.play("idlecelestial")
	
	if not is_on_floor():
		animation_player.play("jump") #this one has to be in the end bc order matters. we want the jump anim to overwrite the other ones

func die():
	camera_2d.reparent(get_tree().current_scene)
	Sound.play(Sound.enemy_die, randf_range(0.8, 1.1), 5.0)
	queue_free()
	Events.player_died.emit()

func _on_drop_timer_timeout():
	set_collision_mask_value(2, true)

func _on_hurtbox_hurt(hitbox, damage):
	var knockback = 1 if (self.global_position.x - global_position.x) > 0 else -1
	change_state(States.HURT)
	Sound.play(Sound.hurt, randf_range(0.8, 1.1), -5.0)
	Events.add_screenshake.emit(4, 0.2)
	PlayerStats.health -= 1
	hurtbox.is_invincible = true
	#_on_hurtbox_area_entered(Area2D)
	blinking_animation_player.play("Blink")
	await blinking_animation_player.animation_finished
	hurtbox.is_invincible = false
#
#func knockback(area, delta):
	#velocity.x = move_toward(velocity.x, 0, 200*delta)
	#var knockback = 1 if (area.global_position.x - global_position.x) > 0 else -1
	##knockback_force *= knockback
	##move_and_slide()
#
#func _on_hurtbox_area_entered(area):
	#var knockback = 1 if (area.global_position.x - global_position.x) > 0 else -1
	#knockback_force *= knockback
