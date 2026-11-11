class_name Pantalla
extends Control
## Base de todas las pantallas (capa Vista). Cada pantalla construye su interfaz en _construir().

signal volver_solicitado

const COLOR_FONDO: Color = Color(0.11, 0.11, 0.14)
const COLOR_TEXTO_SUAVE: Color = Color(0.72, 0.72, 0.78)


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_construir()


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
	return etiqueta


func _boton(texto: String, accion: Callable, alto: float = 64.0) -> Button:
	var boton := Button.new()
	boton.text = texto
	boton.custom_minimum_size = Vector2(0.0, alto)
	boton.add_theme_font_size_override("font_size", 28)
	boton.pressed.connect(_al_pulsar.bind(accion))
	return boton


func _al_pulsar(accion: Callable) -> void:
	AudioController.reproducir_sfx("boton_menu")
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
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.2, 0.2, 0.26)
	estilo.set_corner_radius_all(12)
	estilo.set_content_margin_all(24.0)
	return estilo
