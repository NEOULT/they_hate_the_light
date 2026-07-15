extends Control

## Barra de carga vertical tipo "medidor de agite".
##
## Se llena mientras se mantiene presionado un botón y se vacía al soltarlo.
## Totalmente desacoplada: se controla desde fuera con `cargar()` y `soltar()`.
##
## Ejemplo de uso desde otro script:
##   @onready var barra: Control = $BarraCarga
##   func _input(event):
##       if event.is_action_pressed("ui_right"):
##           barra.cargar()
##       elif event.is_action_released("ui_right"):
##           barra.soltar()


## Velocidad de llenado por segundo (fracción de 0 a 1).
@export var velocidad_carga: float = 0.5

## Velocidad de vaciado por segundo (fracción de 0 a 1).
@export var velocidad_descarga: float = 0.3

## Color cuando la barra está vacía (valor ~0).
@export var color_base: Color = Color(0.2, 0.8, 0.2)

## Color cuando la barra está llena (valor ~1).
@export var color_pico: Color = Color(0.9, 0.2, 0.2)

## Input action para testeo opcional (vacío = sin testeo por input).
@export var input_action_test: String = ""


signal valor_actualizado(valor: float)
## Se emite una sola vez cuando la barra llega al 100%.
signal barra_llena


@onready var _fill: ColorRect = $Fill
@onready var _background: ColorRect = $Background

var _valor: float = 0.0
var _cargando: bool = false
var _barra_llena_emitida := false


func _ready() -> void:
	_actualizar_visual()


func _process(delta: float) -> void:
	if _cargando:
		_valor = minf(_valor + velocidad_carga * delta, 1.0)
	else:
		_valor = maxf(_valor - velocidad_descarga * delta, 0.0)

	_actualizar_visual()
	valor_actualizado.emit(_valor)

	# Detectar cuando la barra se llena (disparo único)
	if _valor >= 1.0 and not _barra_llena_emitida:
		_barra_llena_emitida = true
		barra_llena.emit()
	elif _valor < 1.0:
		_barra_llena_emitida = false

	if _valor <= 0.0 and not _cargando:
		set_process(false)


func _input(event: InputEvent) -> void:
	if input_action_test.is_empty():
		return
	if event.is_action_pressed(input_action_test):
		cargar()
	elif event.is_action_released(input_action_test):
		soltar()


func _actualizar_visual() -> void:
	# Crece de abajo hacia arriba ajustando el anclaje superior
	_fill.anchor_top = 1.0 - _valor
	# Interpola color según el nivel actual
	_fill.color = color_base.lerp(color_pico, _valor)


## Comienza a llenar la barra. Llamar mientras se presiona un botón.
func cargar() -> void:
	if _cargando:
		return
	_cargando = true
	set_process(true)


## Detiene el llenado. La barra comenzará a vaciarse.
func soltar() -> void:
	_cargando = false
	set_process(true)


## Devuelve el valor actual de la barra (0.0 a 1.0).
func obtener_valor() -> float:
	return _valor


## Reinicia la barra a 0 instantáneamente.
func reset() -> void:
	_valor = 0.0
	_cargando = false
	_barra_llena_emitida = false
	_actualizar_visual()
	set_process(false)
