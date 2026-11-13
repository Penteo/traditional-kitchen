class_name Meson
extends Estacion
## Superficie de apoyo (mesa de cocina). Cada celda guarda 1 item cualquiera (R2), pero los
## mesones contiguos se dibujan como una sola mesa continua. Hereda recibir/retirar de Estacion.

const TOLERANCIA_VECINO: float = 2.0

var _une_izq: bool = false
var _une_der: bool = false
var _une_arriba: bool = false
var _une_abajo: bool = false
var _estilo_cuerpo: StyleBoxFlat
var _estilo_tope: StyleBoxFlat


## El grupo se llena en _enter_tree para que todos los mesones del nivel ya esten
## registrados cuando cada uno busca a sus vecinos en _ready.
func _enter_tree() -> void:
	add_to_group("mesones")


func _ready() -> void:
	nombre = "Meson"
	color_placeholder = Color(0.62, 0.7, 0.78)
	_detectar_vecinos()
	_crear_estilos()
	super()


## Marca por que lados hay otro meson pegado (distancia exacta de una celda).
func _detectar_vecinos() -> void:
	var paso := ($Colision.shape as RectangleShape2D).size
	for nodo in get_tree().get_nodes_in_group("mesones"):
		var otro := nodo as Meson
		if otro == null or otro == self:
			continue
		var d := otro.global_position - global_position
		if d.distance_to(Vector2(-paso.x, 0.0)) < TOLERANCIA_VECINO:
			_une_izq = true
		elif d.distance_to(Vector2(paso.x, 0.0)) < TOLERANCIA_VECINO:
			_une_der = true
		elif d.distance_to(Vector2(0.0, -paso.y)) < TOLERANCIA_VECINO:
			_une_arriba = true
		elif d.distance_to(Vector2(0.0, paso.y)) < TOLERANCIA_VECINO:
			_une_abajo = true


func _crear_estilos() -> void:
	_estilo_cuerpo = StyleBoxFlat.new()
	_estilo_cuerpo.bg_color = Color("7f8fa0")
	_estilo_cuerpo.border_color = Color("2b3947")
	_aplicar_bordes(_estilo_cuerpo, 3, 10)

	_estilo_tope = StyleBoxFlat.new()
	_estilo_tope.bg_color = Color("d3dce5")
	_estilo_tope.border_color = Color("9fb0c0")
	_aplicar_bordes(_estilo_tope, 2, 8)


## Sin borde ni esquina redondeada en los lados donde hay otro meson.
func _aplicar_bordes(estilo: StyleBoxFlat, borde: int, radio: int) -> void:
	estilo.border_width_left = 0 if _une_izq else borde
	estilo.border_width_right = 0 if _une_der else borde
	estilo.border_width_top = 0 if _une_arriba else borde
	estilo.border_width_bottom = 0 if _une_abajo else borde
	estilo.corner_radius_top_left = 0 if (_une_izq or _une_arriba) else radio
	estilo.corner_radius_top_right = 0 if (_une_der or _une_arriba) else radio
	estilo.corner_radius_bottom_left = 0 if (_une_izq or _une_abajo) else radio
	estilo.corner_radius_bottom_right = 0 if (_une_der or _une_abajo) else radio


## Resalte cuando un chef tiene este meson delante (igual que las estaciones con arte).
func _process(delta: float) -> void:
	_espera_cercania -= delta
	if _espera_cercania > 0.0:
		return
	_espera_cercania = INTERVALO_CERCANIA
	var hay_chef := false
	for nodo in get_tree().get_nodes_in_group("chefs"):
		var chef := nodo as Chef
		if chef != null and chef.estacion_objetivo() == self:
			hay_chef = true
			break
	if hay_chef != _cerca:
		_cerca = hay_chef
		queue_redraw()


func _draw() -> void:
	var tamano := ($Colision.shape as RectangleShape2D).size
	var izq := 0.0 if _une_izq else 3.0
	var der := 0.0 if _une_der else 3.0
	var arriba := 0.0 if _une_arriba else 3.0
	var abajo := 0.0 if _une_abajo else 3.0
	var cuerpo := Rect2(-tamano / 2.0 + Vector2(izq, arriba), tamano - Vector2(izq + der, arriba + abajo))
	if not _une_abajo:
		draw_rect(Rect2(cuerpo.position + Vector2(0.0, 6.0), cuerpo.size), Color(0.0, 0.0, 0.0, 0.25))
	draw_style_box(_estilo_cuerpo, cuerpo)

	var t_izq := 0.0 if _une_izq else 8.0
	var t_der := 0.0 if _une_der else 8.0
	var t_arriba := 0.0 if _une_arriba else 6.0
	var t_abajo := 0.0 if _une_abajo else 16.0
	var tope := Rect2(cuerpo.position + Vector2(t_izq, t_arriba), cuerpo.size - Vector2(t_izq + t_der, t_arriba + t_abajo))
	draw_style_box(_estilo_tope, tope)

	if _cerca:
		draw_rect(Rect2(-tamano / 2.0 + Vector2(5.0, 5.0), tamano - Vector2(10.0, 10.0)), Color(1.0, 0.92, 0.45, 0.95), false, 4.0)
	_dibujar_items(tope.get_center(), tamano)


func _dibujar_items(centro: Vector2, tamano: Vector2) -> void:
	if items.is_empty():
		return
	draw_circle(centro, 30.0, Color(1.0, 1.0, 1.0, 0.85))
	draw_arc(centro, 30.0, 0.0, TAU, 32, Color(0.23, 0.14, 0.09), 2.5, true)
	if IconoItem.dibujar(self, items[0], centro, 56.0):
		return
	draw_circle(centro, 16.0, items[0].color())
	draw_string(ThemeDB.fallback_font, centro + Vector2(-tamano.x / 2.0, 40.0), items[0].etiqueta(), HORIZONTAL_ALIGNMENT_CENTER, tamano.x, 14)