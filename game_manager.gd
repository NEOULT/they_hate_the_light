extends Node
## Controlador global del juego. Orquesta los 5 niveles, transiciones y fin del juego.
##
## Flujo:
##   start_game() → Nivel 1 → Nivel 2 → Nivel 3 → Nivel 4 → Nivel 5 → VICTORIA
##   Si ambos jugadores mueren en cualquier nivel → GAME OVER → menú


## Señal: se emite cuando el jugador gana todos los niveles
signal game_won()
## Señal: se emite cuando ambos jugadores pierden
signal game_over()
## Señal: se emite al cambiar de nivel (útil para UI)
signal level_changed(level_num: int)


const TOTAL_LEVELS := 5

## Rutas de las escenas de cada nivel (en orden)
const LEVELS := [
	"res://events/meteor_event/meteor_event.tscn",  # Nivel 1: Lluvia de Meteoros
	"res://events/ice_event/ice_event.tscn",         # Nivel 2: Paseo por Urano
	"",  # Nivel 3: Por definir
	"",  # Nivel 4: Por definir
	"",  # Nivel 5: Agujero Negro
]

## Nivel actual (0 = primero)
var current_level: int = 0

## Overlay de transición (fade a negro / desde negro)
var _transition_overlay: ColorRect
var _transition_layer: CanvasLayer


func _ready() -> void:
	# Crear overlay de transición persistente entre escenas
	_transition_layer = CanvasLayer.new()
	_transition_layer.layer = 100
	add_child(_transition_layer)
	
	_transition_overlay = ColorRect.new()
	_transition_overlay.color = Color(0, 0, 0, 0)
	_transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition_overlay.anchors_preset = Control.PRESET_FULL_RECT
	_transition_layer.add_child(_transition_overlay)


## Inicia la partida desde el nivel 1
func start_game() -> void:
	current_level = 0
	_transition_to_level(0)


## Devuelve la ruta de la escena del nivel actual
func get_current_level_path() -> String:
	if current_level < LEVELS.size():
		return LEVELS[current_level]
	return ""


## Transiciona a un nivel con fade a negro
func _transition_to_level(level_num: int) -> void:
	if level_num >= TOTAL_LEVELS:
		_victoria()
		return
	
	# Verificar que el nivel tenga ruta definida
	if LEVELS[level_num].is_empty():
		push_error("GameManager: Nivel %d no tiene ruta definida" % level_num)
		return
	
	current_level = level_num
	level_changed.emit(level_num)
	
	# Fade a negro
	_transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween: Tween = create_tween()
	tween.tween_property(_transition_overlay, "color", Color(0, 0, 0, 1), 0.5)
	tween.set_ease(Tween.EASE_IN)
	await tween.finished
	
	# Cargar escena del nivel (event_stage con el evento correspondiente)
	get_tree().change_scene_to_file("res://event_stage/event_stage.tscn")
	
	# Esperar un frame para que la escena se cargue
	await get_tree().process_frame
	
	# Fade a transparente
	var tween2: Tween = create_tween()
	tween2.tween_property(_transition_overlay, "color", Color(0, 0, 0, 0), 0.5)
	tween2.set_ease(Tween.EASE_OUT)
	await tween2.finished
	_transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE


## Se llama desde event_stage cuando un nivel termina
func on_level_completed(resultado: Dictionary) -> void:
	var completado: bool = resultado.get("completado", false)
	
	if completado:
		# Pasar al siguiente nivel
		_transition_to_level(current_level + 1)
	else:
		_game_over()


func _game_over() -> void:
	game_over.emit()
	
	# Fade a negro
	_transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween: Tween = create_tween()
	tween.tween_property(_transition_overlay, "color", Color(0, 0, 0, 1), 1.0)
	tween.set_ease(Tween.EASE_IN)
	await tween.finished
	
	# Volver al menú
	get_tree().change_scene_to_file("res://menu/menu_principal.tscn")
	await get_tree().process_frame
	
	var tween2: Tween = create_tween()
	tween2.tween_property(_transition_overlay, "color", Color(0, 0, 0, 0), 0.8)
	tween2.set_ease(Tween.EASE_OUT)
	await tween2.finished
	_transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _victoria() -> void:
	game_won.emit()
	
	# Fade a negro con mensaje
	_transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween: Tween = create_tween()
	tween.tween_property(_transition_overlay, "color", Color(0, 0, 0, 1), 1.0)
	await tween.finished
	
	# Volver al menú
	get_tree().change_scene_to_file("res://menu/menu_principal.tscn")
	await get_tree().process_frame
	
	var tween2: Tween = create_tween()
	tween2.tween_property(_transition_overlay, "color", Color(0, 0, 0, 0), 0.8)
	await tween2.finished
	_transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
