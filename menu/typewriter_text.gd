extends Node2D
## Muestra texto con efecto de escritura (letra por letra) en la esquina inferior izquierda.
## Se activa llamando a iniciar(). Emite texto_completo cuando termina.

signal texto_completo

const FONT := preload("res://fonts/BoldPixels.ttf")

## Texto completo a escribir
@export var texto: String = ""
## Segundos entre cada letra
@export var tiempo_entre_letras: float = 0.06
## Tamaño de fuente
@export var font_size: int = 32
## Tamaño del outline
@export var outline_size: int = 3
## Color del outline
@export var outline_color: Color = Color(0, 0, 0, 0.8)
## Color del texto
@export var font_color: Color = Color(1, 1, 1, 1)
## Margen desde el borde izquierdo
@export var margin_left: float = 40.0
## Margen desde el borde inferior
@export var margin_bottom: float = 60.0

var _char_index: int = 0
var _timer: float = 0.0
var _escribiendo: bool = false
var _texto_visible: String = ""
var _pos_dibujo: Vector2


func _ready() -> void:
	visible = false
	_calcular_posicion()


func _calcular_posicion() -> void:
	var viewport_size := get_viewport_rect().size
	_pos_dibujo = Vector2(margin_left, viewport_size.y - margin_bottom)


func _process(delta: float) -> void:
	if not _escribiendo or _char_index >= texto.length():
		return
	
	_timer += delta
	var avanzar: bool = false
	while _timer >= tiempo_entre_letras and _char_index < texto.length():
		_timer -= tiempo_entre_letras
		_char_index += 1
		avanzar = true
	
	if avanzar:
		_texto_visible = texto.substr(0, _char_index)
		queue_redraw()
	
	if _char_index >= texto.length():
		_escribiendo = false
		texto_completo.emit()


## Inicia el efecto de escritura
func iniciar() -> void:
	_char_index = 0
	_timer = 0.0
	_texto_visible = ""
	_escribiendo = true
	visible = true
	_calcular_posicion()
	queue_redraw()


## Detiene el efecto de escritura y oculta el texto
func detener() -> void:
	_escribiendo = false
	_char_index = 0
	_timer = 0.0
	_texto_visible = ""
	visible = false
	queue_redraw()


func _draw() -> void:
	if not _texto_visible:
		return
	
	var ascent = FONT.get_ascent(font_size)
	var descent = FONT.get_descent(font_size)
	var baseline_y = _pos_dibujo.y + (ascent - descent) / 2.0
	var draw_pos = Vector2(_pos_dibujo.x, baseline_y)
	
	# Dibujar outline
	draw_string(FONT, draw_pos, _texto_visible, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, outline_color, outline_size)
	# Dibujar texto encima
	draw_string(FONT, draw_pos, _texto_visible, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, font_color, 0)
