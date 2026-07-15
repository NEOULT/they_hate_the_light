## Reusable ficha (game piece) script.
## Allows overriding the texture and/or scale when instancing the scene,
## so the same scene can be used for multiple players with different sprites.
extends Node2D


## Optional override texture. If not set, the default from the scene is used.
@export var texture_override: Texture2D

## Optional override scale. If set, replaces the sprite's default scale.
@export var sprite_scale_override: Vector2

@onready var _sprite: Sprite2D = $ficha_sprite
@onready var _audio_inicio: AudioStreamPlayer2D = $AudioInicio
@onready var _audio_medio: AudioStreamPlayer2D = $AudioMedio
@onready var _audio_final: AudioStreamPlayer2D = $AudioFinal


func _ready() -> void:
	if texture_override:
		_sprite.texture = texture_override
	if sprite_scale_override:
		_sprite.scale = sprite_scale_override


## Reproduce la secuencia de sonidos de desplazamiento:
## inicio → medio → final, alternando (cada uno detiene al anterior).
func play_desplazamiento(duracion: float) -> void:
	_detener_todos()
	_audio_inicio.play()

	if duracion > 0.2:
		get_tree().create_timer(duracion * 0.3).timeout.connect(_sonido_medio)
		get_tree().create_timer(duracion * 0.65).timeout.connect(_sonido_final)


func _sonido_medio() -> void:
	_detener_todos()
	_audio_medio.play()


func _sonido_final() -> void:
	_detener_todos()
	_audio_final.play()


func _detener_todos() -> void:
	_audio_inicio.stop()
	_audio_medio.stop()
	_audio_final.stop()
