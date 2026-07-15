extends Node2D

## Dado pixel art con animación de agite.
##
## Uso:
##   dado.empezar_agite()          # Inicia el temblor continuo mientras se llena la barra
##   dado.detener_agite(4)         # Muestra la cara 4 con rebote (barra llena)
##   dado.parar_agite()            # Detiene el temblor sin resultado (barra se drenó)
##   dado.lanzar(4)                # Animación completa de un solo golpe (testeo)


@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var _pos_original: Vector2
var _lanzando := false
var _agitando := false
var _jitter_tween: Tween = null
var _agite_timer: Timer = null


func _ready() -> void:
	_pos_original = _animated_sprite.position
	_animated_sprite.frame = 0


## ── Prueba con click (animación completa) ──

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if global_position.distance_to(event.global_position) < 60:
			lanzar(randi() % 6 + 1)


## ── API pública ──

## Inicia la animación de agite continuo (se llama al empezar a llenar la barra).
## Cambia las caras aleatoriamente a gran velocidad + temblor de posición.
func empezar_agite() -> void:
	if _agitando:
		return
	_agitando = true
	_crear_jitter()

	# Timer que cambia la cara del dado aleatoriamente cada 45 ms
	_agite_timer = Timer.new()
	_agite_timer.wait_time = 0.045
	_agite_timer.one_shot = false
	_agite_timer.timeout.connect(_cambiar_cara_aleatoria)
	add_child(_agite_timer)
	_agite_timer.start()


## Detiene el agite y muestra el resultado final con rebote.
## Emite `lanzamiento_completado` al terminar.
func detener_agite(resultado: int) -> void:
	if not _agitando:
		return
	_agitando = false
	_detener_jitter()
	_detener_timer()

	resultado = clampi(resultado, 1, 6)
	_animated_sprite.stop()
	_animated_sprite.frame = resultado - 1
	_animated_sprite.position = _pos_original

	# Rebote al caer
	var bounce_tween = create_tween()
	bounce_tween.set_trans(Tween.TRANS_BOUNCE)
	bounce_tween.set_ease(Tween.EASE_OUT)
	bounce_tween.tween_property(_animated_sprite, "position:y", _pos_original.y - 6.0, 0.1)
	bounce_tween.tween_property(_animated_sprite, "position:y", _pos_original.y, 0.2)
	await bounce_tween.finished

	lanzamiento_completado.emit(resultado)


## Detiene el agite sin mostrar resultado (cuando se sueltan las teclas antes de llenar la barra).
func parar_agite() -> void:
	if not _agitando:
		return
	_agitando = false
	_detener_jitter()
	_detener_timer()
	_animated_sprite.frame = 0
	_animated_sprite.position = _pos_original


## Animación completa en un solo llamado (para testeo con click).
signal lanzamiento_completado(resultado: int)

func lanzar(resultado: int) -> void:
	if _lanzando or _agitando:
		return
	_lanzando = true

	resultado = clampi(resultado, 1, 6)

	_animated_sprite.play("shake")

	# Vibración secuencial
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	var shake_intensity = 4.0
	for i in 3:
		var offset_x = randf_range(-shake_intensity, shake_intensity)
		var offset_y = randf_range(-shake_intensity, shake_intensity)
		tween.tween_property(_animated_sprite, "position", _pos_original + Vector2(offset_x, offset_y), 0.08)
		tween.tween_property(_animated_sprite, "position", _pos_original, 0.08)

	await tween.finished

	_animated_sprite.stop()
	_animated_sprite.frame = resultado - 1
	_animated_sprite.position = _pos_original

	var bounce_tween = create_tween()
	bounce_tween.set_trans(Tween.TRANS_BOUNCE)
	bounce_tween.set_ease(Tween.EASE_OUT)
	bounce_tween.tween_property(_animated_sprite, "position:y", _pos_original.y - 6.0, 0.1)
	bounce_tween.tween_property(_animated_sprite, "position:y", _pos_original.y, 0.2)
	await bounce_tween.finished

	_lanzando = false
	lanzamiento_completado.emit(resultado)


## ── Internos ──

## Cambia a una cara aleatoria del dado (para el efecto de agite).
func _cambiar_cara_aleatoria() -> void:
	_animated_sprite.frame = randi() % 6


## Crea un Tween en bucle que hace vibrar el dado en posición Y.
func _crear_jitter() -> void:
	_detener_jitter()
	_jitter_tween = create_tween().set_loops()
	_jitter_tween.set_trans(Tween.TRANS_SINE)
	_jitter_tween.set_ease(Tween.EASE_IN_OUT)
	_jitter_tween.tween_property(_animated_sprite, "position:y", _pos_original.y - 4.0, 0.045)
	_jitter_tween.tween_property(_animated_sprite, "position:y", _pos_original.y, 0.045)
	_jitter_tween.tween_property(_animated_sprite, "position:y", _pos_original.y + 3.0, 0.045)
	_jitter_tween.tween_property(_animated_sprite, "position:y", _pos_original.y, 0.045)


## Mata el Tween de jitter si existe.
func _detener_jitter() -> void:
	if _jitter_tween and _jitter_tween.is_valid():
		_jitter_tween.kill()
	_jitter_tween = null


## Detiene y libera el Timer de cambio de caras.
func _detener_timer() -> void:
	if _agite_timer:
		_agite_timer.stop()
		_agite_timer.queue_free()
		_agite_timer = null
