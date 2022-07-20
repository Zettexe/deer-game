extends KinematicBody2D

const UP = Vector2.UP
const GRAVITY = 1000
const MAX_FALL_SPEED = 500
const MAX_SPEED = 300.0
const ACCELERATION = 20
const DEADZONE = 0.1

enum Gun_Mode { RIFLE, SHOTGUN }
var gun_mode = Gun_Mode.SHOTGUN

onready var anim_tree = $AnimationTree
onready var main_sprite: Sprite = $Main
onready var pellet_exit = $Main/Gun/Flash.global_position
onready var gun_mode_label = get_parent().get_node("./DebugGUI/WeaponModeLabel")

var jump_force = 400

var direction = 1
var motion = Vector2()
var action_strength = 0
var time_held_drop = 0
var jumps_left = 2
var double_jump = false
var variable_jump_height = false


func _ready():
	var game = get_parent()
	game.get_node("./DebugGUI/CameraSlider").value = $Camera2D.zoom.x
	game.get_node("./DebugGUI/JumpHeightSlider").value = jump_force
	game.get_node("./DebugGUI/DoubleJumpCheck").pressed = double_jump
	game.get_node("./DebugGUI/DoubleJumpCheck").pressed = variable_jump_height
	
	anim_tree.active = true


func _process(_delta):
	var game = get_parent()
	var zoom = game.get_node("./DebugGUI/CameraSlider").value
	$Camera2D.zoom = Vector2(zoom, zoom)
	$Camera2D.position.y = -50 * zoom
	
	jump_force = game.get_node("./DebugGUI/JumpHeightSlider").value
	double_jump = game.get_node("./DebugGUI/DoubleJumpCheck").pressed
	variable_jump_height = game.get_node("./DebugGUI/DoubleJumpCheck").pressed
	
	pellet_exit = $Main/Gun/Flash.global_position


func _physics_process(delta):
	action_strength = Input.get_axis("left", "right")
	action_strength = action_strength if abs(action_strength) > DEADZONE else 0

	direction = main_sprite.scale.x / abs(main_sprite.scale.x)

	motion.y += GRAVITY * delta
	motion.y = min(motion.y, MAX_FALL_SPEED)

	if Input.is_action_pressed("left") and not Input.is_action_pressed("right") and action_strength:
		main_sprite.scale.x = -abs(main_sprite.scale.x)
		motion.x -= ACCELERATION
	elif Input.is_action_pressed("right") and not Input.is_action_pressed("left") and action_strength:
		main_sprite.scale.x = abs(main_sprite.scale.x)
		motion.x += ACCELERATION
	else:
		anim_tree.set("parameters/movement_state/current", 0)
		motion.x = lerp(motion.x, 0, 0.1)

	motion.x = clamp(motion.x, -MAX_SPEED * abs(action_strength), MAX_SPEED * abs(action_strength))

	var walk_speed = (
		((abs(motion.x) - (MAX_SPEED * DEADZONE)) / (MAX_SPEED / 2) + (0.2 * (MAX_SPEED / 300)))
		* 2
	)
	
	anim_tree.set("parameters/walk_speed/scale", walk_speed)
	if action_strength:
		anim_tree.set("parameters/movement_state/current", 1)
		if abs(motion.x) >= (MAX_SPEED / 3):
			anim_tree.set("parameters/movement_state/current", 2)

	on_floor_checks()
	motion = move_and_slide(motion, UP)
	
#	if motion.y != 0:
#		print(motion.y)
	
	if Input.is_action_just_pressed("shoot"):
		var p = load("Game/Pellet/Pellet.tscn")
		
		$GunPlayer.play()
		
		match gun_mode:
			Gun_Mode.RIFLE:
				create_pellet(p)
			Gun_Mode.SHOTGUN:
				for _i in range(0, 3):
					create_pellet(p, rand_range(-1, 1) * 0.1)

	if Input.is_action_just_pressed("cycle_weapon_mode"):
		gun_mode += 1
		if gun_mode >= Gun_Mode.size():
			gun_mode = 0
		gun_mode_label.text = "Weapon Mode: " + Gun_Mode.keys()[gun_mode]

	if Input.is_action_just_pressed("respawn"):
		position = Vector2.ZERO


func on_floor_checks():
	if is_on_floor():
		anim_tree.set("parameters/in_air_state/current", 0)
		jumps_left = 2
	else:
		anim_tree.set("parameters/in_air_state/current", 1)
		if motion.y > 0:
			anim_tree.set("parameters/jump_state/current", 1)
	
	if Input.is_action_just_pressed("jump") and ((double_jump and jumps_left > 0) or is_on_floor()):
		if Input.is_action_pressed("down") and is_on_floor() and action_strength == 0:
			position.y += 1
			# warning-ignore:return_value_discarded
			move_and_collide(Vector2.ZERO)  # Potentially expensive computationally
		else:
			anim_tree.set("parameters/jump_state/current", 0)
			motion.y = -jump_force
			jumps_left -= 1


func create_pellet(scene, random = 0):
	var pellet = scene.instance()
	pellet.global_position = pellet_exit
	pellet.direction = Vector2(direction, random)
	get_parent().add_child(pellet)


func _play_footstep():
	$FootstepPlayer.pitch_scale = rand_range(0.9, 1.1)
	$FootstepPlayer.play()

func damage_event():
	main_sprite.self_modulate = Color.darkred
	yield(get_tree().create_timer(0.1), "timeout")
	main_sprite.self_modulate = Color.white

func is_class(c_name: String):
	return c_name == "Player"
