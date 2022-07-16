extends KinematicBody2D

class_name Enemy

onready var sprite = $Sprite
var move_position = Vector2.ZERO

func _process(delta):
	pass

func _physics_process(delta):
	
	pass

func damage_event():
	sprite.material = preload("res://Game/Enemy/ColorShader.tres")
	yield(get_tree().create_timer(0.1), "timeout")
	sprite.material = null

func is_class(c_name: String):
	return c_name == "Enemy"
