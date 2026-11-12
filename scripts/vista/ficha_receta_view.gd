class_name FichaRecetaView
extends Pantalla
## Ficha previa al nivel: dura como maximo 5 s y se omite al instante con cualquier tecla (menos Esc).

signal ficha_terminada

const DURACION: float = 5.0

var nivel: Nivel = null

var _terminada: bool = false


func preparar(datos: Dictionary) -> void:
	nivel = datos.get("nivel") as Nivel


func _construir() -> void:
	_fondo()
	if nivel == null:
		nivel = Nivel.cargar(1)
	var antagonista := load("res://data/antagonista.tres") as DatosAntagonista
	var columna := _columna(1100.0)
	columna.add_child(_etiqueta("Ficha de receta: %s" % nivel.nombre, 48))
	for receta in nivel.recetas_disponibles():
		columna.add_child(_fila_receta(receta))
	columna.add_child(_etiqueta("Pedidos del nivel: %d   |   Cuota: %d puntos" % [nivel.secuencia_pedidos.size(), nivel.cuota], 28))
	columna.add_child(_separador(8.0))
	columna.add_child(_etiqueta("%s: «%s»" % [antagonista.nombre, nivel.frase_antagonista], 28, HORIZONTAL_ALIGNMENT_CENTER, Color(1.0, 0.85, 0.5)))
	columna.add_child(_etiqueta("Pulsa cualquier tecla para continuar", 20, HORIZONTAL_ALIGNMENT_CENTER, COLOR_TEXTO_SUAVE))
	get_tree().create_timer(DURACION).timeout.connect(_terminar)


func _fila_receta(receta: Receta) -> PanelContainer:
	var tarjeta := PanelContainer.new()
	tarjeta.add_theme_stylebox_override("panel", _estilo_tarjeta())
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 24)
	tarjeta.add_child(fila)
	var iconos := _iconos_receta(receta, 72.0)
	iconos.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	fila.add_child(iconos)
	var datos := VBoxContainer.new()
	datos.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_child(datos)
	datos.add_child(_etiqueta(receta.nombre, 34, HORIZONTAL_ALIGNMENT_LEFT))
	datos.add_child(_etiqueta("Composición: " + _composicion(receta), 24, HORIZONTAL_ALIGNMENT_LEFT))
	datos.add_child(_etiqueta("Región: " + receta.region, 24, HORIZONTAL_ALIGNMENT_LEFT, COLOR_TEXTO_SUAVE))
	return tarjeta


func _composicion(receta: Receta) -> String:
	var partes := PackedStringArray()
	for i in receta.componentes.size():
		partes.append("%s (%s)" % [Ingrediente.NOMBRES[receta.componentes[i]], Ingrediente.ESTADOS[receta.estados_componentes[i]]])
	var texto := " + ".join(partes)
	if receta.unidades_por_pedido > 1:
		texto += " (x%d)" % receta.unidades_por_pedido
	return texto


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("ui_cancel"):
		return
	var tecla := evento as InputEventKey
	var raton := evento as InputEventMouseButton
	if (tecla != null and tecla.pressed and not tecla.echo) or (raton != null and raton.pressed):
		get_viewport().set_input_as_handled()
		_terminar()


func _terminar() -> void:
	if _terminada:
		return
	_terminada = true
	ficha_terminada.emit()
