extends AIBaseState

func enter() -> void:
	enemy.apply_movement(Vector2.ZERO)

	if enemy.last_direction == Vector2.ZERO:
		enemy.last_direction = Vector2.DOWN

	enemy.play_animation("idle", enemy.last_direction)


func update(delta: float) -> void:
	var target = enemy.target

	enemy.apply_movement(Vector2.ZERO)

	if target == null or not is_instance_valid(target):
		enemy.play_animation("idle", enemy.last_direction)
		return

	var dist := enemy.global_position.distance_to(target.global_position)

	if dist <= enemy.aggro_range:
		ai_state_machine.change_state(ai_state_machine.enemy_walk_state)
		return

	enemy.play_animation("idle", enemy.last_direction)
