extends KinematicBody2D

var SPEED = 100.0

onready var sprite = $Sprite
onready var timer: int = rand_range(0, 500)

var label
var move_position = Vector2.ZERO
var currently_moving = false
var freeze_movement = false
var lock_movement = false
var origin_color = Color.black
var attacking = false
var current_direction = -1

func _process(delta):
	if $AnimationTree.get("parameters/state/current") != 2:
		attacking = false
	
	if timer == 0:
		var value = (randi() % 100 + 1)
		if value <= 30:
			$AnimationTree.set("parameters/state/current", 2)
			attacking = true
		else:
			while abs(move_position.x) < 50:
				move_position.x = int(rand_range(-200, 200))
			$RayCast2D.position.x = move_position.x * -current_direction
			move_position.x = position.x - move_position.x
				
			var target = move_position - position
			var direction = target.x / abs(target.x)
			
			scale.x = direction * current_direction
			current_direction = direction
		
		timer = rand_range(100, 500)
	elif not currently_moving and not freeze_movement and not lock_movement and not attacking:
		timer -= 1

	if freeze_movement and Input.is_action_just_released("click"):
		if lock_movement:
			origin_color = Color.black
			sprite.material.set_shader_param("new_color", origin_color)
			lock_movement = false
		else:
			origin_color = Color.aqua
			sprite.material.set_shader_param("new_color", origin_color)
			move_position = Vector2.ZERO
			lock_movement = true
	
#	label.text = (
#		str(move_position.x)
#		+ ", "
#		+ str(position.x)
#		+ ", "
#		+ str(move_position.x - position.x)
#		+ "\n"
#		+ str(currently_moving)
#		+ ", "
#		+ str(freeze_movement)
#		+ ", "
#		+ str(lock_movement)
#		+ ", "
#		+ str(attacking)
#		+ "\n"
#		+ str(sprite.flip_h)
#		+ ", "
#		+ str(timer)
#		+ ", "
#		+ str(scale.x)
#	)


func _physics_process(delta):
	if move_position.x == 0:
		return

	if not currently_moving:
		if $RayCast2D.is_colliding():
			currently_moving = true
			$AnimationTree.set("parameters/state/current", 1)
		else:
			move_position = position
			timer = 0

	if move_position.x != position.x:
		var target = move_position - position
		var direction = target.x / abs(target.x)
		$RayCast2D.position.x = target.x * -current_direction
		move_and_collide(Vector2(direction, 0) * SPEED * delta)


	if abs(move_position.x - position.x) < 10:
		move_position = Vector2.ZERO
		currently_moving = false
		$AnimationTree.set("parameters/state/current", 0)

	label.rect_position = position + Vector2(0 - (label.rect_size.x / 2), -60)


func damage_event():
	sprite.material.set_shader_param("new_color", Color.darkred)
	yield(get_tree().create_timer(0.1), "timeout")
	sprite.material.set_shader_param("new_color", origin_color)


func is_class(c_name: String):
	return c_name == "Enemy"


var temp_move_position


func _on_mouse_entered_hitbox():
	freeze_movement = true
	temp_move_position = move_position
	move_position = Vector2.ZERO
	pass  # Replace with function body.


func _on_mouse_exited_hitbox():
	freeze_movement = false
	move_position = temp_move_position
	pass  # Replace with function body.


onready var grenade = $Grenade

func _show_grenade(show_grenade: bool):
	grenade.visible = show_grenade


func _detach_grenade():
	var detached_grenade = preload("res://Game/Grenade/Grenade.tscn").instance()
	detached_grenade.global_position = grenade.global_position
	detached_grenade.velocity = Vector2(500 * current_direction, -300)
	get_parent().add_child(detached_grenade)
