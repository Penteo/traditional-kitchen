class_name SeleccionNivelView
extends Pantalla
## Una tarjeta por nivel con su cuota, las estrellas obtenidas y su estado de bloqueo.

signal nivel_elegido(numero: int)


func _construir() -> void:
	_fondo()
	var progreso := GameController.obtener_progreso()
	var columna := _columna(1100.0)
	columna.add_child(_etiqueta("Selección de nivel", 56))
	var fila := HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override("separation", 48)
	columna.add_child(fila)
	for numero in range(1, Nivel.total() + 1):
		fila.add_child(_tarjeta(Nivel.cargar(numero), progreso))
	columna.add_child(_boton("Volver", func() -> void: volver_solicitado.emit()))


func _tarjeta(nivel: Nivel, progreso: ProgresoJugador) -> PanelContainer:
	var desbloqueado := progreso.esta_desbloqueado(nivel.numero)
	var tarjeta := PanelContainer.new()
	tarjeta.custom_minimum_size = Vector2(480.0, 400.0)
	tarjeta.add_theme_stylebox_override("panel", _estilo_tarjeta())
	var contenido := VBoxContainer.new()
	contenido.add_theme_constant_override("separation", 14)
	tarjeta.add_child(contenido)
	contenido.add_child(_etiqueta(nivel.nombre, 42))
	contenido.add_child(_etiqueta("Cuota: %d puntos" % nivel.cuota, 28))
	contenido.add_child(_etiqueta("Estrellas: %d de 3" % progreso.estrellas_de(nivel.numero), 28))
	var texto_estado := "Disponible" if desbloqueado else "Bloqueado: necesitas al menos 1 estrella en el nivel anterior"
	var color_estado := Color(0.6, 0.9, 0.6) if desbloqueado else Color(1.0, 0.6, 0.5)
	contenido.add_child(_etiqueta(texto_estado, 22, HORIZONTAL_ALIGNMENT_CENTER, color_estado))
	var relleno := Control.new()
	relleno.size_flags_vertical = Control.SIZE_EXPAND_FILL
	contenido.add_child(relleno)
	var boton := _boton("Jugar", _elegir.bind(nivel.numero))
	boton.disabled = not desbloqueado
	contenido.add_child(boton)
	return tarjeta


func _elegir(numero: int) -> void:
	nivel_elegido.emit(numero)
