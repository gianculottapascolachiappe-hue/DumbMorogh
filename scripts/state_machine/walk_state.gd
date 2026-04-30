extends BaseState


func enter() -> void:
	player.play_animation(player.walk_anim, player.last_direction)


func update(delta: float) -> void:
	var input_dir = Input.get_vector(
		player.input_left,
		player.input_right,
		player.input_up,
		player.input_down
	)

	if input_dir == Vector2.ZERO:
		state_machine.change_state(state_machine.idle_state)
		return

	player.apply_movement(input_dir)
	player.play_animation(player.walk_anim, input_dir)
