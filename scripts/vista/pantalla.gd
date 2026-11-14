class_name Pantalla
extends Control
## Base de todas las pantallas (capa Vista). Cada pantalla construye su interfaz en _construir().

signal volver_solicitado

const COLOR_FONDO: Color = Color(0.14, 0.10, 0.09)
const COLOR_TEXTO_SUAVE: Color = Color(0.72, 0.72, 0.78)
const CARPETA_UI: String = "res://assets/art/ui/"


func _ready() -> void:
	theme = TemaUI.obtener()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_construir()
	# Entrada con fundido (tambien durante la pausa del juego).
	modulate.a = 0.0
	var entrada := create_tween()
	entrada.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	entrada.tween_property(self, "modulate:a", 1.0, 0.25)


## Cada pantalla concreta arma aqui sus controles.
func _construir() -> void:
	pass


## MenuController entrega los datos (por ejemplo el nivel elegido) antes de anadir la pantalla al arbol.
func preparar(_datos: Dictionary) -> void:
	pass


func mostrar() -> void:
	show()


func ocultar() -> void:
	hide()


func _fondo() -> void:
	var fondo := ColorRect.new()
	fondo.color = COLOR_FONDO
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fondo)
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_decorar_fondo()


## Trama de rombos sobre el fondo y una guirnalda de papel picado arriba. Sin las imagenes, no se anade nada.
func _decorar_fondo() -> void:
	var trama := _textura_ui("fondo_tile.png")
	if trama != null:
		var tapiz := TextureRect.new()
		tapiz.texture = trama
		tapiz.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tapiz.stretch_mode = TextureRect.STRETCH_TILE
		tapiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(tapiz)
		tapiz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var guirnalda := _textura_ui("guirnalda.png")
	if guirnalda != null:
		var franja := TextureRect.new()
		franja.texture = guirnalda
		franja.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		franja.stretch_mode = TextureRect.STRETCH_TILE
		franja.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(franja)
		franja.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
		franja.offset_bottom = float(guirnalda.get_height())


func _textura_ui(nombre: String) -> Texture2D:
	var ruta := CARPETA_UI + nombre
	if ResourceLoader.exists(ruta):
		return load(ruta) as Texture2D
	return null


## Columna centrada donde se apilan los controles de la pantalla.
func _columna(ancho: float) -> VBoxContainer:
	var centro := CenterContainer.new()
	add_child(centro)
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var columna := VBoxContainer.new()
	columna.custom_minimum_size = Vector2(ancho, 0.0)
	columna.add_theme_constant_override("separation", 16)
	centro.add_child(columna)
	return columna


func _etiqueta(texto: String, tamano: int = 26, alineacion: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER, color: Color = Color.WHITE) -> Label:
	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.horizontal_alignment = alineacion
	etiqueta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.add_theme_color_override("font_color", color)
	if tamano >= 48:
		etiqueta.add_theme_color_override("font_outline_color", Color(0.15, 0.09, 0.06))
		etiqueta.add_theme_constant_override("outline_size", 8)
	return etiqueta


func _boton(texto: String, accion: Callable, alto: float = 64.0) -> Button:
	var boton := Button.new()
	boton.text = texto
	boton.custom_minimum_size = Vector2(0.0, alto)
	boton.add_theme_font_size_override("font_size", 28)
	boton.pressed.connect(_al_pulsar.bind(accion))
	return boton


func _al_pulsar(accion: Callable) -> void:
	EventBus.sfx_solicitado.emit("boton_menu")
	accion.call()


func _separador(alto: float) -> Control:
	var separador := Control.new()
	separador.custom_minimum_size = Vector2(0.0, alto)
	return separador


func _cuadro_color(color: Color, lado: float) -> ColorRect:
	var cuadro := ColorRect.new()
	cuadro.color = color
	cuadro.custom_minimum_size = Vector2(lado, lado)
	return cuadro


func _estilo_tarjeta() -> StyleBoxFlat:
	var estilo := TemaUI.caja(TemaUI.NOGAL, TemaUI.CONTORNO, 5)
	estilo.set_content_margin_all(24.0)
	return estilo


## Fila de estrellas (llenas y vacias). Sin las imagenes, devuelve el texto de siempre.
func _estrellas(cantidad: int, total: int = 3, lado: float = 48.0) -> Control:
	var llena := _textura_ui("estrella_llena.png")
	var vacia := _textura_ui("estrella_vacia.png")
	if llena == null or vacia == null:
		return _etiqueta("Estrellas: %d de %d" % [cantidad, total], 28)
	var fila := HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override("separation", 8)
	for i in total:
		var estrella := TextureRect.new()
		estrella.texture = llena if i < cantidad else vacia
		estrella.custom_minimum_size = Vector2(lado, lado)
		estrella.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		estrella.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		fila.add_child(estrella)
	return fila


## Icono de un ingrediente en un estado dado; si no hay arte, el cuadro de color de siempre.
func _icono_ingrediente(tipo: int, estado: int, lado: float) -> Control:
	var ingrediente := Ingrediente.new(tipo as Ingrediente.Tipo, estado as Ingrediente.Estado)
	if not IconoItem.hay_arte(ingrediente):
		return _cuadro_color(Ingrediente.COLORES[tipo], lado)
	var icono := IconoItemControl.new()
	icono.custom_minimum_size = Vector2(lado, lado)
	icono.establecer(ingrediente)
	return icono


## Los componentes de una receta como iconos: masa + queso, o empanada x2.
func _iconos_receta(receta: Receta, lado: float) -> HBoxContainer:
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 4)
	for i in receta.componentes.size():
		if i > 0:
			fila.add_child(_signo_receta("+", lado))
		var icono := _icono_ingrediente(receta.componentes[i], receta.estados_componentes[i], lado)
		icono.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		fila.add_child(icono)
	if receta.unidades_por_pedido > 1:
		fila.add_child(_signo_receta("x%d" % receta.unidades_por_pedido, lado))
	return fila


func _signo_receta(texto: String, lado: float) -> Label:
	var signo := _etiqueta(texto, maxi(int(lado * 0.5), 14))
	signo.custom_minimum_size = Vector2(lado * 0.6, lado)
	signo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return signo
