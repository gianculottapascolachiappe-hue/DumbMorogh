#TargetManager.gd
extends Node

var current_target: Node = null


func set_target(target: Node) -> void:
	if current_target == target:
		return

	# turn OFF old target indicator
	if current_target and current_target.has_method("set_targeted"):
		current_target.set_targeted(false)

	current_target = target

	# turn ON new target indicator
	if current_target and current_target.has_method("set_targeted"):
		current_target.set_targeted(true)

	print("Target selected:", target.name)


func clear_target() -> void:
	if current_target and current_target.has_method("set_targeted"):
		current_target.set_targeted(false)

	current_target = null
	print("Target cleared")


# =========================================================
# SAFETY HELPERS (optional but recommended)
# =========================================================
func get_target() -> Node:
	if current_target == null:
		return null

	if not is_instance_valid(current_target):
		current_target = null
		return null

	return current_target
