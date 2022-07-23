extends KinematicBody2D


func _process(delta):
	var collision = move_and_collide(Vector2.ZERO)
	if collision != null:
		print(collision.collider.name)
