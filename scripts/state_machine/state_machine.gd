extends Node

var current_state: BaseState
var player: CharacterBody2D

var idle_state: BaseState
var walk_state: BaseState


func init(p: CharacterBody2D) -> void:
	player = p

	idle_state = $IdleState
	walk_state = $WalkState

	for s in [idle_state, walk_state]:
		s.player = player
		s.state_machine = self

	current_state = idle_state
	current_state.enter()


func update(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func change_state(new_state: BaseState) -> void:
	if new_state == current_state:
		return

	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()
