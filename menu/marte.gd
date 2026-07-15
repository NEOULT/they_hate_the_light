extends "res://menu/planeta_base.gd"
## Planeta Marte - gira lento, flota, tiene glow rojizo

const SHADER_GLOW = preload("res://menu/marte_glow.gdshader")

func _ready() -> void:
	tiempo_vuelta = 350.0
	flotar = true
	flotacion_velocidad = 0.2
	flotacion_amplitud = 10.0
	usar_parallax = true
	parallax_factor = 0.02
	super._ready()
	_aplicar_shader()


func _aplicar_shader() -> void:
	var mat := ShaderMaterial.new()
	mat.shader = SHADER_GLOW
	mat.set_shader_parameter("intensidad_glow", 1.0)
	mat.set_shader_parameter("radio_glow", 4.0)
	mat.set_shader_parameter("color_glow", Color(1.0, 0.4, 0.1))
	mat.set_shader_parameter("velocidad_pulso", 0.8)
	material = mat
