extends PlayerBaseState


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
		player_state_machine.change_state(player_state_machine.player_walk_state)
