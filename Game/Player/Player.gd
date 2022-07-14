extends KinematicBody2D

const UP = Vector2(0, -1)
const GRAVITY = 1000
const MAX_FALL_SPEED = 500
const MAX_SPEED = 300.0
const JUMP_FORCE = 400
const ACCELERATION = 20

enum Gun_Mode { RIFLE, SHOTGUN }
var gun_mode = Gun_Mode.SHOTGUN

onready var anim_tree = $AnimationTree
onready var main_sprite: Sprite = $Main
onready var pellet_exit = $Main/Gun/Flash.global_position
onready var gun_mode_label = get_parent().get_node("./DebugGUI/WeaponModeLabel")

var direction = 1
var motion = Vector2()
	
func _ready():
	get_parent().get_node("./DebugGUI/CameraSlider").value = $Camera2D.zoom.x
	anim_tree.active = true 

func _process(_delta):
	var zoom = get_parent().get_node("./DebugGUI/CameraSlider").value
	$Camera2D.zoom = Vector2(zoom, zoom)
	$Camera2D.position.y = -50 * zoom

func _physics_process(delta):
	pellet_exit = $Main/Gun/Flash.global_position
	direction = main_sprite.scale.x / abs(main_sprite.scale.x)
	
	motion.y += GRAVITY * delta
	if motion.y > MAX_FALL_SPEED:
		motion.y = MAX_FALL_SPEED
	
	if Input.is_action_pressed("left"):
		main_sprite.scale.x = -abs(main_sprite.scale.x)
		motion.x -= ACCELERATION
	elif Input.is_action_pressed("right"):
		main_sprite.scale.x = abs(main_sprite.scale.x)
		motion.x += ACCELERATION
	else:
		anim_tree.set("parameters/movement_state/current", 0)
		motion.x = lerp(motion.x, 0, 0.2)
	
	motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
	
	if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		anim_tree.set("parameters/movement_state/current", 1)
		if abs(motion.x) > (MAX_SPEED / 2):
			anim_tree.set("parameters/movement_state/current", 2)
	
	on_floor_checks()
	
	motion = move_and_slide(motion, UP)
	
	if Input.is_action_just_pressed("shoot"):
		var p = load("Game/Pellet/Pellet.tscn")
		
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
		if Input.is_action_just_pressed("jump"):
			anim_tree.set("parameters/jump_state/current", 0)
			motion.y = -JUMP_FORCE
		
		yield(get_tree().create_timer(0.1), "timeout")
		if Input.is_action_pressed("drop_down_platform"):
			position.y += 1
# warning-ignore:return_value_discarded
			move_and_collide(Vector2.ZERO) # Potentially expensive computationally
	else:
		anim_tree.set("parameters/in_air_state/current", 1)
		if motion.y > 0:
			anim_tree.set("parameters/jump_state/current", 1)

func create_pellet(scene, random = 0):
	var pellet = scene.instance()
	pellet.global_position = pellet_exit
	pellet.direction = Vector2(direction, random)
	get_parent().add_child(pellet)
