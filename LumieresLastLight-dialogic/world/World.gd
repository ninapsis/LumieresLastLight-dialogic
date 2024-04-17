class_name World
extends Node2D

@onready var level: = $LevelOne
#var tileset = load("res://tilesets/code_tileset.png")
#var dupe = tileset.duplicate(true)
#var saved = ResourceSaver.save(tileset, filename.get_base_dir() + "/" + file + ".tres")
#filename = file
#base_tileset = load("res://addons/godotile/base.tres")
#tileset = base_tileset.duplicate(true)
func _enter_tree():
	MainInstances.world = self

# Called when the node enters the scene tree for the first time.
func _ready():
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	RenderingServer.set_default_clear_color(Color.BLACK)
	Events.door_entered.connect(change_levels)
	Events.player_died.connect(game_over)
	Music.play(Music.main_theme)
	if SaveManager.is_loading:
		SaveManager.load_game()
		SaveManager.is_loading =false   

#func _process(delta):
	#if Input.is_action_just_pressed("save"):
		#SaveManager.save_game()
	#if Input.is_action_just_pressed("load"):
		#SaveManager.load_game()

func _exit_tree():
	MainInstances.world = null

func load_level(file_path):
	level.queue_free()
	level.name = level.name+"OLD"
	var LevelScene = load(file_path)
	var new_level = LevelScene.instantiate()
	add_child(new_level)
	level = new_level

func change_levels(door : Door):
	var player = MainInstances.player as Player
	if not player is Player:  return
	level.queue_free()
	var new_level = load(door.new_level_path).instantiate()
	add_child(new_level)
	level = new_level
	var doors = get_tree().get_nodes_in_group("doors")
	for found_door in doors:
		if found_door == door: continue
		if found_door.connection != door.connection: continue
		var yoffset = player.global_position.y - door.global_position.y
		player.global_position = found_door.global_position +  Vector2(0, yoffset)

func game_over():
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://menus/game_over_menu.tscn")
