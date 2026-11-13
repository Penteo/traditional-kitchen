class_name CodiceView
extends Pantalla
## Codice Culinario: una entrada por plato. Las bloqueadas se muestran como "???".

const TEXTO_BLOQUEADO: String = "Entrada bloqueada. Entrega este plato por primera vez para desbloquearla."

var _codice: Codice
var _icono: ColorRect
var _titulo: Label
var _texto: Label


func _construir() -> void:
	_fondo()
	_codice = GameController.obtener_codice()
	var columna := _columna(1300.0)
	columna.add_child(_etiqueta("Códice Culinario", 56))
	var cuerpo := HBoxContainer.new()
	cuerpo.add_theme_constant_override("separation", 40)
	columna.add_child(cuerpo)

	var lista := VBoxContainer.new()
	lista.custom_minimum_size = Vector2(420.0, 0.0)
	lista.add_theme_constant_override("separation", 12)
	cuerpo.add_child(lista)
	for entrada in _codice.entradas:
		lista.add_child(_boton(_codice.nombre_visible(entrada), _seleccionar.bind(entrada)))

	var detalle := PanelContainer.new()
	detalle.custom_minimum_size = Vector2(800.0, 420.0)
	detalle.add_theme_stylebox_override("panel", _estilo_tarjeta())
	cuerpo.add_child(detalle)
	var contenido := VBoxContainer.new()
	contenido.add_theme_constant_override("separation", 14)
	detalle.add_child(contenido)
	_icono = _cuadro_color(Color.GRAY, 96.0)
	_icono.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	contenido.add_child(_icono)
	_titulo = _etiqueta("", 38)
	contenido.add_child(_titulo)
	_texto = _etiqueta("", 26, HORIZONTAL_ALIGNMENT_LEFT)
	contenido.add_child(_texto)

	if not _codice.entradas.is_empty():
		_seleccionar(_codice.entradas[0])
	columna.add_child(_boton("Volver", func() -> void: volver_solicitado.emit()))


func _seleccionar(entrada: EntradaCodice) -> void:
	if _codice.esta_desbloqueada(entrada):
		_icono.color = Ingrediente.COLORES[entrada.receta.componentes[0]]
		_titulo.text = entrada.nombre
		_texto.text = "Origen: %s\nIngredientes: %s\nEn el juego: %s\nDato curioso: %s" % [entrada.origen, entrada.ingredientes, entrada.en_el_juego, entrada.dato_curioso]
	else:
		_icono.color = Color(0.3, 0.3, 0.35)
		_titulo.text = Codice.TEXTO_BLOQUEADO
		_texto.text = TEXTO_BLOQUEADO
