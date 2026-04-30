extends BaseState


# =========================================================
# ENTER STATE
# =========================================================
func enter() -> void:
	pass


# =========================================================
# UPDATE (DECISION ONLY)
# =========================================================
func update(delta: float) -> void:
	var input_dir := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	# Switch to idle if no input
	if input_dir == Vector2.ZERO:
		state_machine.change_state(state_machine.idle_state)
		return

	# Delegate ALL movement + animation to Player
	player.apply_movement(input_dir)
	player.play_animation("walk", input_dir)
