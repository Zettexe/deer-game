extends Control

var COLUMNS = 5
var ROWS = 6

func _ready():
	var grid_container = $GridContainer
	
	var font = preload("res://Assets/LevelSelectButtonFont.tres")
	for i in range(0, COLUMNS * ROWS):
		var button = Button.new()
		button.add_font_override("Test", font)
		grid_container.add_child(button)
	
	var total_spacing = Vector2(grid_container.spacing * (COLUMNS - 1), grid_container.spacing * (ROWS - 1))
	grid_container.cell_size.x = (grid_container.rect_size.x - total_spacing.x) / COLUMNS
	grid_container.cell_size.y = (grid_container.rect_size.y - total_spacing.y) / ROWS
	
	var levels = {}
	var dir = Directory.new()
	dir.open("res://Levels")
	dir.list_dir_begin()
	
	var i = 0
	while true:
		var level_name = dir.get_next()
		if level_name == "": break
		if level_name.begins_with("."): continue
		if i >= COLUMNS * ROWS: 
			push_warning("Unable to display all levels: Too many levels")
			break
		
		levels[level_name] = load("res://Levels/%s" % [level_name]).instance()
		i += 1
	
	dir.list_dir_end()
	
	i = 0
	for button in grid_container.get_children():
		if i >= levels.size():
			button.disabled = true
			continue
		
		button.text = levels.keys()[i]
		button.connect("button_up", self, "level_init", [levels.values()[i]])
		i += 1
		pass


func level_init(level):
	# Load plane and camera
	var player = preload("res://Game/Player/Player.tscn").instance()
	
	# If plane spawn point is defined spawn it there
	# Otherwise leave it to default
	var player_spawn = level.get_node("plane_spawn")
	if player_spawn:
		player.transform = player_spawn.transform
	
	var game = get_parent()
	
	# TODO: Add level changing system
	game.add_child(level)
	
	game.add_child(player)
	
	set_enemies_labels(level)
	
#	var a_enemy = get_node("Attacking Enemy/AnimationTree")
#	if a_enemy:
#		a_enemy.set("parameters/state/current", 2)
	game.remove_child(self)

func set_enemies_labels(node):
	for N in node.get_children():
		print(N.name)
		print(N.is_class("Enemy"))
		if N.is_class("Enemy"):
			var label = Label.new()
			label.theme = load("./Assets/DebugTheme.tres")
			label.text = N.name
			get_parent().add_child(label)
			label.rect_position = N.position + Vector2(0 - (label.rect_size.x / 2), -60)
			continue
		
		if N.get_child_count() > 0:
			set_enemies_labels(N)
