extends Control

var COLUMNS = 5
var ROWS = 6

func _ready():
	var grid_container = $GridContainer
	
	var font = preload("res://Game/LevelSelect/LevelSelectButtonFont.tres")
	
	var total_spacing = Vector2(grid_container.spacing * (COLUMNS - 1), grid_container.spacing * (ROWS - 1))
	grid_container.cell_size.x = (grid_container.rect_size.x - total_spacing.x) / COLUMNS
	grid_container.cell_size.y = (grid_container.rect_size.y - total_spacing.y) / ROWS
	
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
		
		var button = Button.new()
		button.add_font_override("Test", font)
		grid_container.add_child(button)
		button.text = level_name
		button.connect("button_up", self, "level_init", [load("res://Levels/%s" % [level_name]).instance()])

		i += 1
	
	dir.list_dir_end()


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
	
	game.remove_child(self)

func set_enemies_labels(node):
	for N in node.get_children():
		if N.is_class("Enemy"):
			var label = Label.new()
			label.theme = load("Game/DebugTheme.tres")
			label.text = N.name
			get_parent().add_child(label)
			label.rect_position = N.position + Vector2(0 - (label.rect_size.x / 2), -60)
			continue
		
		if N.get_child_count() > 0:
			set_enemies_labels(N)
