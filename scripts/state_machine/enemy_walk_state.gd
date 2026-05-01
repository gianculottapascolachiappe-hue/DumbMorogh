extends AIBaseState

func enter() -> void:
	pass


func update(delta: float) -> void:
	var target = enemy.target

	if target == null or not is_instance_valid(target):
		ai_state_machine.change_state(ai_state_machine.enemy_idle_state)
		return

	var dist := enemy.global_position.distance_to(target.global_position)

	if dist > enemy.aggro_range * 1.5:
		ai_state_machine.change_state(ai_state_machine.enemy_idle_state)
		return

	var dir: Vector2 = (target.global_position - enemy.global_position).normalized()

	enemy.apply_movement(dir)

	enemy.play_animation("walk", dir)
