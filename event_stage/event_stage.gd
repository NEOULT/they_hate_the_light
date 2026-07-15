## Escenario donde ocurren todos los niveles del juego.
## Actúa como contenedor: aloja a los 2 jugadores y gestiona la carga/ejecución de niveles.
extends Node2D


## Señal: se emite cuando un nivel termina, con el resultado.
signal nivel_terminado(resultado: Dictionary)


@onready var player1: CharacterBody2D = $Player1
@onready var player2: CharacterBody2D = $Player2
@onready var camera: Camera2D = $Camera2D

## Referencia al evento/nivel activo (si hay).
var evento_activo: Node = null


func _ready() -> void:
	_crear_inputs_p2()
	_configurar_player2()
	
	# Reposicionar jugadores para el inicio de cada nivel
	player1.position = Vector2(-250, 0)
	player2.position = Vector2(250, 0)
	
	# Cargar el nivel indicado por el GameManager
	_cargar_nivel_desde_gm()


## Carga el nivel/evento que el GameManager indique
func _cargar_nivel_desde_gm() -> void:
	var gm: Node = get_node_or_null("/root/GameManager")
	if not gm:
		push_error("event_stage: GameManager no encontrado")
		return
	
	var ruta_evento: String = gm.get_current_level_path()
	if ruta_evento.is_empty():
		push_error("event_stage: No hay ruta de nivel en GameManager (nivel %d)" % gm.current_level)
		return
	
	_iniciar_evento(ruta_evento)


## Inicia un evento por su ruta de escena.
## El evento se instancia como hijo, recibe los jugadores y comienza.
func _iniciar_evento(ruta_evento: String) -> void:
	if evento_activo:
		evento_activo.stop_event()
		evento_activo.queue_free()
		evento_activo = null
	
	var escena: PackedScene = load(ruta_evento)
	if not escena:
		push_error("No se pudo cargar el evento: ", ruta_evento)
		return
	
	evento_activo = escena.instantiate()
	add_child(evento_activo)
	
	# Conectar señal de finalización
	evento_activo.event_completed.connect(_on_evento_completado)
	
	# Iniciar el evento con los jugadores
	evento_activo.start_event(player1, player2)


## Se llama cuando un nivel/evento termina.
func _on_evento_completado(resultado: Dictionary) -> void:
	print("Nivel completado: ", resultado)
	
	if evento_activo:
		evento_activo.queue_free()
		evento_activo = null
	
	# Notificar al GameManager
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm and gm.has_method("on_level_completed"):
		gm.on_level_completed(resultado)
	
	nivel_terminado.emit(resultado)


## ── Configuración de jugadores ──

func _crear_inputs_p2() -> void:
	if not InputMap.has_action("p2_left"):
		InputMap.add_action("p2_left")
		var e: InputEventKey = InputEventKey.new()
		e.keycode = KEY_A
		InputMap.action_add_event("p2_left", e)

	if not InputMap.has_action("p2_right"):
		InputMap.add_action("p2_right")
		var e: InputEventKey = InputEventKey.new()
		e.keycode = KEY_D
		InputMap.action_add_event("p2_right", e)

	if not InputMap.has_action("p2_up"):
		InputMap.add_action("p2_up")
		var e: InputEventKey = InputEventKey.new()
		e.keycode = KEY_W
		InputMap.action_add_event("p2_up", e)

	if not InputMap.has_action("p2_down"):
		InputMap.add_action("p2_down")
		var e: InputEventKey = InputEventKey.new()
		e.keycode = KEY_S
		InputMap.action_add_event("p2_down", e)


func _configurar_player2() -> void:
	# Configurar inputs WASD
	var ih: Node = player2.get_node("InputHandler")
	if ih:
		ih.input_left = "p2_left"
		ih.input_right = "p2_right"
		ih.input_up = "p2_up"
		ih.input_down = "p2_down"

	# Configurar sprite con animaciones idle + walk
	var sprite: AnimatedSprite2D = player2.get_node("AnimatedSprite2D")
	if not sprite:
		return

	var frames: SpriteFrames = SpriteFrames.new()

	var tex_idle: Texture2D = load("res://player/sprites/J2 (2).png")
	if tex_idle:
		frames.add_animation("idle")
		frames.add_frame("idle", tex_idle)
		frames.set_animation_speed("idle", 5.0)
		frames.set_animation_loop("idle", true)

	frames.add_animation("walk")
	frames.set_animation_speed("walk", 8.0)
	frames.set_animation_loop("walk", true)
	for i in range(1, 5):
		var tex_walk: Texture2D = load("res://player/sprites/walk/v2_%d.png" % i)
		if tex_walk:
			frames.add_frame("walk", tex_walk)

	sprite.sprite_frames = frames
	sprite.play("idle")
