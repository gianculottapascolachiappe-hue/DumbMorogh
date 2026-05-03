#Area2D.gd
extends Area2D

@onready var enemy = get_parent()

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		TargetManager.set_target(enemy)
