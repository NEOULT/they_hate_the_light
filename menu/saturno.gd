extends "res://menu/planeta_base.gd"
## Planeta Saturno - el más lento, flota suavemente, glow dorado con anillos

const SHADER_GLOW = preload("res://menu/saturno_glow.gdshader")

func _ready() -> void:
	tiempo_vuelta = 500.0  # El más lento
	flotar = true
	flotacion_velocidad = 0.3
	flotacion_amplitud = 4.0
	usar_parallax = true
	parallax_factor = 0.015
	super._ready()
	_aplicar_shader()


func _aplicar_shader() -> void:
	var mat := ShaderMaterial.new()
	mat.set_shader_parameter("intensidad_glow", 1.2)
	mat.set_shader_parameter("radio_glow", 5.0)
	mat.set_shader_parameter("velocidad_pulso", 0.6)
	mat.set_shader_parameter("brillo_anillos", 0.8)
	material = mat
