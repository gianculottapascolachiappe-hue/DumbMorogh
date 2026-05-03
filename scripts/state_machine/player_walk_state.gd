#PlayerWalkState.gd
extends PlayerBaseState


func enter() -> void:
	pass


func update(delta: float) -> void:

	# ONLY visual check (no input here anymore)
	if player.velocity.length() <= 0.1:
		player_state_machine.change_state(player_state_machine.player_idle_state)
		return

	player.play_animation("walk", player.velocity.normalized())
