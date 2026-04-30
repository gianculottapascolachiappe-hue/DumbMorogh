extends Node

var current_target: Node = null

func set_target(target: Node) -> void:
	current_target = target
	print("Target selected:", target.name)

func clear_target() -> void:
	current_target = null
	print("Target cleared")
