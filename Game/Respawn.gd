extends Area2D


func _on_Area2D_body_entered(body):
	if body.is_class("Player"):
		if get_parent().has_node("player_spawn"):
			body.position = get_parent().get_node("player_spawn").position
		else:
			body.position = Vector2.ZERO
