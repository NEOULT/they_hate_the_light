## Evento: VISITA A URANO, HACE FRRRRRRIIIOOO
##
## El suelo se congela y los jugadores resbalan con física de hielo.
## Además caen carámbanos del techo que deben esquivar.
## El evento dura un tiempo fijo (representando 3 turnos del juego de mesa).
## Supervivencia = evento completado.
extends "res://events/event_base.gd"


## Duración del evento en segundos.
@export var duracion: float = 18.0

## Intervalo entre oleadas de carámbanos.
@export var intervalo_carambanos: float = 2.5

## Velocidad base de los carámbanos.
@export var velocidad_icicle: float = 180.0

## Fricción del hielo (0.0 = desliza total, 1.0 = sin deslizar).
@export var friccion_hielo: float = 0.08

## Aceleración en el hielo.
@export var aceleracion_hielo: float = 0.15


const ICICLE_SCENE = preload("res://events/ice_event/icicle.tscn")


var _active: bool = false
var _tiempo_restante: float = 0.0
var _timer_icicles: float = 0.0
var _jugadores_vivos: Array = []
var _jugador1_data: Dictionary = {}
var _jugador2_data: Dictionary = {}
var _hud_label: Label
var _timer_label: Label
var _ui_layer: CanvasLayer
var _ice_surface: ColorRect


func start_event(p1: Node, p2: Node) -> void:
	super(p1, p2)
	event_name = "¡HACE FRÍO!"

	_jugadores_vivos = [p1, p2]
	_tiempo_restante = duracion
	_active = true

	# ── Pintar el suelo de hielo ──
	_ice_surface = ColorRect.new()
	_ice_surface.color = Color(0.6, 0.8, 1.0, 0.25)  # azul semitransparente
	_ice_surface.offset_left = -500
	_ice_surface.offset_top = -200
	_ice_surface.offset_right = 500
	_ice_surface.offset_bottom = 200
	_ice_surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_ice_surface)

	# ── UI ──
	_ui_layer = CanvasLayer.new()
	_ui_layer.layer = 1
	add_child(_ui_layer)

	_hud_label = Label.new()
	_hud_label.text = "¡SUELO CONGELADO! Cuidado al caminar..."
	_hud_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hud_label.add_theme_font_size_override("font_size", 24)
	_hud_label.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	_hud_label.position = Vector2(400, 20)
	_hud_label.size = Vector2(700, 50)
	_ui_layer.add_child(_hud_label)

	_timer_label = Label.new()
	_timer_label.text = _formatear_tiempo(_tiempo_restante)
	_timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_timer_label.add_theme_font_size_override("font_size", 20)
	_timer_label.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	_timer_label.position = Vector2(500, 70)
	_timer_label.size = Vector2(200, 40)
	_ui_layer.add_child(_timer_label)

	# Texto de inicio
	var start_label = Label.new()
	start_label.text = "¡HACE FRÍO!\nEl suelo está congelado..."
	start_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	start_label.add_theme_font_size_override("font_size", 40)
	start_label.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	start_label.position = Vector2(226, 240)
	start_label.size = Vector2(700, 100)
	_ui_layer.add_child(start_label)

	await get_tree().create_timer(1.5).timeout
	start_label.queue_free()

	# ── Congelar el movimiento de los jugadores ──
	_congelar_jugador(p1, _jugador1_data)
	_congelar_jugador(p2, _jugador2_data)


func _process(delta: float) -> void:
	if not _active:
		return

	# Timer
	_tiempo_restante -= delta
	_timer_label.text = _formatear_tiempo(_tiempo_restante)

	if _tiempo_restante <= 0:
		_active = false
		_descongelar_jugadores()
		_finalizar_evento()
		return

	# Spawn de carámbanos
	_timer_icicles -= delta
	if _timer_icicles <= 0:
		_timer_icicles = intervalo_carambanos
		_spawnear_icicles()

	# Física de hielo en cada frame
	for p in _jugadores_vivos:
		_aplicar_fisica_hielo(p)


## Aplica física de hielo al jugador: deslizamiento con inercia.
func _aplicar_fisica_hielo(jugador: Node) -> void:
	if not jugador or not is_instance_valid(jugador):
		return

	var input_handler = jugador.get_node("InputHandler")
	if not input_handler:
		return

	var direction = input_handler.get_direction()
	var velocidad = jugador.move_speed

	# En hielo: la velocidad no se asigna directamente, se interpola
	var target_velocity = direction * velocidad
	jugador.velocity = jugador.velocity.lerp(target_velocity, aceleracion_hielo)

	# Aplicar fricción reducida
	if direction == Vector2.ZERO:
		jugador.velocity = jugador.velocity.lerp(Vector2.ZERO, friccion_hielo)

	jugador.move_and_slide()


## Reemplaza el procesamiento normal del jugador por la física de hielo.
func _congelar_jugador(jugador: Node, data: Dictionary) -> void:
	data["state_machine"] = jugador.get_node("StateMachine")
	data["input_handler"] = jugador.get_node("InputHandler")

	# Deshabilitar la máquina de estados normal del jugador
	if data["state_machine"]:
		data["state_machine"].set_process(false)
		data["state_machine"].set_physics_process(false)

	# El InputHandler lo dejamos activo para leer las teclas


## Restaura el procesamiento normal del jugador.
func _descongelar_jugadores() -> void:
	var datasets = [_jugador1_data, _jugador2_data]
	for data in datasets:
		if data.get("state_machine"):
			data["state_machine"].set_process(true)
			data["state_machine"].set_physics_process(true)
			# Resetear velocidad
			var jugador = player1 if data == _jugador1_data else player2
			if jugador:
				jugador.velocity = Vector2.ZERO


func _spawnear_icicles() -> void:
	var limites = _obtener_limites_viewport()
	var cantidad = randi() % 3 + 2  # 2-4 carámbanos

	for i in range(cantidad):
		var icicle = ICICLE_SCENE.instantiate()
		var x = randf_range(limites.left + 40, limites.right - 40)
		icicle.position = Vector2(x, limites.top - 20)
		icicle.velocidad = velocidad_icicle + randf_range(-30, 30)
		icicle.radio = randf_range(7, 14)
		icicle.golpeo_jugador.connect(_on_icicle_golpea)
		add_child(icicle)
		await get_tree().create_timer(0.2).timeout


func _on_icicle_golpea(jugador: Node) -> void:
	if not _active:
		return

	# Congelar al jugador por un momento (efecto visual)
	var tween = create_tween()
	tween.tween_property(jugador, "modulate", Color(0.5, 0.7, 1.0), 0.1)
	tween.tween_property(jugador, "modulate", Color.WHITE, 0.5)

	# Mostrar mensaje de aviso
	_mostrar_mensaje("¡Cuidado con los carámbanos!", Color(0.5, 0.8, 1.0))


func _mostrar_mensaje(texto: String, color: Color) -> void:
	if not _ui_layer:
		return
	var label = Label.new()
	label.text = texto
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", color)
	label.position = Vector2(226, 300)
	label.size = Vector2(700, 50)
	_ui_layer.add_child(label)

	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 1.0)
	tween.finished.connect(label.queue_free)


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


func _formatear_tiempo(t: float) -> String:
	var seg = int(ceil(t))
	return "Hielo: %ds" % seg


func _finalizar_evento() -> void:
	_active = false
	_descongelar_jugadores()

	var resultado = {
		"evento": "hace_frio",
		"completado": true,
		"duracion": duracion,
	}

	_mostrar_mensaje("¡HIELO SUPERADO!\n Sobreviviste al frío", Color(0.2, 1, 0.8))
	await get_tree().create_timer(2.5).timeout
	event_completed.emit(resultado)


func stop_event() -> void:
	_active = false
	_descongelar_jugadores()


func is_active() -> bool:
	return _active
