class_name HUDView
extends Pantalla
## Interfaz durante la partida: reloj, pedidos, puntaje con los umbrales de estrellas y el item de cada chef.

const ANCHO_TARJETA: float = 280.0
const ANCHO_BARRA_PEDIDO: float = 240.0
const ALTO_BARRA_PEDIDO: float = 14.0
const COLOR_VERDE: Color = Color(0.4, 0.85, 0.4)
const COLOR_AMBAR: Color = Color(1.0, 0.75, 0.2)
const COLOR_ROJO: Color = Color(0.95, 0.3, 0.3)
const BARRA_X: float = 1760.0
const BARRA_Y: float = 200.0
const BARRA_ANCHO: float = 56.0
const BARRA_ALTO: float = 700.0

var _sesion: GameSession = null
var _chefs: Array[Chef] = []
var _reloj: Label
var _cuenta: Label
var _etiqueta_puntos: Label
var _columna_pedidos: VBoxContainer
var _relleno_puntos: ColorRect
var _barras_pedido: Array[Dictionary] = []
var _etiquetas_chef: Array[Label] = []
var _iconos_chef: Array[ColorRect] = []


func _construir() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_reloj = _etiqueta("0:00", 64)
	add_child(_reloj)
	_reloj.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_reloj.offset_left = -150.0
	_reloj.offset_right = 150.0
	_reloj.offset_top = 16.0
	_reloj.offset_bottom = 100.0

	_columna_pedidos = VBoxContainer.new()
	_columna_pedidos.position = Vector2(30.0, 140.0)
	_columna_pedidos.add_theme_constant_override("separation", 12)
	add_child(_columna_pedidos)

	_etiqueta_puntos = _etiqueta("Puntos: 0", 30)
	_etiqueta_puntos.custom_minimum_size = Vector2(260.0, 0.0)
	_etiqueta_puntos.position = Vector2(BARRA_X - 102.0, BARRA_Y - 56.0)
	add_child(_etiqueta_puntos)
	var fondo_barra := ColorRect.new()
	fondo_barra.color = Color(0.0, 0.0, 0.0, 0.5)
	fondo_barra.position = Vector2(BARRA_X, BARRA_Y)
	fondo_barra.size = Vector2(BARRA_ANCHO, BARRA_ALTO)
	add_child(fondo_barra)
	_relleno_puntos = ColorRect.new()
	_relleno_puntos.color = COLOR_VERDE
	add_child(_relleno_puntos)

	for i in 2:
		var fila := HBoxContainer.new()
		fila.position = Vector2(30.0 if i == 0 else 1380.0, 1010.0)
		fila.add_theme_constant_override("separation", 12)
		add_child(fila)
		var icono := _cuadro_color(Color.GRAY, 28.0)
		fila.add_child(icono)
		var texto := _etiqueta("", 24, HORIZONTAL_ALIGNMENT_LEFT, Color(0.45, 0.65, 1.0) if i == 0 else Color(1.0, 0.5, 0.5))
		texto.custom_minimum_size = Vector2(480.0, 0.0)
		fila.add_child(texto)
		_iconos_chef.append(icono)
		_etiquetas_chef.append(texto)

	_cuenta = _etiqueta("3", 220)
	_cuenta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(_cuenta)
	_cuenta.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


## Conecta el HUD con la sesion y los chefs. Se llama una vez que la pantalla ya esta en el arbol.
func vincular(sesion: GameSession, chefs: Array[Chef]) -> void:
	_sesion = sesion
	_chefs = chefs
	_crear_marcas(sesion.nivel.cuota)
	sesion.tiempo_actualizado.connect(_al_actualizar_tiempo)
	sesion.cuenta_atras_cambiada.connect(_al_cambiar_cuenta)
	sesion.estado_cambiado.connect(_al_cambiar_estado)
	sesion.puntuacion.puntaje_cambiado.connect(_al_cambiar_puntaje)
	sesion.gestor_pedidos.pedido_generado.connect(_reconstruir_pedidos)
	sesion.gestor_pedidos.pedido_entregado.connect(_reconstruir_pedidos)
	sesion.gestor_pedidos.pedido_vencido.connect(_reconstruir_pedidos)
	sesion.gestor_pedidos.pedido_rechazado.connect(_reconstruir_pedidos)
	for chef in chefs:
		chef.item_cambiado.connect(_actualizar_chefs)
	_mostrar_reloj(sesion.tiempo_restante)
	_al_cambiar_puntaje(0, 0)
	_cuenta.visible = sesion.estado == GameSession.Estado.CUENTA_ATRAS
	_cuenta.text = str(ceili(GameSession.DURACION_CUENTA_ATRAS))
	_reconstruir_pedidos()
	_actualizar_chefs()


func _crear_marcas(cuota: int) -> void:
	var marcas := [
		[cuota, "Cuota: %d" % cuota],
		[roundi(cuota * 1.4), "2 estrellas: %d" % roundi(cuota * 1.4)],
		[roundi(cuota * 1.8), "3 estrellas: %d" % roundi(cuota * 1.8)],
	]
	for marca in marcas:
		var y := BARRA_Y + BARRA_ALTO * (1.0 - float(marca[0]) / (cuota * 2.0))
		var linea := ColorRect.new()
		linea.color = Color.WHITE
		linea.position = Vector2(BARRA_X - 12.0, y - 2.0)
		linea.size = Vector2(BARRA_ANCHO + 24.0, 4.0)
		add_child(linea)
		var texto := _etiqueta(marca[1], 18, HORIZONTAL_ALIGNMENT_RIGHT)
		texto.custom_minimum_size = Vector2(170.0, 0.0)
		texto.position = Vector2(BARRA_X - 188.0, y - 14.0)
		add_child(texto)


func _al_actualizar_tiempo(restante: float) -> void:
	_mostrar_reloj(restante)
	_refrescar_barras()


func _mostrar_reloj(restante: float) -> void:
	var segundos := ceili(restante)
	_reloj.text = "%d:%02d" % [floori(segundos / 60.0), segundos % 60]


func _al_cambiar_cuenta(valor: int) -> void:
	_cuenta.text = str(valor)


func _al_cambiar_estado(estado: GameSession.Estado) -> void:
	_cuenta.visible = estado == GameSession.Estado.CUENTA_ATRAS


func _al_cambiar_puntaje(puntos: int, cambio: int) -> void:
	_etiqueta_puntos.text = "Puntos: %d" % puntos
	var fraccion := clampf(float(puntos) / (_sesion.nivel.cuota * 2.0), 0.0, 1.0)
	var alto := BARRA_ALTO * fraccion
	_relleno_puntos.position = Vector2(BARRA_X, BARRA_Y + BARRA_ALTO - alto)
	_relleno_puntos.size = Vector2(BARRA_ANCHO, alto)
	if cambio != 0:
		_flotante(cambio)


## Numero flotante "+pts" / "-pts" junto a la barra de puntaje.
func _flotante(cambio: int) -> void:
	var color := Color(0.5, 1.0, 0.5) if cambio > 0 else Color(1.0, 0.45, 0.45)
	var texto := _etiqueta("%+d" % cambio, 44, HORIZONTAL_ALIGNMENT_CENTER, color)
	texto.custom_minimum_size = Vector2(200.0, 0.0)
	texto.position = Vector2(BARRA_X - 72.0, 130.0)
	add_child(texto)
	var animacion := create_tween()
	animacion.set_parallel(true)
	animacion.tween_property(texto, "position:y", 70.0, 1.0)
	animacion.tween_property(texto, "modulate:a", 0.0, 1.0)
	animacion.chain().tween_callback(texto.queue_free)


## Las tarjetas se ordenan de la mas antigua a la mas reciente (maximo 4 a la vez).
func _reconstruir_pedidos(_pedido: Pedido = null) -> void:
	for hijo in _columna_pedidos.get_children():
		_columna_pedidos.remove_child(hijo)
		hijo.queue_free()
	_barras_pedido.clear()
	for pedido in _sesion.gestor_pedidos.activos:
		_columna_pedidos.add_child(_tarjeta(pedido))
	_refrescar_barras()


func _tarjeta(pedido: Pedido) -> PanelContainer:
	var tarjeta := PanelContainer.new()
	tarjeta.custom_minimum_size = Vector2(ANCHO_TARJETA, 0.0)
	var estilo := _estilo_tarjeta()
	estilo.set_content_margin_all(10.0)
	tarjeta.add_theme_stylebox_override("panel", estilo)
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 4)
	tarjeta.add_child(caja)
	caja.add_child(_etiqueta("#%d %s" % [pedido.numero, pedido.receta.nombre], 24, HORIZONTAL_ALIGNMENT_LEFT))
	caja.add_child(_etiqueta(_componentes(pedido.receta), 18, HORIZONTAL_ALIGNMENT_LEFT, COLOR_TEXTO_SUAVE))
	var barra := Control.new()
	barra.custom_minimum_size = Vector2(ANCHO_BARRA_PEDIDO, ALTO_BARRA_PEDIDO)
	var fondo := ColorRect.new()
	fondo.color = Color(0.0, 0.0, 0.0, 0.5)
	fondo.size = Vector2(ANCHO_BARRA_PEDIDO, ALTO_BARRA_PEDIDO)
	barra.add_child(fondo)
	var relleno := ColorRect.new()
	relleno.size = Vector2(ANCHO_BARRA_PEDIDO, ALTO_BARRA_PEDIDO)
	barra.add_child(relleno)
	caja.add_child(barra)
	_barras_pedido.append({"pedido": pedido, "relleno": relleno})
	return tarjeta


func _componentes(receta: Receta) -> String:
	var partes := PackedStringArray()
	for i in receta.componentes.size():
		partes.append("%s (%s)" % [Ingrediente.NOMBRES[receta.componentes[i]], Ingrediente.ESTADOS[receta.estados_componentes[i]]])
	var texto := " + ".join(partes)
	if receta.unidades_por_pedido > 1:
		texto += " (x%d)" % receta.unidades_por_pedido
	return texto


## Verde con mas del 50 % del tiempo, ambar entre el 25 % y el 50 %, rojo por debajo del 25 %.
func _refrescar_barras() -> void:
	for entrada in _barras_pedido:
		var pedido: Pedido = entrada["pedido"]
		var relleno: ColorRect = entrada["relleno"]
		var fraccion := clampf(pedido.fraccion_restante(), 0.0, 1.0)
		relleno.size = Vector2(ANCHO_BARRA_PEDIDO * fraccion, ALTO_BARRA_PEDIDO)
		if fraccion > 0.5:
			relleno.color = COLOR_VERDE
		elif fraccion >= 0.25:
			relleno.color = COLOR_AMBAR
		else:
			relleno.color = COLOR_ROJO


func _actualizar_chefs() -> void:
	for i in _chefs.size():
		var item := _chefs[i].item_en_mano
		_iconos_chef[i].color = item.color() if item != null else Color(0.35, 0.35, 0.4)
		_etiquetas_chef[i].text = "J%d: %s" % [_chefs[i].numero_jugador, item.etiqueta() if item != null else "manos libres"]
