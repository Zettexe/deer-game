extends KinematicBody2D

signal animation_finished

var SPEED = 50.0

onready var sprite = $Sprite
onready var grenade_sprite = $Grenade

var label = Label.new()

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var max_fall_speed = ProjectSettings.get_setting("physics/2d/default_maximum_fall_speed")
var motion = Vector2.RIGHT * SPEED
var direction

onready var attack_timer: int = 50
var player_in_vision = false
var targeting = false

func _ready():
	label.theme = load("Game/DebugTheme.tres")
	label.text = name
	add_child(label)
	label.rect_position = Vector2(0 - (label.rect_size.x / 2), -110)


func _process(_delta):
	if targeting:
		if attack_timer == 0:
			$AnimationTree.set("parameters/state/current", 2)
			# warning-ignore:narrowing_conversion
			attack_timer = rand_range(150, 200)
		else:
			attack_timer -= 1


func _physics_process(delta):
	if not $RayCastForward.is_colliding():
		motion.x = -motion.x
	
	if motion.x != 0:
		$AnimationTree.set("parameters/state/current", 1)
		direction = motion.x / abs(motion.x)
		scale = Vector2(-direction * scale.x, abs(scale.y))
		rotation = 0
		label.rect_scale.x = scale.x
		label.rect_position.x = (label.rect_size.x / 2) * (-scale.x / abs(scale.x))
	else:
		if not targeting:
			$AnimationTree.set("parameters/state/current", 0)
	
	motion.y += gravity * delta
	motion.y = min(motion.y, max_fall_speed)
	
	motion = move_and_slide(motion)


func _on_vision_entered(_body):
	player_in_vision = true
	targeting = true
	motion.x = 0
	
	if $AnimationTree.get("parameters/state/current") != 2:
		$AnimationTree.set("parameters/state/current", 0)

var test_timer: SceneTreeTimer

func _on_vision_exited(_body):
	player_in_vision = false
	if test_timer and test_timer.time_left != 0:
		test_timer.time_left = 1
		return
	
	test_timer = get_tree().create_timer(1)
	yield(test_timer, "timeout")
	test_timer = null
	
	if $AnimationTree.get("parameters/state/current") == 2:
		yield(self, "animation_finished")
	
	if not player_in_vision:
		motion.x = direction * SPEED
		targeting = false
		attack_timer = 50


func damage_event():
	sprite.self_modulate = Color.darkred
	yield(get_tree().create_timer(0.1), "timeout")
	sprite.self_modulate = Color.black


func _show_grenade(show_grenade: bool):
	grenade_sprite.visible = show_grenade


func _detach_grenade():
	var detached_grenade = preload("res://Game/Grenade/Grenade.tscn").instance()
	detached_grenade.global_position = grenade_sprite.global_position
	detached_grenade.velocity = Vector2(250 * direction, -300)
	get_parent().add_child(detached_grenade)


func is_class(c_name: String):
	return c_name == "Enemy"
