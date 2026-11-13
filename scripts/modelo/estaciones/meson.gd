class_name Meson
extends Estacion
## Superficie de apoyo (mesa de cocina). Cada celda guarda 1 item (R2), pero los mesones
## contiguos se dibujan como una sola mesa. Con un plato encima, acepta ingredientes que
## encajen en alguna receta. Hereda retirar de Estacion.

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


# --- Logica de apoyo y platos ---

func acepta(item: Item) -> bool:
	if items.is_empty():
		return true
	return _se_combinan(items[0], item)


func recibir(item: Item) -> bool:
	if not acepta(item):
		return false
	if items.is_empty():
		items.append(item)
	else:
		_combinar(items[0], item)
	item_cambiado.emit()
	queue_redraw()
	return true


## Un plato presente recibe un ingrediente; un plato que llega recoge el ingrediente suelto.
func _se_combinan(presente: Item, nuevo: Item) -> bool:
	var plato := presente as Plato
	var ingrediente := nuevo as Ingrediente
	if plato != null and ingrediente != null:
		return plato.acepta(ingrediente)
	plato = nuevo as Plato
	ingrediente = presente as Ingrediente
	if plato != null and ingrediente != null:
		return plato.acepta(ingrediente)
	return false


func _combinar(presente: Item, nuevo: Item) -> void:
	var plato := presente as Plato
	if plato != null:
		plato.agregar(nuevo as Ingrediente)
		return
	plato = nuevo as Plato
	plato.agregar(presente as Ingrediente)
	items.clear()
	items.append(plato)


# --- Vecinos y estilo ---

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


# --- Dibujo ---

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
	var item := items[0]
	if IconoItem.dibujar(self, item, centro, 56.0):
		return
	var plato := item as Plato
	if plato != null:
		_dibujar_plato_provisional(plato, centro)
		return
	draw_circle(centro, 16.0, item.color())
	draw_string(ThemeDB.fallback_font, centro + Vector2(-tamano.x / 2.0, 40.0), item.etiqueta(), HORIZONTAL_ALIGNMENT_CENTER, tamano.x, 14)


## Plato sin arte: disco blanco con un punto de color por cada ingrediente (hasta 4).
func _dibujar_plato_provisional(plato: Plato, centro: Vector2) -> void:
	draw_circle(centro, 24.0, Color(0.96, 0.96, 0.96))
	draw_arc(centro, 24.0, 0.0, TAU, 32, Color(0.5, 0.5, 0.55), 2.0, true)
	var cantidad := mini(plato.componentes.size(), 4)
	for i in cantidad:
		var desplazamiento := Vector2.ZERO
		if cantidad > 1:
			desplazamiento = Vector2.from_angle(-PI / 2.0 + TAU * i / cantidad) * 10.0
		draw_circle(centro + desplazamiento, 8.0, plato.componentes[i].color())