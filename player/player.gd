extends CharacterBody2D


## Movement speed in pixels per second.
@export var move_speed: float = 300.0
## Initial jump velocity (negative = upward).
@export var jump_velocity: float = -400.0

@onready var state_machine: Node = $StateMachine
@onready var input_handler: Node = $InputHandler
@onready var animation_controller: Node = $AnimationController


func _ready() -> void:
	_register_states()
	state_machine.start("idle")


func _physics_process(delta: float) -> void:
	# Apply gravity when not on floor.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump input.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Delegate movement logic to the active state.
	state_machine.physics_update(delta)


func _register_states() -> void:
	const IdleState = preload("res://player/scripts/states/idle_state.gd")
	const WalkState = preload("res://player/scripts/states/walk_state.gd")

	state_machine.add_state("idle", IdleState.new(self, state_machine))
	state_machine.add_state("walk", WalkState.new(self, state_machine))
