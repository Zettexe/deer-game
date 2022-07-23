extends Area2D

export var direction = Vector2.RIGHT
export var speed = 2000

var time_alive_seconds = 0

func _physics_process(delta):
	position = lerp(position, position + direction * speed * delta, 1)
	
	time_alive_seconds += delta
	if time_alive_seconds >= 10:
		queue_free()

func _on_body_entered(body):
	if not body.has_method("damage_event"):
		print(body.name + " does not have a damage state")
		return
	
	body.damage_event()
	queue_free()
