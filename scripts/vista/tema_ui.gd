class_name TemaUI
extends RefCounted
## Tema visual de madera para todas las pantallas (botones, paneles y deslizadores).
## Se crea en codigo, asi no hace falta tocar ninguna escena. Si existe
## res://assets/fonts/fuente_principal.ttf (o .otf), se usa como fuente por defecto.

const FUENTES: Array[String] = ["res://assets/fonts/fuente_principal.ttf", "res://assets/fonts/fuente_principal.otf"]
const MADERA: Color = Color(0.54, 0.33, 0.19)
const MADERA_CLARA: Color = Color(0.67, 0.42, 0.24)
const MADERA_OSCURA: Color = Color(0.36, 0.22, 0.13)
const NOGAL: Color = Color(0.30, 0.19, 0.12)
const CONTORNO: Color = Color(0.23, 0.14, 0.09)
const CREMA: Color = Color(0.98, 0.94, 0.86)
const MAIZ: Color = Color(0.95, 0.79, 0.30)

static var _tema: Theme = null


static func obtener() -> Theme:
	if _tema == null:
		_tema = _crear()
	return _tema


## Caja de madera con borde oscuro, grosor extra abajo (efecto de tabla) y sombra.
static func caja(fondo: Color, borde: Color = CONTORNO, grosor_abajo: int = 6) -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = fondo
	estilo.border_color = borde
	estilo.set_border_width_all(3)
	estilo.border_width_bottom = grosor_abajo
	estilo.set_corner_radius_all(12)
	estilo.shadow_color = Color(0.0, 0.0, 0.0, 0.35)
	estilo.shadow_size = 6
	estilo.shadow_offset = Vector2(0.0, 4.0)
	return estilo


static func _crear() -> Theme:
	var tema := Theme.new()

	var normal := caja(MADERA)
	var hover := caja(MADERA_CLARA)
	var presionado := caja(MADERA_OSCURA, CONTORNO, 3)
	var desactivado := caja(Color(0.38, 0.34, 0.31), Color(0.2, 0.18, 0.17))
	for estilo in [normal, hover, presionado, desactivado]:
		estilo.content_margin_left = 20.0
		estilo.content_margin_right = 20.0
		estilo.content_margin_top = 8.0
		estilo.content_margin_bottom = 8.0
	var foco := StyleBoxFlat.new()
	foco.draw_center = false
	foco.border_color = CREMA
	foco.set_border_width_all(3)
	foco.set_corner_radius_all(12)
	foco.expand_margin_left = 3.0
	foco.expand_margin_right = 3.0
	foco.expand_margin_top = 3.0
	foco.expand_margin_bottom = 3.0
	tema.set_stylebox("normal", "Button", normal)
	tema.set_stylebox("hover", "Button", hover)
	tema.set_stylebox("pressed", "Button", presionado)
	tema.set_stylebox("disabled", "Button", desactivado)
	tema.set_stylebox("focus", "Button", foco)
	tema.set_color("font_color", "Button", CREMA)
	tema.set_color("font_hover_color", "Button", MAIZ)
	tema.set_color("font_focus_color", "Button", CREMA)
	tema.set_color("font_pressed_color", "Button", Color.WHITE)
	tema.set_color("font_disabled_color", "Button", Color(0.68, 0.63, 0.58))
	tema.set_color("font_outline_color", "Button", CONTORNO)
	tema.set_constant("outline_size", "Button", 4)

	var panel := caja(NOGAL, CONTORNO, 5)
	panel.set_content_margin_all(16.0)
	tema.set_stylebox("panel", "PanelContainer", panel)

	var pista := StyleBoxFlat.new()
	pista.bg_color = Color(0.16, 0.10, 0.07)
	pista.border_color = CONTORNO
	pista.set_border_width_all(2)
	pista.set_corner_radius_all(6)
	pista.set_content_margin_all(5.0)
	var relleno := StyleBoxFlat.new()
	relleno.bg_color = MAIZ
	relleno.set_corner_radius_all(6)
	var relleno_claro := StyleBoxFlat.new()
	relleno_claro.bg_color = Color(1.0, 0.88, 0.45)
	relleno_claro.set_corner_radius_all(6)
	tema.set_stylebox("slider", "HSlider", pista)
	tema.set_stylebox("grabber_area", "HSlider", relleno)
	tema.set_stylebox("grabber_area_highlight", "HSlider", relleno_claro)

	for ruta in FUENTES:
		if ResourceLoader.exists(ruta):
			tema.default_font = load(ruta) as Font
			break
	return tema
