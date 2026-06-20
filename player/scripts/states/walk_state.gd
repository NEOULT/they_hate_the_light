## Walk state: player moves horizontally.
## Applies gravity and horizontal movement based on input.
## Transitions to IdleState when no input is detected.
extends "res://player/scripts/states/base_state.gd"


func physics_update(_delta: float) -> void:
	var direction: Vector2 = player.input_handler.get_direction()

	if direction.x == 0.0:
		state_machine.transition_to("idle")
		return

	player.velocity.x = direction.x * player.move_speed
	player.move_and_slide()
