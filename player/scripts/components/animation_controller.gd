## Controls the player's sprite animation.
## Reacts to state changes and direction to play the correct animation.
extends Node


@onready var _animated_sprite: AnimatedSprite2D = get_node("../AnimatedSprite2D")
@onready var _player: Node = get_node("..")  # Parent is the Player node


## Minimum velocity magnitude to consider the player as moving.
const MOVEMENT_THRESHOLD := 10.0


func _ready() -> void:
	if not _animated_sprite:
		push_error("AnimationController: AnimatedSprite2D not found.")
		return
	
	_animated_sprite.play("walk")


func _process(_delta: float) -> void:
	if not _animated_sprite:
		return
	
	# Flip sprite based on horizontal direction.
	if _player.velocity.x < -MOVEMENT_THRESHOLD:
		_animated_sprite.flip_h = true
	elif _player.velocity.x > MOVEMENT_THRESHOLD:
		_animated_sprite.flip_h = false
	
	# Pause animation when idle, resume when moving.
	var is_moving: bool = _player.velocity.length() > MOVEMENT_THRESHOLD
	_animated_sprite.speed_scale = 1.0 if is_moving else 0.0
