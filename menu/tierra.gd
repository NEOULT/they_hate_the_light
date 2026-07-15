extends "res://menu/planeta_base.gd"
## Planeta Tierra - gira más rápido que los demás

func _ready() -> void:
	tiempo_vuelta = 450.0  # Gira rápido
	flotar = false  # La Tierra no flota
	usar_parallax = false  # No se mueve con el mouse
	super._ready()
