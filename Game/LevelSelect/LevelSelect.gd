extends Control

func _ready():
	var grid_container = $GridContainer
	
	var font = preload("res://Game/LevelSelect/LevelSelectButtonFont.tres")
	
	var dir = Directory.new()
	dir.open("res://Levels")
	dir.list_dir_begin()
	
	var i = 0
	while true:
		var level_name = dir.get_next()
		if level_name == "": break
		if level_name.begins_with("."): continue
		if i >= grid_container.columns * grid_container.rows: 
			push_warning("Unable to display all levels: Too many levels")
			break
		
		var button = Button.new()
		button.add_font_override("font", font)
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
	var player_spawn = level.get_node("player_spawn")
	if player_spawn:
		player.position = player_spawn.position
	
#	set_enemies_labels(level)
	
	get_parent()._level_selected(player, level)
	

func set_enemies_labels(node):
	var container = Node2D.new()
	get_parent().add_child(container)
	for N in node.get_children():
		if N.is_class("Enemy"):
			var label = Label.new()
			label.theme = load("Game/DebugTheme.tres")
			label.text = N.name
			container.add_child(label)
			label.rect_position = N.position + Vector2(0 - (label.rect_size.x / 2), -60)
			label.anchor_bottom
			N.label = label
			continue
		
		if N.get_child_count() > 0:
			set_enemies_labels(N)
