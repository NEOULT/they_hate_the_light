## Carámbano que cae del techo.
## Similar al meteorito pero con física de hielo: cae recto, más lento, visual azul.
extends Area2D


## Velocidad de caída en píxeles/segundo.
@export var velocidad: float = 180.0

## Tamaño del carámbano.
@export var radio: float = 10.0

## Dirección de caída (siempre recto hacia abajo).
var direccion: Vector2 = Vector2.DOWN


signal golpeo_jugador(jugador: Node)


@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	# Colisión circular pequeña
	var shape = CircleShape2D.new()
	shape.radius = radio
	_collision.shape = shape

	_crear_textura_icicle()
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	position += direccion * velocidad * delta

	# Auto-destruirse al salir de la pantalla
	var camera = get_viewport().get_camera_2d()
	if camera:
		var viewport_size = get_viewport().get_visible_rect().size
		var cam_pos = camera.global_position
		var left = cam_pos.x - viewport_size.x / 2.0
		var right = cam_pos.x + viewport_size.x / 2.0
		var bottom = cam_pos.y + viewport_size.y / 2.0

		if global_position.y > bottom + 50 or global_position.x < left - 50 or global_position.x > right + 50:
			queue_free()


func _on_body_entered(body: Node) -> void:
	if not body is CharacterBody2D:
		return
	golpeo_jugador.emit(body)
	_crear_estallido()
	queue_free()


func _crear_estallido() -> void:
	var estallido = ColorRect.new()
	estallido.size = Vector2(radio * 3, radio * 3)
	estallido.position = position - estallido.size / 2
	estallido.color = Color(0.7, 0.9, 1.0, 0.7)
	estallido.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var parent = get_parent()
	if parent:
		parent.add_child(estallido)
	else:
		Engine.get_main_loop().current_scene.add_child(estallido)

	var tween = create_tween()
	tween.tween_property(estallido, "scale", Vector2(1.5, 1.5), 0.15)
	tween.parallel().tween_property(estallido, "modulate:a", 0.0, 0.25)
	tween.finished.connect(estallido.queue_free)


## Crea textura procedural: diamante/rombo azul claro.
func _crear_textura_icicle() -> void:
	var size = int(radio * 4)
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center = Vector2(size / 2.0, size / 2.0)

	for x in size:
		for y in size:
			var pos = Vector2(x, y)
			var dx = abs(pos.x - center.x)
			var dy = abs(pos.y - center.y)
			# Forma de diamante / rombo
			var half_w = size / 2.0 - 1
			var half_h = size / 2.0 - 1
			# Rombo: |dx/half_w + dy/half_h| <= 1
			if (dx / half_w + dy / half_h) <= 1.0:
				var t = (dx + dy) / (half_w + half_h)
				var color = Color(0.6 + t * 0.3, 0.8 - t * 0.2, 1.0, 1.0)
				image.set_pixel(x, y, color)

	var texture = ImageTexture.create_from_image(image)
	_sprite.texture = texture
	_sprite.scale = Vector2(0.4, 0.4)
