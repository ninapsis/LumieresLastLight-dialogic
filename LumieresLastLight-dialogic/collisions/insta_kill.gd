class_name InstaKill
extends Area2D

@export var damage = 1

func _on_area_entered(hurtbox):
	if not hurtbox is Hurtbox: return
	hurtbox.take_hit(self, damage)
	Sound.play(Sound.enemy_die, randf_range(0.8, 1.1), 5.0)
	queue_free()
	Events.player_died.emit()
	
