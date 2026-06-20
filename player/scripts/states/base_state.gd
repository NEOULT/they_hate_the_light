## Base state for the Player State Machine.
## All player states must extend this class.
extends RefCounted


var player: CharacterBody2D
var state_machine


func _init(player_node: CharacterBody2D, sm) -> void:
	player = player_node
	state_machine = sm


## Called when entering this state.
func enter(_previous_state: String) -> void:
	pass


## Called when exiting this state.
func exit() -> void:
	pass


## Called every frame via _process.
func update(_delta: float) -> void:
	pass


## Called every physics frame via _physics_process.
func physics_update(_delta: float) -> void:
	pass
