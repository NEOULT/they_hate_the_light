extends Node2D
## Spawner de cometas - genera cometas que vuelven en arco hacia los planetas

@export var cometas_activos: bool = true
@export var max_cometas_en_pantalla: int = 4
@export var intervalo_cometas: float = 3.0
@export var duracion_vuelo: float = 12.0
@export var arco_altura: float = -200.0
@export var escala_y: float = 0.073
@export var skew_grados: float = -60.6

# Parámetros del shader (compartido con estrellas)
@export var twinkle_velocidad: float = 3.0
@export var twinkle_intensidad: float = 1.2
@export var radio_glow: float = 3.0
@export var intensidad_glow: float = 1.0

const COMETA_TEXTURE = preload("res://menu/fondo_del_menu_cometa.png")
const SHADER_TWINKLE = preload("res://menu/fondo_estelar_twinkle.gdshader")

var _timer: float = 0.0
var _cometas_en_pantalla: int = 0
var _shader_material: ShaderMaterial


func _ready() -> void:
	# Crear material de shader compartido para todos los cometas
	_shader_material = ShaderMaterial.new()
	_shader_material.shader = SHADER_TWINKLE
	_shader_material.set_shader_parameter("velocidad", twinkle_velocidad)
	_shader_material.set_shader_parameter("intensidad", twinkle_intensidad)
	_shader_material.set_shader_parameter("umbral_brillo", 0.05)
	_shader_material.set_shader_parameter("radio_glow", radio_glow)
	_shader_material.set_shader_parameter("intensidad_glow", intensidad_glow)
	
	_timer = 1.0  # Primer cometa después de 1 segundo


func _process(delta: float) -> void:
	if not cometas_activos:
		return
	
	_timer -= delta
	if _timer <= 0.0:
		_spawnear_cometa()
		_timer = intervalo_cometas + randf_range(-1.0, 1.0)


func _spawnear_cometa() -> void:
	if _cometas_en_pantalla >= max_cometas_en_pantalla:
		return
	
	var cometa = Sprite2D.new()
	cometa.texture = COMETA_TEXTURE
	cometa.script = preload("res://menu/cometa.gd")
	
	var viewport_size = get_viewport_rect().size
	
	# Variar posición de inicio entre 3 zonas de la derecha
	var zona = randi() % 3
	var inicio: Vector2
	match zona:
		0:  # Esquina superior derecha
			inicio = Vector2(
				viewport_size.x + randf_range(50.0, 150.0),
				randf_range(-50.0, 80.0)
			)
		1:  # Un poco más a la izquierda
			inicio = Vector2(
				viewport_size.x + randf_range(50.0, 150.0),
				randf_range(80.0, viewport_size.y * 0.4)
			)
		2:  # Derecha de la pantalla
			inicio = Vector2(
				viewport_size.x + randf_range(50.0, 150.0),
				randf_range(viewport_size.y * 0.3, viewport_size.y * 0.7)
			)
	
	# Fin: cerca de la tierra (lado izquierdo)
	var fin = Vector2(
		randf_range(150.0, 350.0),
		randf_range(150.0, viewport_size.y - 200.0)
	)
	
	add_child(cometa)
	_cometas_en_pantalla += 1
	cometa.tree_exited.connect(_on_cometa_destruido)
	
	# Aplicar shader
	cometa.material = _shader_material
	
	# Escala X aleatoria
	var escala_x_random = randf_range(0.075, 0.175)
	
	cometa.configurar(
		inicio, fin,
		escala_x_random, escala_y, skew_grados,
		duracion_vuelo + randf_range(-2.0, 2.0),
		arco_altura + randf_range(-80.0, 80.0)
	)


func _on_cometa_destruido() -> void:
	_cometas_en_pantalla -= 1
