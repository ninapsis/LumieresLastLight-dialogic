extends StaticBody2D
#
func _on_hurtbox_hurt(hitbox, damage):
	queue_free()
#
#func _ready():
#	update_collision_layer()
#
#func update_collision_layer():
#	set_collision_layer_value(1, is_visible_in_tree())
#
#func _on_visibility_changed():
#	update_collision_layer()
