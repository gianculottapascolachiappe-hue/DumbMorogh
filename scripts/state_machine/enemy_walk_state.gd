extends AIBaseState


func enter() -> void:
	pass


func update(delta: float) -> void:
	var target = TargetManager.get_target()

	if target == null:
		ai_state_machine.change_state(ai_state_machine.enemy_idle_state)
		return

	var dist := enemy.global_position.distance_to(target.global_position)
	
	# leash back to idle if target too far
	if dist > enemy.aggro_range * 1.5:
		ai_state_machine.change_state(ai_state_machine.player_idle_state)
		return

	var dir: Vector2 = (target.global_position - enemy.global_position).normalized()

	enemy.last_direction = dir
	
	enemy.apply_movement(dir)
	enemy.play_animation(dir)

	enemy.apply_movement(dir)
	enemy.play_animation("walk", dir)
