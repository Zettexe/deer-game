extends Control

signal pressed()

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("pressed")
