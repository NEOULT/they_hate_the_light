## Clase base para todos los eventos del juego.
##
## Cada evento debe extender esta clase e implementar:
##   - start_event(player1, player2) → inicia el evento
##   - stop_event() → detiene el evento prematuramente
##
## Emite `event_completed(resultado)` cuando termina.
## resultado es un Dictionary con claves como "ganador", "puntos", etc.
extends Node


@warning_ignore("unused_signal")
signal event_completed(resultado: Dictionary)

## Referencias a los jugadores (asignadas por EventStage)
var player1: Node
var player2: Node

## Nombre visible del evento (para UI)
@export var event_name: String = "Evento"


## Inicia el evento. Recibe referencias a los dos jugadores.
func start_event(p1: Node, p2: Node) -> void:
	player1 = p1
	player2 = p2


## Detiene el evento antes de que termine naturalmente.
func stop_event() -> void:
	pass


## Devuelve true si el evento sigue en ejecución.
func is_active() -> bool:
	return false
