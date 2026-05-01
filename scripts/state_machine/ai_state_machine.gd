extends Node
class_name AIStateMachine

var current_state: PlayerBaseState
var actor: CharacterBody2D

var player_idle_state: PlayerBaseState
var player_walk_state: PlayerBaseState


func init(entity: CharacterBody2D) -> void:
	actor = entity

	# assign states + cache references
	for child in get_children():
		if child is PlayerBaseState:
			child.actor = actor
			child.state_machine = self

			if child.name == "EnemyIdleState":
				player_idle_state = child
			elif child.name == "EnemyWalkState":
				player_walk_state = child

	# safety check
	current_state = player_idle_state if player_idle_state != null else get_child(0)
	current_state.enter()


func update(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func change_state(new_state: PlayerBaseState) -> void:
	if new_state == current_state:
		return

	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()
