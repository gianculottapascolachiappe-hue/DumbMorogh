#AIStateMachine
extends Node

var current_state: AIBaseState
var enemy: CharacterBody2D

var enemy_idle_state: AIBaseState
var enemy_walk_state: AIBaseState


func init(e: CharacterBody2D) -> void:
	enemy = e

	enemy_idle_state = $EnemyIdleState
	enemy_walk_state = $EnemyWalkState

	for s in [enemy_idle_state, enemy_walk_state]:
		s.enemy = enemy
		s.ai_state_machine = self

	current_state = enemy_idle_state
	current_state.enter()


func update(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func change_state(new_state: AIBaseState) -> void:
	if new_state == current_state:
		return

	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()
