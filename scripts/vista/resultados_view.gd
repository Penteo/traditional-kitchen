class_name ResultadosView
extends Pantalla
## Resultados del nivel: titulo, estrellas, puntaje, conteos y entrada nueva o dato curioso.

signal reintentar_solicitado
signal continuar_solicitado

var resultado: ResultadoPartida = null


func preparar(datos: Dictionary) -> void:
	resultado = datos.get("resultado") as ResultadoPartida


func _construir() -> void:
	var velo := ColorRect.new()
	velo.color = Color(0.0, 0.0, 0.0, 0.82)
	add_child(velo)
	velo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var columna := _columna(900.0)
	var cumplida := resultado.cuota_cumplida
	columna.add_child(_etiqueta("¡CUOTA CUMPLIDA!" if cumplida else "ORDEN DE EXPULSIÓN", 72, HORIZONTAL_ALIGNMENT_CENTER, Color(0.5, 1.0, 0.5) if cumplida else Color(1.0, 0.4, 0.4)))
	columna.add_child(_etiqueta("Estrellas: %d de 3" % resultado.estrellas if cumplida else "Sin estrellas", 40))
	columna.add_child(_etiqueta("Puntaje: %d   |   Cuota: %d" % [resultado.puntaje, resultado.cuota], 34))
	columna.add_child(_etiqueta("Pedidos entregados: %d\nPedidos vencidos: %d\nPedidos rechazados: %d\nPlatos quemados: %d" % [resultado.entregados, resultado.vencidos, resultado.rechazados, resultado.quemados], 28))
	if not resultado.entradas_nuevas.is_empty():
		columna.add_child(_etiqueta("Nueva entrada desbloqueada: %s" % resultado.entradas_nuevas[0].nombre, 30, HORIZONTAL_ALIGNMENT_CENTER, Color(1.0, 0.85, 0.5)))
	elif resultado.dato_curioso != "":
		columna.add_child(_etiqueta("Dato curioso: %s" % resultado.dato_curioso, 28, HORIZONTAL_ALIGNMENT_CENTER, Color(1.0, 0.85, 0.5)))
	if not cumplida:
		var antagonista := load("res://data/antagonista.tres") as DatosAntagonista
		var ficha := HBoxContainer.new()
		ficha.alignment = BoxContainer.ALIGNMENT_CENTER
		ficha.add_theme_constant_override("separation", 16)
		ficha.add_child(_cuadro_color(Color(0.4, 0.4, 0.45), 64.0))
		ficha.add_child(_etiqueta(antagonista.nombre, 28))
		columna.add_child(ficha)
	columna.add_child(_separador(8.0))
	var botones := HBoxContainer.new()
	botones.add_theme_constant_override("separation", 24)
	columna.add_child(botones)
	var reintentar := _boton("Reintentar", func() -> void: reintentar_solicitado.emit())
	reintentar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	botones.add_child(reintentar)
	var continuar := _boton("Continuar", func() -> void: continuar_solicitado.emit())
	continuar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	botones.add_child(continuar)
	continuar.grab_focus()
