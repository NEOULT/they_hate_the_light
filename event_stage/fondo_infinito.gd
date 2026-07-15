extends TextureRect
## Fondo de espacio con scroll infinito horizontal.
## Desplaza la textura en _process() actualizando un parámetro del shader.


## Velocidad del scroll
@export var scroll_speed: float = 30.0

const SHADER_SCROLL := preload("res://event_stage/fondo_infinito.gdshader")

var _shader_material: ShaderMaterial
var _scroll_offset: float = 0.0


func _ready() -> void:
	_shader_material = ShaderMaterial.new()
	_shader_material.shader = SHADER_SCROLL
	material = _shader_material


func _process(delta: float) -> void:
	_scroll_offset += scroll_speed * delta * 0.005
	_shader_material.set_shader_parameter("scroll_offset", _scroll_offset)
