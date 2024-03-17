extends Control

@onready var full = $Full
@onready var empty = $Empty

func _ready():
	update_health_ui()
	update_max_health_ui()
	PlayerStats.health_changed.connect(update_health_ui)
	PlayerStats.max_health_changed.connect(update_max_health_ui)

func update_health_ui():
	full.size.x = PlayerStats.health * 5 + 1 #5 pixels long. you can see this in the full transform, change size to 10.

func update_max_health_ui():
	empty.size.x = PlayerStats.max_health * 5 + 1
