## Handles player input detection.
## Decouples raw input from movement logic by providing clean accessors.
extends Node


## Input actions names used by the player.
const INPUT_LEFT := "ui_left"
const INPUT_RIGHT := "ui_right"
const INPUT_UP := "ui_up"
const INPUT_DOWN := "ui_down"


## Returns a normalized direction vector (-1 to 1) for both axes.
func get_direction() -> Vector2:
	return Input.get_vector(INPUT_LEFT, INPUT_RIGHT, INPUT_UP, INPUT_DOWN).normalized()
