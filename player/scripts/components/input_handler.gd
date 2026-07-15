## Handles player input detection.
## Decouples raw input from movement logic by providing clean accessors.
## Supports per-instance configuration via @export for player-specific inputs.
extends Node


## Input actions used by this player instance.
## Default to Godot's built-in UI actions (arrow keys).
@export var input_left: String = "ui_left"
@export var input_right: String = "ui_right"
@export var input_up: String = "ui_up"
@export var input_down: String = "ui_down"


## Returns a normalized direction vector (-1 to 1) for both axes.
func get_direction() -> Vector2:
	return Input.get_vector(input_left, input_right, input_up, input_down).normalized()
