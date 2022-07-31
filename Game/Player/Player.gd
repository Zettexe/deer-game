extends KinematicBody2D

const UP = Vector2.UP
const MAX_SPEED = 300.0
const ACCELERATION = 0.05
const STOPPING_POWER = 0.1
const DEADZONE = 0.1

enum Gun_Mode { RIFLE, SHOTGUN }
var gun_mode = Gun_Mode.SHOTGUN

onready var anim_tree = $AnimationTree
onready var main_sprite: Sprite = $Main
onready var pellet_exit = $Main/Gun/Flash.global_position
onready var gun_mode_label = get_parent().get_node("./DebugGUI/WeaponModeLabel")
onready var player_spawn = get_parent().level.get_node("player_spawn")

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var max_fall_speed = ProjectSettings.get_setting("physics/2d/default_maximum_fall_speed")

var jump_force = 400
var walk_toggle = false
var direction = 1
var motion = Vector2()
var action_strength = 0
var time_held_drop = 0
var jumps_left = 2
var double_jump = false
var variable_jump_height = false
var zoom
var zoom_updated = false


func _ready():
	zoom = $Camera2D.zoom
	anim_tree.active = true

func _process(_delta):
	if zoom_updated and zoom != $Camera2D.zoom:
		$Camera2D.zoom = zoom
		zoom_updated = false
	
	pellet_exit = $Main/Gun/Flash.global_position
	
	if Input.is_action_just_pressed("player_toggle_walk"):
		walk_toggle = !walk_toggle

func _physics_process(delta):
	action_strength = Input.get_axis("player_left", "player_right")
	action_strength = action_strength if abs(action_strength) > DEADZONE else 0
	
	direction = main_sprite.scale.x / abs(main_sprite.scale.x)
	
	motion.y += gravity * delta
	motion.y = min(motion.y, max_fall_speed)
	
	motion.x = lerp(motion.x, action_strength * MAX_SPEED, ACCELERATION if action_strength else STOPPING_POWER)
	
	var walk_speed = ((
		(abs(motion.x) - (MAX_SPEED * DEADZONE))
		/ (MAX_SPEED / 2)
		+ (0.2 * (MAX_SPEED / 300))
	) * 2)
	
	anim_tree.set("parameters/walk_speed/scale", walk_speed)
	if action_strength:
		main_sprite.scale.x = action_strength / abs(action_strength) * abs(main_sprite.scale.x)
		anim_tree.set("parameters/movement_state/current", 1)
		if abs(motion.x) >= (MAX_SPEED / 3):
			anim_tree.set("parameters/movement_state/current", 2)
	else:
		anim_tree.set("parameters/movement_state/current", 0)
	
	on_floor_checks()
	motion = move_and_slide(motion, UP)
	
	if abs(motion.x) > MAX_SPEED / 3:
		var new_zoom = lerp($Camera2D.zoom.x, zoom.x * 1.1, 0.01)
		$Camera2D.zoom = Vector2.ONE * new_zoom
	else:
		$Camera2D.zoom = Vector2.ONE * lerp($Camera2D.zoom.x, zoom.x, 0.1)
	
	if Input.is_action_just_pressed("player_shoot"):
		var p = load("Game/Pellet/Pellet.tscn")
		
		$GunPlayer.play()
		
		match gun_mode:
			Gun_Mode.RIFLE:
				create_pellet(p)
			Gun_Mode.SHOTGUN:
				for _i in range(0, 3):
					create_pellet(p, rand_range(-1, 1) * 0.1)
	
	if Input.is_action_just_pressed("player_cycle_weapon_mode"):
		gun_mode += 1
		if gun_mode >= Gun_Mode.size():
			gun_mode = 0
		gun_mode_label.text = "Weapon Mode: " + Gun_Mode.keys()[gun_mode]
	
	if Input.is_action_just_pressed("player_respawn"):
		if player_spawn:
			position = player_spawn.position
		else:
			position = Vector2.ZERO
	

func on_floor_checks():
	if is_on_floor():
		anim_tree.set("parameters/in_air_state/current", 0)
		jumps_left = 2
	else:
		anim_tree.set("parameters/in_air_state/current", 1)
		if motion.y > 0:
			anim_tree.set("parameters/jump_state/current", 1)
			if motion.y == max_fall_speed:
				anim_tree.set("parameters/jump_state/current", 2)
	
	if (
		Input.is_action_just_pressed("player_jump") 
		and ((double_jump and jumps_left > 0) 
		or is_on_floor())
	):
		if (
			Input.is_action_pressed("player_down") 
			and is_on_floor() 
			and action_strength == 0
		):
			position.y += 1
			# warning-ignore:return_value_discarded
			move_and_collide(Vector2.ZERO)  # Potentially expensive calculation
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

func _update_camera_size(value):
	zoom = Vector2.ONE * value
	$Camera2D.position.y = -50 * value
	zoom_updated = true

func _update_jump_height(value):
	jump_force = value

func _update_double_jump(value):
	double_jump = value

func _update_variable_jump_height(value):
	variable_jump_height = value

func is_class(c_name: String):
	return c_name == "Player"
