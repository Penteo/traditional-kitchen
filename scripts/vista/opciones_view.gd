class_name OpcionesView
extends Pantalla
## Volumen de la musica y de los efectos. Los valores se guardan al cambiarlos.


func _construir() -> void:
	_fondo()
	var progreso := GameController.obtener_progreso()
	var columna := _columna(700.0)
	columna.add_child(_etiqueta("Opciones", 56))
	columna.add_child(_separador(16.0))
	columna.add_child(_fila_volumen("Volumen de la música", progreso.volumen_musica, GameController.ajustar_volumen_musica))
	columna.add_child(_fila_volumen("Volumen de los efectos (SFX)", progreso.volumen_sfx, GameController.ajustar_volumen_sfx))
	columna.add_child(_separador(16.0))
	columna.add_child(_boton("Volver", func() -> void: volver_solicitado.emit()))


func _fila_volumen(titulo: String, inicial: float, al_cambiar: Callable) -> VBoxContainer:
	var fila := VBoxContainer.new()
	fila.add_theme_constant_override("separation", 8)
	var etiqueta := _etiqueta("%s: %d %%" % [titulo, roundi(inicial * 100.0)], 28, HORIZONTAL_ALIGNMENT_LEFT)
	fila.add_child(etiqueta)
	var control := HSlider.new()
	control.min_value = 0.0
	control.max_value = 1.0
	control.step = 0.05
	control.value = inicial
	control.custom_minimum_size = Vector2(0.0, 40.0)
	fila.add_child(control)
	control.value_changed.connect(_al_mover.bind(titulo, etiqueta, al_cambiar))
	return fila


func _al_mover(valor: float, titulo: String, etiqueta: Label, al_cambiar: Callable) -> void:
	etiqueta.text = "%s: %d %%" % [titulo, roundi(valor * 100.0)]
	al_cambiar.call(valor)
