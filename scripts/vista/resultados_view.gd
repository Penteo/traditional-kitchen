class_name ResultadosView
extends Pantalla
## Resultados del nivel: titulo, estrellas, puntaje contra cuota, conteos y entrada nueva o dato curioso.

signal reintentar_solicitado
signal continuar_solicitado
signal menu_solicitado

const ANCHO_TARJETA: float = 940.0
const COLOR_EXITO: Color = Color(0.5, 1.0, 0.5)
const COLOR_DERROTA: Color = Color(1.0, 0.4, 0.4)
const COLOR_BORDE_DERROTA: Color = Color(0.8, 0.22, 0.2)
const COLOR_QUEMADO: Color = Color(1.0, 0.65, 0.3)

var resultado: ResultadoPartida = null

var _boton_foco: Button = null


func preparar(datos: Dictionary) -> void:
	resultado = datos.get("resultado") as ResultadoPartida


func _construir() -> void:
	var cumplida := resultado.cuota_cumplida

	var velo := ColorRect.new()
	velo.color = Color(0.0, 0.0, 0.0, 0.85)
	add_child(velo)
	velo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var centro := CenterContainer.new()
	add_child(centro)
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var tarjeta := PanelContainer.new()
	tarjeta.custom_minimum_size = Vector2(ANCHO_TARJETA, 0.0)
	tarjeta.add_theme_stylebox_override("panel", _estilo_resultado(cumplida))
	centro.add_child(tarjeta)

	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 14)
	tarjeta.add_child(columna)

	columna.add_child(_etiqueta("¡CUOTA CUMPLIDA!" if cumplida else "ORDEN DE EXPULSIÓN", 68, HORIZONTAL_ALIGNMENT_CENTER, COLOR_EXITO if cumplida else COLOR_DERROTA))
	if not cumplida:
		columna.add_child(_firma_antagonista())
	columna.add_child(_estrellas(resultado.estrellas, 3, 60.0))
	columna.add_child(_bloque_puntaje(cumplida))
	columna.add_child(_bloque_conteos())
	var destacado := _bloque_destacado()
	if destacado != null:
		columna.add_child(destacado)
	columna.add_child(_separador(4.0))
	columna.add_child(_botones(cumplida))
	_boton_foco.grab_focus()


func _estilo_resultado(cumplida: bool) -> StyleBoxFlat:
	var fondo := TemaUI.NOGAL if cumplida else Color(0.22, 0.11, 0.09)
	var borde := TemaUI.MAIZ if cumplida else COLOR_BORDE_DERROTA
	var estilo := TemaUI.caja(fondo, borde, 8)
	estilo.set_border_width_all(5)
	estilo.border_width_bottom = 9
	estilo.set_corner_radius_all(18)
	estilo.set_content_margin_all(36.0)
	return estilo


# --- Firma del antagonista (solo en derrota) ---

func _firma_antagonista() -> Control:
	var antagonista := load("res://data/antagonista.tres") as DatosAntagonista
	var nombre := antagonista.nombre if antagonista != null else "El concesionario"
	var fila := HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override("separation", 14)
	fila.add_child(_retrato_antagonista(nombre))
	var texto := _etiqueta("Firmado: %s" % nombre, 28, HORIZONTAL_ALIGNMENT_LEFT, TemaUI.CREMA)
	texto.autowrap_mode = TextServer.AUTOWRAP_OFF
	texto.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	fila.add_child(texto)
	return fila


## Usa assets/art/ui/antagonista.png si existe; si no, un medallon con la inicial.
func _retrato_antagonista(nombre: String) -> Control:
	var arte := _textura_ui("antagonista.png")
	if arte != null:
		var imagen := TextureRect.new()
		imagen.texture = arte
		imagen.custom_minimum_size = Vector2(84.0, 84.0)
		imagen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		imagen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		imagen.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		return imagen
	var medallon := PanelContainer.new()
	var estilo := TemaUI.caja(Color(0.45, 0.14, 0.12), TemaUI.CONTORNO, 3)
	estilo.set_corner_radius_all(32)
	estilo.set_content_margin_all(0.0)
	medallon.add_theme_stylebox_override("panel", estilo)
	medallon.custom_minimum_size = Vector2(64.0, 64.0)
	medallon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var inicial := _etiqueta(nombre.substr(0, 1).to_upper(), 36, HORIZONTAL_ALIGNMENT_CENTER, TemaUI.CREMA)
	inicial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	inicial.autowrap_mode = TextServer.AUTOWRAP_OFF
	medallon.add_child(inicial)
	return medallon


# --- Puntaje y cuota ---

func _bloque_puntaje(cumplida: bool) -> Control:
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 8)
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 24)
	var puntaje := _dato_grande("PUNTAJE", str(resultado.puntaje), COLOR_EXITO if cumplida else TemaUI.CREMA)
	var cuota := _dato_grande("CUOTA", str(resultado.cuota), TemaUI.MAIZ)
	puntaje.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cuota.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_child(puntaje)
	fila.add_child(cuota)
	caja.add_child(fila)
	caja.add_child(_barra_progreso(float(resultado.puntaje) / maxf(float(resultado.cuota), 1.0), cumplida))
	return caja


func _dato_grande(titulo: String, valor: String, color: Color) -> VBoxContainer:
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 0)
	caja.add_child(_etiqueta(titulo, 22, HORIZONTAL_ALIGNMENT_CENTER, TemaUI.CREMA.darkened(0.25)))
	caja.add_child(_etiqueta(valor, 56, HORIZONTAL_ALIGNMENT_CENTER, color))
	return caja


## Barra de puntaje: llena = cuota alcanzada.
func _barra_progreso(fraccion: float, cumplida: bool) -> Control:
	var barra := Control.new()
	barra.custom_minimum_size = Vector2(0.0, 22.0)
	var fondo := ColorRect.new()
	fondo.color = Color(0.0, 0.0, 0.0, 0.55)
	barra.add_child(fondo)
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var relleno := ColorRect.new()
	relleno.color = COLOR_EXITO if cumplida else COLOR_DERROTA
	barra.add_child(relleno)
	relleno.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	relleno.anchor_right = clampf(fraccion, 0.0, 1.0)
	relleno.offset_right = 0.0
	return barra


# --- Conteos ---

func _bloque_conteos() -> Control:
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 4)
	caja.add_child(_fila_conteo("Pedidos entregados", resultado.entregados, COLOR_EXITO))
	caja.add_child(_fila_conteo("Pedidos vencidos", resultado.vencidos, COLOR_DERROTA))
	caja.add_child(_fila_conteo("Pedidos rechazados", resultado.rechazados, COLOR_DERROTA))
	caja.add_child(_fila_conteo("Platos quemados", resultado.quemados, COLOR_QUEMADO))
	var panel := PanelContainer.new()
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.0, 0.0, 0.0, 0.3)
	estilo.set_corner_radius_all(12)
	estilo.set_content_margin_all(18.0)
	panel.add_theme_stylebox_override("panel", estilo)
	panel.add_child(caja)
	return panel


func _fila_conteo(texto: String, valor: int, color: Color) -> Control:
	var fila := HBoxContainer.new()
	var nombre := _etiqueta(texto, 28, HORIZONTAL_ALIGNMENT_LEFT, TemaUI.CREMA)
	nombre.autowrap_mode = TextServer.AUTOWRAP_OFF
	nombre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_child(nombre)
	var cantidad := _etiqueta(str(valor), 30, HORIZONTAL_ALIGNMENT_RIGHT, color if valor > 0 else COLOR_TEXTO_SUAVE)
	cantidad.autowrap_mode = TextServer.AUTOWRAP_OFF
	fila.add_child(cantidad)
	return fila


# --- Entrada nueva o dato curioso ---

func _bloque_destacado() -> Control:
	var titulo := ""
	var texto := ""
	if not resultado.entradas_nuevas.is_empty():
		titulo = "Nueva entrada desbloqueada"
		texto = resultado.entradas_nuevas[0].nombre
	elif resultado.dato_curioso != "":
		titulo = "Dato curioso"
		texto = resultado.dato_curioso
	else:
		return null
	var panel := PanelContainer.new()
	var estilo := TemaUI.caja(TemaUI.MADERA_OSCURA, TemaUI.CONTORNO, 4)
	estilo.set_content_margin_all(14.0)
	panel.add_theme_stylebox_override("panel", estilo)
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 4)
	caja.add_child(_etiqueta(titulo, 22, HORIZONTAL_ALIGNMENT_CENTER, TemaUI.MAIZ))
	caja.add_child(_etiqueta(texto, 26, HORIZONTAL_ALIGNMENT_CENTER, TemaUI.CREMA))
	panel.add_child(caja)
	return panel


# --- Botones ---

func _botones(cumplida: bool) -> Control:
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 20)
	var reintentar := _boton("Reintentar", func() -> void: reintentar_solicitado.emit())
	var continuar := _boton("Continuar", func() -> void: continuar_solicitado.emit())
	var menu := _boton("Volver al menú", func() -> void: menu_solicitado.emit())
	var botones: Array[Button] = [reintentar, continuar, menu]
	for boton in botones:
		boton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fila.add_child(boton)
	_boton_foco = reintentar if not cumplida else continuar
	return fila