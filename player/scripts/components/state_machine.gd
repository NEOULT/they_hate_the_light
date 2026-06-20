## Generic Finite State Machine.
## Manages state transitions and delegates update calls to the active state.
extends Node


## Emitted when the state changes. Provides the new state name.
signal state_changed(state_name: String)

## The currently active state name (read-only).
var current_state: String = "" :
	get:
		return _current_state

var _current_state: String = ""

## Maps state names to BaseState instances.
var _states: Dictionary = {}

## Registers a state with the given name.
func add_state(name: String, state) -> void:
	_states[name] = state


## Initializes the FSM to the given starting state.
func start(initial_state: String) -> void:
	assert(_states.has(initial_state), "State '%s' not registered." % initial_state)
	_current_state = initial_state
	_states[_current_state].enter("")


## Transitions to a new state, calling exit() on the old and enter() on the new.
func transition_to(new_state: String) -> void:
	assert(_states.has(new_state), "State '%s' not registered." % new_state)
	
	var previous_state := _current_state
	_states[_current_state].exit()
	_current_state = new_state
	_states[_current_state].enter(previous_state)
	
	state_changed.emit(_current_state)


## Delegates _process to the active state.
func update(delta: float) -> void:
	if _states.has(_current_state):
		_states[_current_state].update(delta)


## Delegates _physics_process to the active state.
func physics_update(delta: float) -> void:
	if _states.has(_current_state):
		_states[_current_state].physics_update(delta)
