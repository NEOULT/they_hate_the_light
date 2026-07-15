extends TextureRect
## Fondo de estrellas con efecto de parpadeo (twinkle)

@export var twinkle_velocidad: float = 3.0
@export var twinkle_intensidad: float = 1.2
@export var twinkle_umbral: float = 0.1
@export var radio_glow: float = 3.0
@export var intensidad_glow: float = 1.0

const SHADER_TWINKLE = preload("res://menu/fondo_estelar_twinkle.gdshader")


func _ready() -> void:
	print("🚀 estrellas_fondo.gd _ready() ejecutado!")
	var mat := ShaderMaterial.new()
	mat.shader = SHADER_TWINKLE
	print("  → shader asignado correctamente")
	mat.set_shader_parameter("velocidad", twinkle_velocidad)
	mat.set_shader_parameter("intensidad", twinkle_intensidad)
	mat.set_shader_parameter("umbral_brillo", 0.01)  # MUY bajo para que todo brille
	mat.set_shader_parameter("radio_glow", 6.0)
	mat.set_shader_parameter("intensidad_glow", 2.0)  # Al máximo
	material = mat
	print("  → material asignado, textura =", texture)
	print("  → material.material =", material)
