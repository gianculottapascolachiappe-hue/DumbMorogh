extends PlayerBaseState

var _has_started_attack := false


func enter() -> void:
	print("➡️ ENTER AttackState")
	_has_started_attack = false


func update(delta: float) -> void:
	if player.current_target == null:
		_return_to_move_state()
		return

	var to_target: Vector2 = (player.current_target.global_position - player.global_position).normalized()
	var facing: Vector2 = player.last_direction.normalized()

	# =========================================================
	# HARD GATE: facing check FIRST
	# =========================================================
	if facing.dot(to_target) < 0.5:
		print("🧭 YOU ARE FACING THE WRONG DIRECTION!")
		_return_to_move_state()
		return

	# =========================================================
	# HARD GATE: range check
	# =========================================================
	var dist := player.global_position.distance_to(player.current_target.global_position)

	if dist > player.attack_range:
		_return_to_move_state()
		return

	# =========================================================
	# PLAY ANIMATION ONLY IF VALID
	# =========================================================
	if not _has_started_attack:
		print("🎬 Play attack animation")
		player.play_animation("attack", player.last_direction)
		_has_started_attack = true


func _return_to_move_state() -> void:
	print("⬅️ EXIT AttackState")

	# 🔥 CRITICAL RESET
	player.is_attacking = false

	_has_started_attack = false

	if player.velocity.length() > 0.1:
		player_state_machine.change_state(player_state_machine.player_walk_state)
	else:
		player_state_machine.change_state(player_state_machine.player_idle_state)
