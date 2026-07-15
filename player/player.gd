extends CharacterBody2D


## Movement speed in pixels per second.
@export var move_speed: float = 300.0

@onready var state_machine: Node = $StateMachine
@onready var input_handler: Node = $InputHandler
@onready var animation_controller: Node = $AnimationController


func _ready() -> void:
	_register_states()
	state_machine.start("idle")


func _physics_process(delta: float) -> void:
	# Delegate movement logic to the active state.
	state_machine.physics_update(delta)


func _register_states() -> void:
	const IdleState = preload("res://player/scripts/states/idle_state.gd")
	const WalkState = preload("res://player/scripts/states/walk_state.gd")

	state_machine.add_state("idle", IdleState.new(self, state_machine))
	state_machine.add_state("walk", WalkState.new(self, state_machine))
