#PlayerAttackState.gd
extends PlayerBaseState


func enter() -> void:
	pass


func update(delta: float) -> void:

	# ONLY visual condition: are we still attacking?
	if not player.is_attacking:
		_return_to_move_state()
		return

	if player.current_target == null:
		_return_to_move_state()
		return

	var dir = (player.current_target.global_position - player.global_position).normalized()
	player.last_direction = dir

	player.play_animation("attack", dir)


func _return_to_move_state() -> void:
	if player.velocity.length() > 0.1:
		player_state_machine.change_state(player_state_machine.player_walk_state)
	else:
		player_state_machine.change_state(player_state_machine.player_idle_state)
