extends Level

@onready var blockers = $Blockers
@onready var trigger = $Trigger

func _ready():
	blockers.hide()
	await Music.fade()
	Music.play(Music.main_theme)
	

func _on_trigger_trigger_entered():
	var boss_freed = WorldStash.retrieve("first_boss", "freed")
	if not boss_freed:
		blockers.show()
		trigger.is_active = false

func _on_boss_enemy_tree_exited():
	blockers.queue_free()
