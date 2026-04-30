extends BaseState


func enter() -> void:
	player.apply_movement(Vector2.ZERO)
	player.play_animation(player.idle_anim, player.last_direction)


func update(delta: float) -> void:
	var input_dir = Input.get_vector(
		player.input_left,
		player.input_right,
		player.input_up,
		player.input_down
	)

	if input_dir != Vector2.ZERO:
		state_machine.change_state(state_machine.walk_state)
