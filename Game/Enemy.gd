extends KinematicBody2D

class_name Enemy

onready var sprite = $Sprite
var new_mat = preload("res://ColorShader.tres")

func damage_event():
	sprite.material = new_mat
	yield(get_tree().create_timer(0.1), "timeout")
	sprite.material = null

func is_class(c_name: String):
	return c_name == "Enemy"
