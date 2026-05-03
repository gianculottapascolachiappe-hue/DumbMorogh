#PlayerIdleSTate.gd
extends PlayerBaseState


func enter() -> void:
	player.play_animation("idle", player.last_direction)


func update(delta: float) -> void:
	# ONLY visual decision: is player moving?
	if player.velocity.length() > 0.1:
		player_state_machine.change_state(player_state_machine.player_walk_state)
