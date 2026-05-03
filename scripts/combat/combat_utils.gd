#CombatUtils.gd
extends Node
class_name CombatUtils


static func enter_combat(entity: Node, state: Dictionary) -> void:
	if state.in_combat:
		return

	state.in_combat = true
	state.combat_timer = state.combat_timeout

	if entity.has_method("on_enter_combat"):
		entity.on_enter_combat()


static func exit_combat(entity: Node, state: Dictionary) -> void:
	if not state.in_combat:
		return

	state.in_combat = false

	if entity.has_method("on_exit_combat"):
		entity.on_exit_combat()
