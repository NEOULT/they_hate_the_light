## Walk state: player moves in any direction.
## Sets velocity based on input direction.
## Transitions to IdleState when no input is detected.
extends "res://player/scripts/states/base_state.gd"


func physics_update(_delta: float) -> void:
	var direction: Vector2 = player.input_handler.get_direction()

	if direction == Vector2.ZERO:
		state_machine.transition_to("idle")
		return

	player.velocity = direction * player.move_speed
	player.move_and_slide()
