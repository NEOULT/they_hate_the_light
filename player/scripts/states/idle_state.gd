## Idle state: player stands still.
## Applies friction to both axes to decelerate.
## Transitions to WalkState when any movement input is detected.
extends "res://player/scripts/states/base_state.gd"


func physics_update(_delta: float) -> void:
	var direction: Vector2 = player.input_handler.get_direction()

	# Transition to walk if there's input in any direction.
	if direction != Vector2.ZERO:
		state_machine.transition_to("walk")
		return

	# Apply friction/deceleration to both axes.
	player.velocity.x = move_toward(player.velocity.x, 0.0, player.move_speed)
	player.velocity.y = move_toward(player.velocity.y, 0.0, player.move_speed)
	player.move_and_slide()
