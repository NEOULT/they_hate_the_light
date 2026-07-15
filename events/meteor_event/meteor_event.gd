## Evento: METEORITOS
##
## Los jugadores deben sobrevivir a oleadas de meteoritos.
## Cada oleada spawneará más meteoritos. Si un jugador es golpeado, queda eliminado.
## El evento termina cuando se completan todas las oleadas o ambos jugadores caen.
extends "res://events/event_base.gd"


## Número de oleadas de meteoritos
@export var oleadas_totales: int = 3

## Meteoritos por oleada (base)
@export var meteoritos_por_oleada: int = 4

## Tiempo entre oleadas (segundos)
@export var tiempo_entre_oleadas: float = 2.0

## Intervalo entre cada meteorito
@export var intervalo_spawn: float = 0.35

## Velocidad base de los meteoritos
@export var velocidad_meteorito: float = 250.0

const METEOR_SCENE = preload("res://events/meteor_event/meteor.tscn")


var _oleada_actual: int = 0
var _spawn_pending: int = 0
var _active: bool = false
var _jugadores_vivos: Array = []
var _hud_label: Label
var _ui_layer: CanvasLayer


func start_event(p1: Node, p2: Node) -> void:
	super(p1, p2)
	event_name = "¡¡METEORITOS!!"

	# Inicializar tracking de jugadores
	_jugadores_vivos = [p1, p2]

	# ── UI en CanvasLayer (coordenadas de pantalla) ──
	_ui_layer = CanvasLayer.new()
	_ui_layer.layer = 1
	add_child(_ui_layer)

	# HUD: título del evento (centrado arriba)
	_hud_label = Label.new()
	_hud_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hud_label.add_theme_font_size_override("font_size", 28)
	_hud_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
	_hud_label.position = Vector2(400, 20)
	_hud_label.size = Vector2(700, 60)
	_ui_layer.add_child(_hud_label)

	# Texto de inicio (centrado en pantalla)
	var start_label = Label.new()
	start_label.text = "¡Prepárate!\nEsquiva los meteoritos..."
	start_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	start_label.add_theme_font_size_override("font_size", 44)
	start_label.add_theme_color_override("font_color", Color(1, 0.3, 0.1))
	start_label.position = Vector2(226, 250)
	start_label.size = Vector2(700, 100)
	_ui_layer.add_child(start_label)

	_active = true

	await get_tree().create_timer(1.5).timeout
	start_label.queue_free()
	_iniciar_siguiente_oleada()


func stop_event() -> void:
	_active = false
	_oleada_actual = oleadas_totales


func is_active() -> bool:
	return _active


func _iniciar_siguiente_oleada() -> void:
	if not _active or _oleada_actual >= oleadas_totales:
		await get_tree().create_timer(1.0).timeout
		_finalizar_evento()
		return

	_oleada_actual += 1
	_spawn_pending = meteoritos_por_oleada + _oleada_actual
	_actualizar_hud()
	_spawnear_proximo_meteorito()


func _spawnear_proximo_meteorito() -> void:
	if not _active:
		return

	if _spawn_pending <= 0:
		await get_tree().create_timer(tiempo_entre_oleadas).timeout
		_iniciar_siguiente_oleada()
		return

	_spawn_pending -= 1
	_instanciar_meteorito()

	await get_tree().create_timer(intervalo_spawn).timeout
	_spawnear_proximo_meteorito()


## Calcula los límites del viewport en coordenadas de mundo.
func _obtener_limites_viewport() -> Dictionary:
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return { "left": -600, "right": 600, "top": -340, "bottom": 340 }

	var viewport_size = get_viewport().get_visible_rect().size
	var cam_pos = camera.global_position
	return {
		"left":   cam_pos.x - viewport_size.x / 2.0,
		"right":  cam_pos.x + viewport_size.x / 2.0,
		"top":    cam_pos.y - viewport_size.y / 2.0,
		"bottom": cam_pos.y + viewport_size.y / 2.0,
	}


func _instanciar_meteorito() -> void:
	var meteor = METEOR_SCENE.instantiate()

	# Posición aleatoria arriba del viewport, en coordenadas de mundo
	var limites = _obtener_limites_viewport()
	var x = randf_range(limites.left + 60, limites.right - 60)
	meteor.position = Vector2(x, limites.top - 30)

	# Dificultad progresiva
	meteor.velocidad = velocidad_meteorito + _oleada_actual * 40.0
	meteor.radio = randf_range(12, 20)

	# Deriva lateral
	var drift_x = randf_range(-0.4, 0.4)
	meteor.direccion = Vector2(drift_x, 1.0).normalized()

	# Conectar señal de impacto
	meteor.golpeo_jugador.connect(_on_meteorito_golpea)

	add_child(meteor)


func _on_meteorito_golpea(jugador: Node) -> void:
	if not _active:
		return
	if not jugador in _jugadores_vivos:
		return

	_jugadores_vivos.erase(jugador)

	var idx = 1 if jugador == player1 else 2
	_mostrar_mensaje("¡JUGADOR %d ELIMINADO!" % idx, Color(1, 0.1, 0.1))

	# Efecto visual: jugador eliminado se vuelve transparente
	var tween = create_tween()
	tween.tween_property(jugador, "modulate:a", 0.3, 0.5)

	# Desactivar input del jugador eliminado
	var input_handler = jugador.get_node("InputHandler")
	if input_handler:
		input_handler.set_process(false)
		input_handler.set_physics_process(false)

	if _jugadores_vivos.is_empty():
		_active = false
		await get_tree().create_timer(1.0).timeout
		_finalizar_evento()


func _mostrar_mensaje(texto: String, color: Color) -> void:
	if not _ui_layer:
		return

	var label = Label.new()
	label.text = texto
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 36)
	label.add_theme_color_override("font_color", color)
	label.position = Vector2(226, 280)
	label.size = Vector2(700, 60)
	_ui_layer.add_child(label)

	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 1.5)
	tween.finished.connect(label.queue_free)


func _finalizar_evento() -> void:
	_active = false

	var completado = not _jugadores_vivos.is_empty()
	var resultado = {
		"evento": "meteoritos",
		"completado": completado,
		"jugadores_vivos": _jugadores_vivos.size(),
		"oleadas_superadas": _oleada_actual,
		"oleadas_totales": oleadas_totales,
	}

	if completado:
		var label = Label.new()
		label.text = "¡MISIÓN CUMPLIDA!\nSobreviviste %d/%d oleadas" % [_oleada_actual, oleadas_totales]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 40)
		label.add_theme_color_override("font_color", Color(0.2, 1, 0.2))
		label.position = Vector2(226, 240)
		label.size = Vector2(700, 100)

		if _ui_layer:
			_ui_layer.add_child(label)

		await get_tree().create_timer(2.5).timeout
		label.queue_free()
	else:
		_mostrar_mensaje("¡DERROTA!\nAmbos jugadores fueron eliminados", Color(1, 0.2, 0.2))
		await get_tree().create_timer(2.5).timeout

	event_completed.emit(resultado)


func _actualizar_hud() -> void:
	if _hud_label:
		_hud_label.text = "OLEADA %d/%d — ¡ESQUIVA!" % [_oleada_actual, oleadas_totales]
