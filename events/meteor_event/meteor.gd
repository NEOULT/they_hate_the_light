## Meteorito individual que cae del cielo.
## Colisiona con los jugadores y se destruye al llegar al suelo o al salir de pantalla.
extends Area2D


## Velocidad de caída en píxeles/segundo.
@export var velocidad: float = 250.0

## Tamaño del meteorito (radio en píxeles).
@export var radio: float = 16.0

## Dirección de caída.
var direccion: Vector2 = Vector2.DOWN


signal golpeo_jugador(jugador: Node)


@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	# Configurar colisión circular
	var shape = CircleShape2D.new()
	shape.radius = radio
	_collision.shape = shape

	# Crear textura procedural del meteorito
	_crear_textura_meteorito()

	# Rotación inicial aleatoria
	_sprite.rotation = randf_range(0, TAU)

	# Conectar señal de colisión
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	# Movimiento de caída
	position += direccion * velocidad * delta

	# Rotar mientras cae
	_sprite.rotation += delta * 2.0

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
	else:
		# Fallback si no hay cámara: limpiar si está muy lejos del origen
		if abs(global_position.x) > 2000 or abs(global_position.y) > 2000:
			queue_free()


func _on_body_entered(body: Node) -> void:
	# Solo nos interesan los jugadores (CharacterBody2D)
	if not body is CharacterBody2D:
		return

	# Avisar al evento que golpeó a este jugador
	golpeo_jugador.emit(body)

	# Explosión visual
	_crear_explosion()
	queue_free()


func _crear_explosion() -> void:
	var explosion = ColorRect.new()
	explosion.size = Vector2(radio * 2, radio * 2)
	explosion.position = position - explosion.size / 2
	explosion.color = Color(1, 0.5, 0, 0.8)
	explosion.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Añadir al árbol desde la escena raíz por seguridad
	var parent = get_parent()
	if parent:
		parent.add_child(explosion)
	else:
		# Fallback al árbol global si no hay padre
		Engine.get_main_loop().current_scene.add_child(explosion)

	var tween = create_tween()
	tween.tween_property(explosion, "scale", Vector2(2, 2), 0.2)
	tween.parallel().tween_property(explosion, "modulate:a", 0.0, 0.3)
	tween.finished.connect(explosion.queue_free)


## Crea textura procedural de meteorito (círculo naranja-rojizo).
func _crear_textura_meteorito() -> void:
	var size = int(radio * 3)
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center = Vector2(size / 2.0, size / 2.0)
	var max_radius = size / 2.0 - 1

	for x in size:
		for y in size:
			var pos = Vector2(x, y)
			var dist = pos.distance_to(center)
			var noise = sin(x * 0.5) * cos(y * 0.5) * 2.0
			var r = max_radius + noise
			if dist <= r:
				var t = dist / r
				var color = Color(1.0 - t * 0.3, 0.4 - t * 0.3, 0.1 - t * 0.1, 1.0)
				image.set_pixel(x, y, color)

	var texture = ImageTexture.create_from_image(image)
	_sprite.texture = texture
	_sprite.scale = Vector2(0.5, 0.5)
