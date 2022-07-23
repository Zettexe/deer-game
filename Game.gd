extends Node

#-----------------SCENE--SCRIPT------------------#
#    Close your game faster by clicking 'Esc'    #
#   Change mouse mode by clicking 'Shift + F1'   #
#------------------------------------------------#

export var is_debug_enabled := true
var debug := false

var debug_mouse_release = "debug_mouse_release"
var debug_canvas_layer

var open_menu = "gui_pause"
var level_select
var level
var player

onready var gui_background = $GUI/GUIBackround
onready var gui_pause_menu = $GUI/PauseMenu
onready var pause_menu_open = gui_pause_menu.visible


func _ready() -> void:
	if OS.is_debug_build():
		debug = is_debug_enabled
	if debug:
		debug_init()

	game_init()


# Production code goes here
func game_init():
	gui_pause_menu.get_node("ExitButton").connect("pressed", self, "_exit_game")
	gui_pause_menu.get_node("CancelButton").connect("pressed", self, "_toggle_pause_menu")
	gui_background.connect("pressed", self, "_toggle_pause_menu")


# Only runs when in the editor and debug set to true
# DO NOT put production code here
func debug_init():
	"""
	Semi-automated key detection for debug keys
	"""
	print("** Debug mode enabled")
	print("** %s to open game menu" % get_action_keys(open_menu))
	print("** %s to toggle mouse" % get_action_keys(debug_mouse_release))

	print("\n** Controls:")
	print(
		(
			"** %s to move left, %s to move right, %s to jump"
			% [get_action_keys("left"), get_action_keys("right"), get_action_keys("jump")]
		)
	)
	print("** %s to cycle weapon modes" % get_action_keys("cycle_weapon_mode"))
	print("** %s to shoot" % get_action_keys("shoot"))

	level_select = preload("res://Game/LevelSelect/LevelSelect.tscn").instance()
	add_child(level_select)


func get_action_keys(action):
	var keys = ""
	var first = true
	for action_list in InputMap.get_action_list(action):
		if not action_list is InputEventKey:
			continue

		if not first:
			keys += ", "
		else:
			first = false
		keys += (
			"'%s'"
			% OS.get_scancode_string(action_list.get_scancode_with_modifiers()).replace("+", " + ")
		)
	return keys


func _level_selected(_player, _level):
	player = _player
	level = _level

	var camera_distance = gui_pause_menu.get_node("Grid/CameraDistanceOption/Slider")
	camera_distance.editable = true
	camera_distance.value = player.get_node("Camera2D").zoom.x
	camera_distance.connect("value_changed", player, "_update_camera_size")

	var jump_height = gui_pause_menu.get_node("Grid/JumpHeightOption/Slider")
	jump_height.editable = true
	jump_height.value = player.jump_force
	jump_height.connect("value_changed", player, "_update_jump_height")

	var double_jump = gui_pause_menu.get_node("Grid/DoubleJumpOption")
	double_jump.disabled = false
	double_jump.pressed = player.double_jump
	double_jump.connect("toggled", player, "_update_double_jump")

	var var_jump_height = gui_pause_menu.get_node("Grid/VariableJumpHeightOption")
	var_jump_height.disabled = false
	var_jump_height.pressed = player.variable_jump_height
	var_jump_height.connect("toggled", player, "_update_variable_jump_height")

	_level.pause_mode = Node.PAUSE_MODE_STOP
	_player.pause_mode = Node.PAUSE_MODE_STOP

	add_child(_level)
	add_child(_player)
	remove_child(level_select)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	get_node("DebugGUI/WeaponModeLabel").show()
	


func _process(_delta):
	$DebugGUI/FPSLabel.text = str(Engine.get_frames_per_second()) + " FPS"


func _toggle_pause_menu():
	pause_menu_open = !pause_menu_open
	
	gui_background.visible = pause_menu_open
	gui_pause_menu.visible = pause_menu_open
	get_tree().paused = pause_menu_open
	_set_mouse_mode(pause_menu_open)


func _set_mouse_mode(visible):
	if visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _exit_game():
	get_tree().quit()


func _input(event: InputEvent) -> void:
	if player and event.is_action_pressed(open_menu):
		_toggle_pause_menu()

	if not debug:
		return

	if event.is_action_pressed(debug_mouse_release):
		match Input.get_mouse_mode():
			Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
