extends Node

var current_state: PlayerBaseState
var player: CharacterBody2D

var player_idle_state: PlayerBaseState
var player_walk_state: PlayerBaseState


func init(p: CharacterBody2D) -> void:
	player = p

	player_idle_state = $PlayerIdleState
	player_walk_state = $PlayerWalkState

	for s in [player_idle_state, player_walk_state]:
		s.player = player
		s.player_state_machine = self

	current_state = player_idle_state
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
