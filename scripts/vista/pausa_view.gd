class_name PausaView
extends Pantalla
## Menu de pausa: Continuar, Reiniciar, Opciones y Salir.

signal continuar_solicitado
signal reiniciar_solicitado
signal opciones_solicitado
signal salir_solicitado


func _construir() -> void:
	var velo := ColorRect.new()
	velo.color = Color(0.0, 0.0, 0.0, 0.65)
	add_child(velo)
	velo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var columna := _columna(480.0)
	columna.add_child(_etiqueta("Pausa", 64))
	columna.add_child(_separador(16.0))
	columna.add_child(_boton("Continuar", func() -> void: continuar_solicitado.emit()))
	columna.add_child(_boton("Reiniciar", func() -> void: reiniciar_solicitado.emit()))
	columna.add_child(_boton("Opciones", func() -> void: opciones_solicitado.emit()))
	columna.add_child(_boton("Salir", func() -> void: salir_solicitado.emit()))
