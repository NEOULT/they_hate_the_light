extends TextureRect
## Script base para planetas del menú.
## Proporciona rotación, flotación y parallax.

## Velocidad de rotación (segundos por vuelta completa)
@export var tiempo_vuelta: float = 30.0
## Habilitar flotación arriba/abajo
@export var flotar: bool = true
## Velocidad de flotación
@export var flotacion_velocidad: float = 0.5
## Amplitud de flotación (píxeles)
@export var flotacion_amplitud: float = 5.0
## Habilitar parallax con el mouse
@export var usar_parallax: bool = true
## Factor de parallax
@export var parallax_factor: float = 0.02

var _posicion_base: Vector2
var _tiempo: float = 0.0


func _ready() -> void:
	# Centrar pivote para rotación
	pivot_offset = size * 0.5
	# Guardar posición inicial
	_posicion_base = position


func _process(delta: float) -> void:
	# Rotación
	rotation += delta * (TAU / max(tiempo_vuelta, 0.001))
	
	# Flotación
	if flotar:
		_tiempo += delta
		var offset_y = sin(_tiempo * flotacion_velocidad) * flotacion_amplitud
		position.y = _posicion_base.y + offset_y
	
	# Parallax con el mouse
	if usar_parallax:
		var mouse_pos = get_viewport().get_mouse_position()
		var viewport_size = get_viewport_rect().size
		var mouse_norm = (mouse_pos - viewport_size * 0.5) / (viewport_size * 0.5)
		position.x = _posicion_base.x + mouse_norm.x * parallax_factor * -50.0
