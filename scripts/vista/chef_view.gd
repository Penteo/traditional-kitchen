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
const ALTURA_ICONO: float = 50.0
const VELOCIDAD_MINIMA: float = 1.0
const DURACION_PARPADEO: float = 0.45

var animacion: Animacion = Animacion.REPOSO

var _chef: Chef = null
var _sprite: AnimatedSprite2D = null
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
	if _se_mueve() or _parpadeo > 0.0:
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
	_sprite.position = POSICION_SPRITE + Vector2(temblor, 0.0)


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
	_dibujar_item(radio)


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
	draw_circle(posicion, 16.0, item.color())
	draw_string(ThemeDB.fallback_font, posicion + Vector2(-60.0, -24.0), item.etiqueta(), HORIZONTAL_ALIGNMENT_CENTER, 120.0, 20)
