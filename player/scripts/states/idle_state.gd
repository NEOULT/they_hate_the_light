## Idle state: player stands still or is in the air.
## Applies gravity and horizontal friction.
## Transitions to WalkState when horizontal movement input is detected.
extends "res://player/scripts/states/base_state.gd"


func physics_update(_delta: float) -> void:
	var direction: Vector2 = player.input_handler.get_direction()

	# Transition to walk if there's horizontal input.
	if direction.x != 0.0:
		state_machine.transition_to("walk")
		return

	# Apply horizontal friction/deceleration.
	player.velocity.x = move_toward(player.velocity.x, 0.0, player.move_speed)
	player.move_and_slide()
