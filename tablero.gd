extends Node2D


@onready var _curva: Curve2D = $Path2D.curve
@onready var distancias_casillas := _calcular_distancias()
@onready var _barra_agite: Control = $BarraAgite
@onready var _dado: Node2D = $Dado
@onready var _dado2: Node2D = $Dado2
@onready var _key: Node2D = $Node2D
@onready var _label_turno: Label = $LabelTurno

## Posiciones originales para animación de entrada/salida
var _barra_pos_original: Vector2
var _dado1_pos_original: Vector2
var _dado2_pos_original: Vector2

## Player data: each entry has path_follow, casilla_actual, _avanzando
var _players := []

## Índice del jugador que tiene el turno (0 = Player 1, 1 = Player 2)
var _turno_actual: int = 0

## Contador de teclas presionadas para el medidor de agite
var _teclas_pulsadas: int = 0

## Si es true, no se procesa input y la barra se queda fija
var _roll_en_curso := false

## Control de tirada con 2 dados
var _resultados_pendientes := 0
var _suma_resultados := 0


func _ready() -> void:
	randomize()

	_players = [
		{
			path_follow = $Path2D/PathFollow2D,
			casilla_actual = 0,
			_avanzando = false,
		},
		{
			path_follow = $Path2D/PathFollow2D2,
			casilla_actual = 0,
			_avanzando = false,
		},
	]

	# Guardar referencia a la ficha de cada jugador
	for p in _players:
		p.ficha = p.path_follow.get_child(0)

	for p in _players:
		p.path_follow.loop = true
		p.path_follow.progress = 0.0

	# ── Mostrar turno inicial ──
	_actualizar_label_turno()

	# ── Guardar posiciones originales para animaciones ──
	_barra_pos_original = Vector2(_barra_agite.offset_left, _barra_agite.offset_top)
	_dado1_pos_original = _dado.position
	_dado2_pos_original = _dado2.position

	# Empezar con UI fuera de pantalla y animar entrada
	_mover_ui_fuera()
	await get_tree().process_frame
	_animar_ui_entrada()

	# ── Conectar señales ──
	_barra_agite.barra_llena.connect(_iniciar_tirada)
	_dado.lanzamiento_completado.connect(_on_dado_completado)
	_dado2.lanzamiento_completado.connect(_on_dado_completado)
	_key.animacion_completada.connect(_on_key_completada)


func _input(event: InputEvent) -> void:
	# ── Durante la tirada del dado no se procesa nada ──
	if _roll_en_curso:
		return

	# ── Medidor de agite (Player 1) ──
	_manejar_barra_p1(event)


func _manejar_barra_p1(event: InputEvent) -> void:
	## Rastrea cuántas teclas está presionando el jugador activo.
	## La barra se llena mientras haya al menos una tecla presionada.
	## El dado se agita mientras se llena la barra.
	for action in ["ui_accept", "ui_right", "ui_left"]:
		if event.is_action_pressed(action) and not event.is_echo():
			_teclas_pulsadas += 1
			if _teclas_pulsadas == 1:
				_barra_agite.cargar()
				_dado.empezar_agite()
				_dado2.empezar_agite()
			return
		elif event.is_action_released(action):
			_teclas_pulsadas = maxi(_teclas_pulsadas - 1, 0)
			if _teclas_pulsadas == 0:
				_barra_agite.soltar()
				_dado.parar_agite()
				_dado2.parar_agite()
			return


## Se llama cuando la barra de agite llega al 100%.
func _iniciar_tirada() -> void:
	_roll_en_curso = true
	_resultados_pendientes = 2
	var r1 = randi() % 6 + 1
	var r2 = randi() % 6 + 1
	_suma_resultados = r1 + r2
	_dado.detener_agite(r1)
	_dado2.detener_agite(r2)


## Se llama cada vez que un dado termina su animación.
## Cuando ambos terminan, activa la llave tantas veces como la suma de los dados.
func _on_dado_completado(_resultado: int) -> void:
	_resultados_pendientes -= 1
	if _resultados_pendientes > 0:
		return

	# Ambos dados terminaron → la llave gira la suma de los resultados
	# Usamos call_deferred para que el audio arranque desde un contexto limpio
	# (el dado emite la señal desde adentro de una corrutina con await)
	_key.call_deferred("activar", _suma_resultados)
	# El reset y movimiento se hacen en _on_key_completada


## Se llama cuando la llave termina de girar.
## Mueve la ficha del jugador actual y cambia el turno.
func _on_key_completada(_suma: int) -> void:
	# Mover ficha del jugador en turno
	await avanzar(_turno_actual, _suma)
	_barra_agite.reset()
	_teclas_pulsadas = 0
	_roll_en_curso = false

	# Animar salida de la UI
	await _animar_ui_salida()

	# Cambiar al siguiente jugador
	_turno_actual = 1 if _turno_actual == 0 else 0
	_actualizar_label_turno()

	# Animar entrada de la UI para el nuevo turno
	_animar_ui_entrada()


func mover_1_casilla(player_idx: int, direccion: int) -> void:
	var p = _players[player_idx]
	if p._avanzando:
		return
	p._avanzando = true

	var total_casillas = distancias_casillas.size()
	p.casilla_actual = (p.casilla_actual + direccion) % total_casillas
	if p.casilla_actual < 0:
		p.casilla_actual += total_casillas

	var destino = distancias_casillas[p.casilla_actual]

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(p.path_follow, "progress", destino, 0.15)
	tween.finished.connect(func():
		p._avanzando = false
	)


func avanzar(player_idx: int, pasos: int = -1) -> void:
	var p = _players[player_idx]
	if p._avanzando:
		return
	p._avanzando = true

	var distancia_total = distancias_casillas[distancias_casillas.size() - 1]
	if pasos <= 0:
		pasos = randi() % 6 + 1
	var progreso_actual = p.path_follow.progress
	p.casilla_actual = (p.casilla_actual + pasos) % distancias_casillas.size()
	var destino = distancias_casillas[p.casilla_actual]

	var distancia_viaje = destino - progreso_actual
	if distancia_viaje < 0:
		distancia_viaje = (distancia_total - progreso_actual) + destino
		destino += distancia_total

	# Velocidad base: 100 px/s. Reducida un tercio → dura 1.5x más
	var duracion = maxf(distancia_viaje / 100.0 * 1.5, 0.3)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(p.path_follow, "progress", destino, duracion)
	# Reproducir secuencia de sonidos de desplazamiento
	if p.has("ficha") and p.ficha:
		p.ficha.play_desplazamiento(duracion)
	await tween.finished
	p.path_follow.progress = fmod(p.path_follow.progress, distancia_total)
	p._avanzando = false


## Actualiza el texto del Label de turno.
func _actualizar_label_turno() -> void:
	_label_turno.text = "TURNO: JUGADOR " + str(_turno_actual + 1)


## ── Animaciones de transición de turno ──

const UI_OFFSET := 500.0  # px fuera de pantalla a la derecha


## Mueve la barra y los dados instantáneamente fuera de pantalla.
func _mover_ui_fuera() -> void:
	_barra_agite.offset_left = _barra_pos_original.x + UI_OFFSET
	_barra_agite.offset_top = _barra_pos_original.y
	_dado.position = _dado1_pos_original + Vector2(UI_OFFSET, 0)
	_dado2.position = _dado2_pos_original + Vector2(UI_OFFSET, 0)


## Anima la entrada de la barra y los dados desde la derecha.
func _animar_ui_entrada() -> void:
	# Posicionar fuera antes de animar
	_mover_ui_fuera()

	var tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(_barra_agite, "offset_left", _barra_pos_original.x, 0.5)
	tween.tween_property(_barra_agite, "offset_top", _barra_pos_original.y, 0.5)
	tween.tween_property(_dado, "position", _dado1_pos_original, 0.5)
	tween.tween_property(_dado2, "position", _dado2_pos_original, 0.5)


## Anima la salida de la barra y los dados hacia la derecha.
## Retorna un await para que el llamante espere a que termine.
func _animar_ui_salida() -> void:
	var tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(_barra_agite, "offset_left", _barra_pos_original.x + UI_OFFSET, 0.4)
	tween.tween_property(_barra_agite, "offset_top", _barra_pos_original.y, 0.4)
	tween.tween_property(_dado, "position", _dado1_pos_original + Vector2(UI_OFFSET, 0), 0.4)
	tween.tween_property(_dado2, "position", _dado2_pos_original + Vector2(UI_OFFSET, 0), 0.4)
	await tween.finished


func _calcular_distancias() -> Array:
	var distancias = []
	for i in range(_curva.point_count):
		var pos = _curva.get_point_position(i)
		var offset = _curva.get_closest_offset(pos)
		distancias.append(offset)
	return distancias
