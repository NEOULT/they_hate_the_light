extends Sprite2D

## Cometa que vuela en arco desde el lado derecho hacia el planeta.
## Todas las propiedades de Transform se gestionan de forma consistente.

## Duración total del vuelo en segundos
@export var duracion_vuelo: float = 12.0
## Punto de control Y del arco (negativo = más arriba)
@export var arco_altura: float = -200.0
## Escala del cometa (X e Y independientes)
@export var escala_x: float = 0.175
@export var escala_y: float = 0.073
## Skew (inclinación) del cometa en grados
@export var skew_grados: float = -60.6
## Opacidad máxima
@export var opacidad_max: float = 0.85

var _tiempo: float = 0.0
var _inicio: Vector2
var _control: Vector2
var _fin: Vector2
var _configurado: bool = false


## Configura todo el cometa de una vez: transform + trayectoria
func configurar(p_inicio: Vector2, p_fin: Vector2, p_esc_x: float, p_esc_y: float, p_skew: float, p_duracion: float, p_arco: float) -> void:
	# Aplicar propiedades básicas
	escala_x = p_esc_x
	escala_y = p_esc_y
	skew_grados = p_skew
	duracion_vuelo = p_duracion
	arco_altura = p_arco
	
	# Transform: posición inicial, escala no uniforme, skew, z_index
	position = p_inicio
	scale = Vector2(escala_x, escala_y)
	skew = deg_to_rad(skew_grados)
	rotation = 0.0
	z_index = 1  # Detrás de la tierra (z_index = 2)
	modulate.a = 0.0
	
	# Trayectoria Bézier
	_inicio = p_inicio
	_fin = p_fin
	_control = Vector2(
		(p_inicio.x + p_fin.x) * 0.5,
		min(p_inicio.y, p_fin.y) + arco_altura
	)
	
	_configurado = true


func _process(delta: float) -> void:
	if not _configurado:
		return
	
	_tiempo += delta
	var t = clamp(_tiempo / duracion_vuelo, 0.0, 1.0)
	
	# Position: curva de Bézier
	position = _bezier(t)
	
	# Rotation: apuntar en la dirección del movimiento
	if t < 0.98:
		var t_next = clamp(t + 0.01, 0.0, 1.0)
		var pos_next = _bezier(t_next)
		rotation = (pos_next - position).angle()
	
	# Scale y Skew: constantes durante el vuelo (ya configurados)
	# scale y skew se mantienen iguales
	
	# Modulate alpha: fade in/out suave y gradual
	if t < 0.15:
		# Fade in: 0% -> 15% del vuelo
		modulate.a = lerp(0.0, opacidad_max, t / 0.15)
	elif t > 0.7:
		# Fade out lineal: 70% -> 100% del vuelo
		var fade_t = (t - 0.7) / 0.3
		modulate.a = lerp(opacidad_max, 0.0, fade_t)
	else:
		modulate.a = opacidad_max
	
	# Eliminar al terminar
	if t >= 1.0 and modulate.a <= 0.0:
		queue_free()


## Curva de Bézier cuadrática
func _bezier(t: float) -> Vector2:
	var u = 1.0 - t
	return u * u * _inicio + 2.0 * u * t * _control + t * t * _fin
