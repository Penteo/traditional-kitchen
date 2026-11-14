class_name ComoJugarView
extends Pantalla
## Controles de ambos jugadores y objetivo. No hay tutorial interactivo ni reasignacion de teclas.


func _construir() -> void:
	_fondo()
	var columna := _columna(1200.0)
	columna.add_child(_etiqueta("Cómo jugar", 56))
	columna.add_child(_etiqueta("Objetivo: prepara y entrega los pedidos antes de que se acabe el tiempo. Si alcanzas la cuota de puntos del nivel, aseguras tu permanencia en la universidad.", 26))
	var fila := HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override("separation", 48)
	columna.add_child(fila)
	fila.add_child(_panel_jugador("Jugador 1 (azul)", Color(0.45, 0.65, 1.0), ["Moverse: W, A, S, D", "Interactuar: F", "Procesar: G"]))
	fila.add_child(_panel_jugador("Jugador 2 (rojo)", Color(1.0, 0.5, 0.5), ["Moverse: flechas", "Interactuar: " + _nombre_tecla("j2_interactuar"), "Procesar: " + _nombre_tecla("j2_procesar")]))
	columna.add_child(_etiqueta("Interactuar: recoger, depositar, retirar y entregar. Procesar: cortar en la tabla.", 24, HORIZONTAL_ALIGNMENT_CENTER, COLOR_TEXTO_SUAVE))
	columna.add_child(_etiqueta("Pausa: Esc o P", 26))
	columna.add_child(_boton("Volver", func() -> void: volver_solicitado.emit()))


func _panel_jugador(titulo: String, color: Color, lineas: Array[String]) -> PanelContainer:
	var tarjeta := PanelContainer.new()
	tarjeta.custom_minimum_size = Vector2(520.0, 0.0)
	tarjeta.add_theme_stylebox_override("panel", _estilo_tarjeta())
	var contenido := VBoxContainer.new()
	contenido.add_theme_constant_override("separation", 12)
	tarjeta.add_child(contenido)
	contenido.add_child(_etiqueta(titulo, 36, HORIZONTAL_ALIGNMENT_CENTER, color))
	for linea in lineas:
		contenido.add_child(_etiqueta(linea, 28, HORIZONTAL_ALIGNMENT_LEFT))
	return tarjeta


## Nombre de la tecla segun la distribucion del teclado de quien juega (la tecla fisica de "/" en un
## teclado US esta rotulada "-" en uno latinoamericano). Sin pantalla real se usa la posicion fisica.
func _nombre_tecla(accion: String) -> String:
	for evento in InputMap.action_get_events(accion):
		var tecla := evento as InputEventKey
		if tecla == null:
			continue
		var codigo: int = tecla.physical_keycode
		if DisplayServer.get_name() != "headless":
			codigo = DisplayServer.keyboard_get_keycode_from_physical(tecla.physical_keycode)
		if codigo >= 32 and codigo <= 126:
			return String.chr(codigo)
		return OS.get_keycode_string(codigo as Key)
	return "?"
