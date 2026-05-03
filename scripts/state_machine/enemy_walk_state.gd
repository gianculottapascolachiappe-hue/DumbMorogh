#EnemyWalkState.gd
extends AIBaseState

func enter() -> void:
	pass


func update(delta: float) -> void:
	if enemy.is_attacking:
		return
	var target = enemy.target

	if target == null or not is_instance_valid(target):
		ai_state_machine.change_state(ai_state_machine.enemy_idle_state)
		return

	var dist := enemy.global_position.distance_to(target.global_position)

	if dist > enemy.aggro_range * 1.5:
		ai_state_machine.change_state(ai_state_machine.enemy_idle_state)
		return

	# 🔥 ONLY control animation here
	if enemy.velocity.length() > 1.0:
		enemy.play_animation("walk", enemy.velocity)
	else:
		enemy.play_animation("idle", enemy.last_direction)
