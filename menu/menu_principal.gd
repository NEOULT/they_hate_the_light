extends Node2D
## Script principal del menú - botones, fade-in y modo DELEITARSE

@onready var btn_jugar: Node2D = $CanvasLayer/ButtonJugar
@onready var btn_salir: Node2D = $CanvasLayer/ButtonSalir
@onready var btn_deleitarse: Node2D = $CanvasLayer/ButtonDeleitarse
@onready var typewriter: Node2D = $CanvasLayer/TypewriterText
@onready var transition_overlay: ColorRect = $CanvasLayer/TransitionOverlay

var _botones_ocultos: bool = false
var _modo_deleitarse: bool = false


func _ready() -> void:
	if btn_jugar:
		btn_jugar.pressed.connect(_on_jugar_pressed)
	if btn_salir:
		btn_salir.pressed.connect(_on_salir_pressed)
	if btn_deleitarse:
		btn_deleitarse.pressed.connect(_on_deleitarse_pressed)
	
	# Animación de entrada: fade-in desde negro
	if transition_overlay:
		transition_overlay.color = Color(0, 0, 0, 1)
		var tween: Tween = create_tween()
		tween.tween_property(transition_overlay, "color", Color(0, 0, 0, 0), 10)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_callback(func(): transition_overlay.visible = false)


func _input(event: InputEvent) -> void:
	# En modo deleitarse, detectar Espacio para volver
	if _modo_deleitarse and event.is_action_pressed("ui_accept"):
		_volver_al_menu()


func _on_deleitarse_pressed() -> void:
	if _botones_ocultos:
		return
	_botones_ocultos = true
	
	# Deshabilitar input de todos los botones
	for btn in [btn_jugar, btn_salir, btn_deleitarse]:
		if btn and btn.has_method("disable"):
			btn.disable()
	
	# Bajar opacidad gradualmente a todos los botones
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	for btn in [btn_jugar, btn_salir, btn_deleitarse]:
		if btn:
			tween.tween_property(btn, "modulate:a", 0.0, 1.0)
	
	# Esperar 10 segundos y luego mostrar texto con efecto de escritura
	await get_tree().create_timer(10.0).timeout
	
	_modo_deleitarse = true
	if typewriter:
		typewriter.iniciar()


func _volver_al_menu() -> void:
	_modo_deleitarse = false
	_botones_ocultos = false
	
	# Ocultar y detener el typewriter
	if typewriter and typewriter.has_method("detener"):
		typewriter.detener()
	
	# Re-activar botones y hacerlos visibles de vuelta
	for btn in [btn_jugar, btn_salir, btn_deleitarse]:
		if not btn:
			continue
		if btn.has_method("enable"):
			btn.enable()
		# Fade-in de opacidad
		var tween: Tween = create_tween()
		tween.tween_property(btn, "modulate:a", 1.0, 0.8)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)


func _on_jugar_pressed() -> void:
	# Iniciar el juego a través del GameManager
	if has_node("/root/GameManager"):
		get_node("/root/GameManager").start_game()


func _on_salir_pressed() -> void:
	get_tree().quit()
