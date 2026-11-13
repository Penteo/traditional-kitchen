class_name ChefView
extends Node2D
## Vista del chef. Elige una de las tres animaciones (reposo, caminar, cargar item) y la muestra con un AnimatedSprite2D.
## Si faltan los PNG en res://assets/art/chef/, vuelve al dibujo provisional de circulo (no se rompe nada).

signal animacion_cambiada(animacion: Animacion)

enum Animacion { REPOSO, CAMINAR, CARGAR }

const NOMBRES: Array[String] = ["reposo", "caminar", "cargar"]
const VISTAS: Array[String] = ["abajo", "arriba", "lado"]
const FOTOGRAMAS: Dictionary = {"reposo": 2, "caminar": 4, "cargar": 4}
const VELOCIDAD_FPS: Dictionary = {"reposo": 4.0, "caminar": 12.0, "cargar": 10.0}
const CARPETA_ARTE: String = "res://assets/art/chef/"
const ESCALA_SPRITE: float = 1.1
const POSICION_SPRITE: Vector2 = Vector2(0.0, -13.0)
const ALTURA_ICONO: float = 82.0
const VELOCIDAD_MINIMA: float = 1.0
const DURACION_PARPADEO: float = 0.45

var animacion: Animacion = Animacion.REPOSO

var _chef: Chef = null
var _sprite: AnimatedSprite2D = null
var _polvo: CPUParticles2D = null
var _tiempo: float = 0.0
var _parpadeo: float = 0.0
var _direccion_dibujada: Chef.Direccion = Chef.Direccion.ABAJO


func _ready() -> void:
	_chef = get_parent() as Chef
	_chef.accion_invalida.connect(_al_accion_invalida)
	_chef.item_cambiado.connect(queue_redraw)
	_crear_sprite()
	queue_redraw()


func _process(delta: float) -> void:
	var nueva := _elegir_animacion()
	if nueva != animacion:
		animacion = nueva
		animacion_cambiada.emit(nueva)
		queue_redraw()
	if _se_mueve() or _parpadeo > 0.0 or _chef.esta_cortando():
		_tiempo += delta
		queue_redraw()
	if _parpadeo > 0.0:
		_parpadeo = maxf(0.0, _parpadeo - delta)
		if _parpadeo == 0.0:
			queue_redraw()
	if _chef.direccion != _direccion_dibujada:
		_direccion_dibujada = _chef.direccion
		queue_redraw()
	_actualizar_sprite()


func nombre_animacion() -> String:
	return NOMBRES[animacion]


func _elegir_animacion() -> Animacion:
	if _chef.item_en_mano != null:
		return Animacion.CARGAR
	if _se_mueve():
		return Animacion.CAMINAR
	return Animacion.REPOSO


func _se_mueve() -> bool:
	return _chef.velocity.length() > VELOCIDAD_MINIMA


func _al_accion_invalida() -> void:
	_parpadeo = DURACION_PARPADEO
	queue_redraw()


## El icono del item parpadea durante una accion invalida.
func _icono_visible() -> bool:
	return _parpadeo <= 0.0 or int(_tiempo * 14.0) % 2 == 0


# --- Sprite animado -------------------------------------------------------------------------

## Construye los SpriteFrames desde los PNG (j1 o j2 segun el jugador). Si falta alguno, no crea el sprite.
func _crear_sprite() -> void:
	var carpeta := "%sj%d/" % [CARPETA_ARTE, _chef.numero_jugador]
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")
	for anim in NOMBRES:
		var cantidad: int = FOTOGRAMAS[anim]
		for vista in VISTAS:
			var nombre := "%s_%s" % [anim, vista]
			frames.add_animation(nombre)
			frames.set_animation_loop(nombre, true)
			frames.set_animation_speed(nombre, VELOCIDAD_FPS[anim])
			for i in cantidad:
				var ruta := "%s%s_%s_%d.png" % [carpeta, anim, vista, i]
				if not ResourceLoader.exists(ruta):
					push_warning("ChefView: falta %s, se usa el dibujo provisional." % ruta)
					return
				frames.add_frame(nombre, load(ruta) as Texture2D)
	_crear_polvo()
	_sprite = AnimatedSprite2D.new()
	_sprite.sprite_frames = frames
	_sprite.scale = Vector2(ESCALA_SPRITE, ESCALA_SPRITE)
	_sprite.position = POSICION_SPRITE
	_sprite.show_behind_parent = true
	add_child(_sprite)
	_actualizar_sprite()


func _actualizar_sprite() -> void:
	if _sprite == null:
		return
	var vista := _vista_actual()
	var nombre := "%s_%s" % [NOMBRES[animacion], vista]
	if _sprite.animation != StringName(nombre):
		var misma_base := String(_sprite.animation).begins_with(NOMBRES[animacion] + "_")
		var fotograma := _sprite.frame
		var progreso := _sprite.frame_progress
		_sprite.play(nombre)
		if misma_base:
			_sprite.set_frame_and_progress(fotograma, progreso)
	elif not _sprite.is_playing():
		_sprite.play(nombre)
	_sprite.flip_h = _chef.direccion == Chef.Direccion.IZQUIERDA
	# Parado con un item en las manos, la animacion de carga va mas lenta.
	var quieto_cargando := animacion == Animacion.CARGAR and not _se_mueve()
	_sprite.speed_scale = 0.35 if quieto_cargando else 1.0
	# Accion invalida: el chef sacude la cabeza de lado a lado.
	var temblor := sin(_tiempo * 60.0) * 3.0 if _parpadeo > 0.0 else 0.0
	var golpe := _golpe()
	var inclinacion := -1.0 if _chef.direccion == Chef.Direccion.IZQUIERDA else 1.0
	_sprite.position = POSICION_SPRITE + Vector2(temblor, golpe * 5.0)
	_sprite.rotation = golpe * 0.1 * inclinacion
	_sprite.scale = Vector2(ESCALA_SPRITE, ESCALA_SPRITE * (1.0 - 0.08 * golpe))
	_polvo.emitting = _se_mueve()


## Polvo bajo los pies mientras el chef camina.
func _crear_polvo() -> void:
	_polvo = CPUParticles2D.new()
	_polvo.position = Vector2(0.0, 30.0)
	_polvo.show_behind_parent = true
	_polvo.texture = EfectosVisuales.textura("particula.png")
	_polvo.emitting = false
	_polvo.amount = 10
	_polvo.lifetime = 0.45
	_polvo.direction = Vector2(0.0, -1.0)
	_polvo.spread = 70.0
	_polvo.gravity = Vector2.ZERO
	_polvo.initial_velocity_min = 10.0
	_polvo.initial_velocity_max = 30.0
	_polvo.scale_amount_min = 0.12
	_polvo.scale_amount_max = 0.3
	_polvo.color = Color(0.82, 0.7, 0.52, 0.55)
	add_child(_polvo)


func _vista_actual() -> String:
	match _chef.direccion:
		Chef.Direccion.ARRIBA:
			return "arriba"
		Chef.Direccion.ABAJO:
			return "abajo"
	return "lado"


# --- Dibujo ---------------------------------------------------------------------------------

func _draw() -> void:
	if _chef == null:
		return
	var radio := _chef.parametros.radio_colision
	if _sprite == null:
		_dibujar_provisional(radio)
	_dibujar_cuchillo(radio)
	_dibujar_item(radio)


## Intensidad del golpe de corte (0 a 1). Vale 0 si el chef no esta cortando.
func _golpe() -> float:
	if not _chef.esta_cortando():
		return 0.0
	return maxf(0.0, sin(_tiempo * 22.0))


## Cuchillo que sube y baja delante del chef mientras corta.
func _dibujar_cuchillo(radio: float) -> void:
	if not _chef.esta_cortando():
		return
	var golpe := _golpe()
	var elevacion := 1.0 - golpe
	var posicion := _chef.vector_direccion() * (radio + 8.0) + Vector2(0.0, -6.0 - elevacion * 14.0)
	draw_set_transform(posicion, -0.3 * elevacion)
	draw_colored_polygon(PackedVector2Array([Vector2(-5.0, -18.0), Vector2(5.0, -18.0), Vector2(5.0, 14.0), Vector2(-5.0, 20.0)]), Color(0.85, 0.88, 0.92))
	draw_rect(Rect2(-4.0, -36.0, 8.0, 18.0), Color(0.4, 0.25, 0.15))
	draw_set_transform(Vector2.ZERO, 0.0)


## Dibujo provisional (circulo con raya de direccion), solo si no hay arte.
func _dibujar_provisional(radio: float) -> void:
	var escala := 1.0
	if _se_mueve():
		escala = 1.0 + 0.06 * sin(_tiempo * 16.0)
	draw_circle(Vector2.ZERO, radio * escala, _chef.color)
	draw_line(Vector2.ZERO, _chef.vector_direccion() * radio, Color.WHITE, 4.0)
	if animacion == Animacion.CARGAR:
		var brazo := _chef.color.lightened(0.3)
		draw_circle(Vector2(-radio, -radio * 0.2), 10.0, brazo)
		draw_circle(Vector2(radio, -radio * 0.2), 10.0, brazo)


func _dibujar_item(radio: float) -> void:
	var item := _chef.item_en_mano
	if item == null or not _icono_visible():
		return
	var altura := ALTURA_ICONO if _sprite != null else 24.0
	var posicion := Vector2(0.0, -radio - altura)
	if _sprite != null:
		if IconoItem.dibujar(self, item, posicion, 68.0):
			return
	draw_circle(posicion, 16.0, item.color())
	draw_string(ThemeDB.fallback_font, posicion + Vector2(-60.0, -24.0), item.etiqueta(), HORIZONTAL_ALIGNMENT_CENTER, 120.0, 20)
