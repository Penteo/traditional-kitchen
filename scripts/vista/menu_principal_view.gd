class_name MenuPrincipalView
extends Pantalla
## Menu principal: exactamente 6 botones y el aviso de prototipo academico como texto fijo.

signal jugar_solicitado
signal como_jugar_solicitado
signal codice_solicitado
signal opciones_solicitado
signal creditos_solicitado
signal salir_solicitado

const AVISO: String = "Este videojuego es un prototipo académico estudiantil. No es un producto oficial ni está respaldado por la institución."


func _construir() -> void:
	_fondo()
	var columna := _columna(520.0)
	columna.add_child(_etiqueta("Traditional Kitchen", 72))
	columna.add_child(_separador(24.0))
	columna.add_child(_boton("Jugar", func() -> void: jugar_solicitado.emit()))
	columna.add_child(_boton("Cómo jugar", func() -> void: como_jugar_solicitado.emit()))
	columna.add_child(_boton("Códice", func() -> void: codice_solicitado.emit()))
	columna.add_child(_boton("Opciones", func() -> void: opciones_solicitado.emit()))
	columna.add_child(_boton("Créditos", func() -> void: creditos_solicitado.emit()))
	columna.add_child(_boton("Salir", func() -> void: salir_solicitado.emit()))

	var aviso := _etiqueta(AVISO, 18, HORIZONTAL_ALIGNMENT_CENTER, COLOR_TEXTO_SUAVE)
	add_child(aviso)
	aviso.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	aviso.offset_left = 120.0
	aviso.offset_right = -120.0
	aviso.offset_top = -70.0
	aviso.offset_bottom = -16.0
