extends AIBaseState


func enter() -> void:
	enemy.velocity = Vector2.ZERO
	enemy.play_animation("idle", Vector2.DOWN)


func update(delta: float) -> void:
	var target = TargetManager.get_target()
	if target == null:
		return

	var dist := enemy.global_position.distance_to(target.global_position)

	if dist <= enemy.aggro_range:
		ai_state_machine.change_state(ai_state_machine.player_walk_state)
