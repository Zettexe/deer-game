extends Node

#-----------------SCENE--SCRIPT------------------#
#    Close your game faster by clicking 'Esc'    #
#   Change mouse mode by clicking 'Shift + F1'   #
#------------------------------------------------#

export var is_debug_enabled: = true
var debug: = false

var debug_quit = "ui_cancel"
var debug_mouse_release = "mouse_release"
var debug_canvas_layer

var level_select
var player

func _ready() -> void:
	if OS.is_debug_build(): debug = is_debug_enabled
	if debug: debug_init()
	
	game_init()

# Production code goes here
func game_init():
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

# Only runs when in the editor and debug set to true
# DO NOT put production code here
func debug_init():
	"""
	Semi-automated key detection for debug keys
	"""
	print("** Debug mode enabled")
	print("** %s to close game" % get_action_keys(debug_quit))
	print("** %s to toggle mouse" % get_action_keys(debug_mouse_release))
	
	print("\n** Controls:")
	print("** %s to move left, %s to move right, %s to jump" % [get_action_keys("left"), get_action_keys("right"), get_action_keys("jump")])
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
		
		if not first: keys += ", "
		else: first = false
		keys += "'%s'" % OS.get_scancode_string(action_list.get_scancode_with_modifiers()).replace("+", " + ")
	return keys


func _process(_delta):
	$DebugGUI/FPSLabel.text = str(Engine.get_frames_per_second()) + " FPS"

func _input(event: InputEvent) -> void:
	if not debug: return
	
	if event.is_action_pressed(debug_quit):
		get_tree().quit() # Quits the game TODO: Pause Menu
	
	if event.is_action_pressed(debug_mouse_release):
		match Input.get_mouse_mode():
			Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
