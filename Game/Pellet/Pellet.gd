extends KinematicBody2D

export var direction = Vector2.RIGHT
export var speed = 2000

var time_alive_seconds = 0

func _physics_process(delta):
	var collision = move_and_collide(direction * speed * delta)
	time_alive_seconds += delta
	
	if collision == null and time_alive_seconds <= 0.5:
		return
	
	get_parent().remove_child(self)
	
	if collision == null: 
		return
	
	# Failsafe
	if not collision.collider.has_method("damage_event"):
		print(collision.collider.name + " does not have a damage state")
		return
	
	collision.collider.damage_event()
