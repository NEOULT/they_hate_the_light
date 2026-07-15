extends Node2D


@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var _activando := false


## Detecta clicks cerca de la llave para testeo rápido.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if global_position.distance_to(event.global_position) < 50:
			activar()


## Se emite al terminar la animación completa de la llave, con la suma total.
signal animacion_completada(suma: int)

## Activa la animación de giro y el sonido de la llave.
## `veces` indica cuántas veces gira la llave (según la suma de los dados).
func activar(veces: int = 1) -> void:
	if _activando:
		return
	_activando = true

	# Acelerar la animación para que cada vuelta dure ~0.3 s
	# Base: 10 FPS × 7 frames = 0.7 s/vuelta. Speed 25 = 0.28 s/vuelta
	_animated_sprite.speed_scale = 2.5

	# Reproducir el giro `veces` veces con una pausa de 0.3 s entre cada una
	# El sonido se reproduce en cada vuelta
	for i in range(veces):
		_audio_player.stop()
		_audio_player.stream_paused = false
		_audio_player.play()
		_animated_sprite.play("spin")
		await _animated_sprite.animation_finished
		if i < veces - 1:
			await get_tree().create_timer(0.3).timeout

	_animated_sprite.speed_scale = 1.0
	_activando = false
	animacion_completada.emit(veces)
