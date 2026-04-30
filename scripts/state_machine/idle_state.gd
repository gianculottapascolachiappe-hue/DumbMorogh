extends BaseState


# =========================================================
# ENTER STATE
# =========================================================
func enter() -> void:
	player.apply_movement(Vector2.ZERO)
	player.play_animation("idle", player.last_direction)


# =========================================================
# UPDATE LOOP (DECISION ONLY)
# =========================================================
func update(delta: float) -> void:
	var input_dir := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	if input_dir != Vector2.ZERO:
		state_machine.change_state(state_machine.walk_state)
