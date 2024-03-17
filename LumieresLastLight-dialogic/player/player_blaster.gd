extends Node2D

const BulletScene = preload("res://player/bullet.tscn")
const MissileScene = preload("res://player/missile.tscn")

@onready var blaster_sprite = $BlasterSprite
@onready var muzzle = $BlasterSprite/Muzzle

func _process(delta):
	blaster_sprite.rotation = get_local_mouse_position().angle()

func fire_bullet():
	var bullet = Utils.instantiate_scene_on_world(BulletScene, muzzle.global_position)
	bullet.rotation = blaster_sprite.rotation
	bullet.update_velocity()
#	var bullet = BulletScene.instantiate()
#	var world = get_tree().current_scene
#	world.add_child(bullet)
#	bullet.global_position = muzzle.global_position

func fire_missile():
	var missile = Utils.instantiate_scene_on_world(MissileScene, muzzle.global_position)
	missile.rotation = blaster_sprite.rotation
	missile.update_velocity()
