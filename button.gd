extends Node2D

signal pressed

@export var button_text: String = "JUGAR":
	set(value):
		button_text = value
		queue_redraw()

# Fuente y configuración del texto
const FONT := preload("res://fonts/BoldPixels.ttf")
const FONT_SIZE := 132
const OUTLINE_SIZE := 6
const OUTLINE_COLOR := Color(0, 0, 0, 0.8)
const FONT_COLOR := Color(1, 1, 1, 1)

# Rectángulo donde se dibuja el texto (coincide con el antiguo Label)
const TEXT_RECT := Rect2(-393, -138, 800, 150)

# Propiedades originales para la animación
var original_position: Vector2
var original_scale: Vector2
var original_color: Color

# Propiedades del hover
@export var hover_offset_y: float = -8.0
@export var hover_scale_factor: float = 1.08
@export var hover_color: Color = Color(0.18, 0.14, 0.10, 1)

var tween_hover: Tween


func _ready():
	await get_tree().process_frame
	
	# Guardar propiedades originales
	original_position = position
	original_scale = scale
	if has_node("Sprite/ColorRect"):
		original_color = $Sprite/ColorRect.color
	
	# Conectar señales del Area2D
	var area = $Area2D
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	area.input_event.connect(_on_input_event)
	
	queue_redraw()


func _draw():
	if not button_text:
		return
	
	# Calcular línea base para centrado vertical
	var ascent = FONT.get_ascent(FONT_SIZE)
	var descent = FONT.get_descent(FONT_SIZE)
	var baseline_y = TEXT_RECT.get_center().y + (ascent - descent) / 2.0
	var pos = Vector2(TEXT_RECT.position.x, baseline_y)
	
	# Dibujar outline primero (queda detrás)
	draw_string(FONT, pos, button_text, HORIZONTAL_ALIGNMENT_CENTER, TEXT_RECT.size.x, FONT_SIZE, OUTLINE_COLOR, OUTLINE_SIZE)
	# Dibujar texto encima
	draw_string(FONT, pos, button_text, HORIZONTAL_ALIGNMENT_CENTER, TEXT_RECT.size.x, FONT_SIZE, FONT_COLOR, 0)


func _on_mouse_entered():
	_animate_hover(true)


func _on_mouse_exited():
	_animate_hover(false)


func _on_input_event(_viewport, event: InputEvent, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed.emit()


## Deshabilita el botón: resetea hover y desactiva input
func disable() -> void:
	if tween_hover and tween_hover.is_valid():
		tween_hover.kill()
	position = original_position
	scale = original_scale
	if has_node("Sprite/ColorRect"):
		$Sprite/ColorRect.color = original_color
	var area = $Area2D
	if area:
		area.input_pickable = false


## Re-activa el botón después de disable()
func enable() -> void:
	var area = $Area2D
	if area:
		area.input_pickable = true


func _animate_hover(entering: bool):
	if tween_hover and tween_hover.is_valid():
		tween_hover.kill()
	
	tween_hover = create_tween()
	tween_hover.set_parallel(true)
	tween_hover.set_ease(Tween.EASE_OUT)
	tween_hover.set_trans(Tween.TRANS_CUBIC)
	
	if entering:
		tween_hover.tween_property(self, "position", original_position + Vector2(0, hover_offset_y), 0.2)
		tween_hover.tween_property(self, "scale", original_scale * hover_scale_factor, 0.2)
		if has_node("Sprite/ColorRect"):
			tween_hover.tween_property($Sprite/ColorRect, "color", hover_color, 0.2)
	else:
		tween_hover.tween_property(self, "position", original_position, 0.2)
		tween_hover.tween_property(self, "scale", original_scale, 0.2)
		if has_node("Sprite/ColorRect"):
			tween_hover.tween_property($Sprite/ColorRect, "color", original_color, 0.2)
