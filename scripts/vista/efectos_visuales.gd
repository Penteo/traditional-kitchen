class_name EfectosVisuales
extends Node2D
## Efectos de la partida: vapor y humo en las estaciones que cocinan, migas al cortar y chispas con
## puntos flotantes al ganar o perder puntos. Solo escucha senales: no cambia nada de la logica.

const CARPETA_ARTE: String = "res://assets/art/efectos/"
const COLOR_GANA: Color = Color(1.0, 0.92, 0.45)
const COLOR_PIERDE: Color = Color(1.0, 0.42, 0.38)
const CONTORNO: Color = Color(0.15, 0.09, 0.06)

static var _cache: Dictionary = {}

var _barra: Estacion = null


## Textura de particula (null si falta el PNG; las particulas se dibujan entonces como cuadritos).
static func textura(nombre: String) -> Texture2D:
	if _cache.has(nombre):
		return _cache[nombre] as Texture2D
	var ruta := CARPETA_ARTE + nombre
	var cargada: Texture2D = null
	if ResourceLoader.exists(ruta):
		cargada = load(ruta) as Texture2D
	_cache[nombre] = cargada
	return cargada


func vincular(sesion: GameSession, estaciones: Array[Estacion]) -> void:
	for estacion in estaciones:
		if estacion is BarraEntrega:
			_barra = estacion
		var coccion := estacion as EstacionCoccion
		if coccion != null:
			_preparar_vapor(coccion)
		var tabla := estacion as TablaCortar
		if tabla != null:
			tabla.corte_iniciado.connect(_migas.bind(tabla))
	sesion.puntuacion.puntaje_cambiado.connect(_al_cambiar_puntaje)


# --- Vapor y humo de las estaciones de coccion ----------------------------------------------

func _preparar_vapor(coccion: EstacionCoccion) -> void:
	var emisor := _emisor(coccion.position + Vector2(0.0, -20.0), "particula.png")
	emisor.emitting = false
	emisor.direction = Vector2(0.0, -1.0)
	emisor.spread = 25.0
	emisor.gravity = Vector2(0.0, -20.0)
	emisor.color_ramp = _rampa(0.25)
	coccion.estado_cambiado.connect(_al_cambiar_estado.bind(coccion, emisor))
	_ajustar_vapor(emisor, coccion.estado)


func _al_cambiar_estado(nuevo: EstacionCoccion.Estado, coccion: EstacionCoccion, emisor: CPUParticles2D) -> void:
	_ajustar_vapor(emisor, nuevo)
	if nuevo == EstacionCoccion.Estado.LISTO:
		_destello(coccion.position + Vector2(0.0, -10.0), Color(1.0, 0.95, 0.7), 8)


func _ajustar_vapor(emisor: CPUParticles2D, estado: EstacionCoccion.Estado) -> void:
	match estado:
		EstacionCoccion.Estado.VACIA:
			emisor.emitting = false
			return
		EstacionCoccion.Estado.PROCESANDO:
			_configurar_vapor(emisor, 6, 1.4, 20.0, 35.0, 0.5, 0.9, Color(1.0, 1.0, 1.0, 0.7))
		EstacionCoccion.Estado.LISTO:
			_configurar_vapor(emisor, 10, 1.4, 30.0, 50.0, 0.6, 1.0, Color(1.0, 0.95, 0.75, 0.85))
		EstacionCoccion.Estado.PELIGRO:
			_configurar_vapor(emisor, 14, 0.9, 40.0, 70.0, 0.6, 1.0, Color(0.6, 0.6, 0.62, 0.9))
		EstacionCoccion.Estado.QUEMADO:
			_configurar_vapor(emisor, 14, 1.8, 35.0, 60.0, 0.8, 1.4, Color(0.14, 0.12, 0.12, 0.95))
	emisor.emitting = true


func _configurar_vapor(emisor: CPUParticles2D, cantidad: int, vida: float, v_min: float, v_max: float, e_min: float, e_max: float, color: Color) -> void:
	emisor.amount = cantidad
	emisor.lifetime = vida
	emisor.initial_velocity_min = v_min
	emisor.initial_velocity_max = v_max
	emisor.scale_amount_min = e_min
	emisor.scale_amount_max = e_max
	emisor.color = color


# --- Migas, chispas y puntos flotantes ------------------------------------------------------

func _migas(tabla: TablaCortar) -> void:
	var emisor := _emisor(tabla.position + Vector2(0.0, -10.0), "particula.png")
	emisor.one_shot = true
	emisor.amount = 10
	emisor.lifetime = 0.5
	emisor.explosiveness = 1.0
	emisor.direction = Vector2(0.0, -1.0)
	emisor.spread = 120.0
	emisor.gravity = Vector2(0.0, 500.0)
	emisor.initial_velocity_min = 90.0
	emisor.initial_velocity_max = 170.0
	emisor.scale_amount_min = 0.15
	emisor.scale_amount_max = 0.3
	emisor.color = Color(0.96, 0.86, 0.58)
	emisor.emitting = true
	_autodestruir(emisor, 1.0)


func _destello(punto: Vector2, color: Color, cantidad: int) -> void:
	var emisor := _emisor(punto, "chispa.png")
	emisor.one_shot = true
	emisor.amount = cantidad
	emisor.lifetime = 0.8
	emisor.explosiveness = 1.0
	emisor.direction = Vector2(0.0, -1.0)
	emisor.spread = 180.0
	emisor.gravity = Vector2(0.0, 260.0)
	emisor.initial_velocity_min = 120.0
	emisor.initial_velocity_max = 260.0
	emisor.scale_amount_min = 0.35
	emisor.scale_amount_max = 0.7
	emisor.color = color
	emisor.color_ramp = _rampa(0.7, true)
	emisor.emitting = true
	_autodestruir(emisor, 1.3)


func _al_cambiar_puntaje(_puntos: int, cambio: int) -> void:
	if cambio == 0:
		return
	var punto := _posicion_barra()
	if cambio > 0:
		_destello(punto, Color(1.0, 0.85, 0.3), 16)
		_texto_flotante("+%d" % cambio, punto, COLOR_GANA)
	else:
		_texto_flotante("%d" % cambio, punto, COLOR_PIERDE)


func _posicion_barra() -> Vector2:
	return _barra.position if _barra != null else Vector2(960.0, 540.0)


func _texto_flotante(texto: String, origen: Vector2, color: Color) -> void:
	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.size = Vector2(200.0, 60.0)
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.add_theme_font_size_override("font_size", 48)
	etiqueta.add_theme_color_override("font_color", color)
	etiqueta.add_theme_color_override("font_outline_color", CONTORNO)
	etiqueta.add_theme_constant_override("outline_size", 10)
	etiqueta.position = origen - etiqueta.size / 2.0 + Vector2(0.0, -70.0)
	etiqueta.pivot_offset = etiqueta.size / 2.0
	etiqueta.scale = Vector2(0.4, 0.4)
	add_child(etiqueta)
	var animacion := create_tween()
	animacion.set_parallel(true)
	animacion.tween_property(etiqueta, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	animacion.tween_property(etiqueta, "position:y", etiqueta.position.y - 80.0, 1.1).set_ease(Tween.EASE_OUT)
	animacion.tween_property(etiqueta, "modulate:a", 0.0, 0.5).set_delay(0.7)
	animacion.chain().tween_callback(etiqueta.queue_free)


# --- Utilidades -----------------------------------------------------------------------------

func _emisor(punto: Vector2, nombre_textura: String) -> CPUParticles2D:
	var emisor := CPUParticles2D.new()
	emisor.position = punto
	emisor.texture = textura(nombre_textura)
	add_child(emisor)
	return emisor


## Aparece suave, se mantiene y se desvanece (opcionalmente sin aparecer de golpe).
func _rampa(punto_medio: float, empieza_visible: bool = false) -> Gradient:
	var rampa := Gradient.new()
	rampa.offsets = PackedFloat32Array([0.0, punto_medio, 1.0])
	rampa.colors = PackedColorArray([Color(1.0, 1.0, 1.0, 1.0 if empieza_visible else 0.0), Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0)])
	return rampa


func _autodestruir(nodo: Node, segundos: float) -> void:
	get_tree().create_timer(segundos).timeout.connect(nodo.queue_free)
