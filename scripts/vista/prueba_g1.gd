extends Node2D
## ESCENA TEMPORAL de pruebas. No forma parte del juego: se excluye antes de la entrega.

const ACCIONES_J1: Array[String] = ["j1_arriba", "j1_abajo", "j1_izquierda", "j1_derecha", "j1_interactuar", "j1_procesar"]
const ACCIONES_J2: Array[String] = ["j2_arriba", "j2_abajo", "j2_izquierda", "j2_derecha", "j2_interactuar", "j2_procesar"]
const RUTAS_NIVELES: Array[String] = ["res://data/niveles/enrico_fermi.tres", "res://data/niveles/jlb.tres"]
const ARCHIVO_PROGRESO: String = "user://progreso.json"

static var nivel_elegido: int = 0

@onready var _estado: Label = $Estado
@onready var _chef1: Chef = $Chef1
@onready var _chef2: Chef = $Chef2
@onready var _controlador: ChefController = $ChefController

var _sesion: GameSession
var _cuenta: int = 0
var _mensaje: String = ""


func _ready() -> void:
	_estado.add_theme_font_size_override("font_size", 20)
	var dispensador := (load("res://scenes/entities/estaciones/dispensador_platos.tscn") as PackedScene).instantiate() as DispensadorPlatos
	dispensador.position = Vector2(1480, 200)
	add_child(dispensador)
	var barra := (load("res://scenes/entities/estaciones/barra_entrega.tscn") as PackedScene).instantiate() as BarraEntrega
	barra.position = Vector2(1480, 380)
	add_child(barra)

	var estaciones: Array[Estacion] = []
	for nodo in get_children():
		if nodo is Estacion:
			estaciones.append(nodo as Estacion)

	var nivel := load(RUTAS_NIVELES[nivel_elegido]) as Nivel
	_controlador.ciclo_terminado.connect(GameController.actualizar)
	_sesion = GameController.iniciar_partida(nivel, estaciones, true)
	_sesion.estado_cambiado.connect(_actualizar_controles)
	_sesion.pausa_cambiada.connect(_actualizar_controles)
	_sesion.cuenta_atras_cambiada.connect(_al_cambiar_cuenta)
	_actualizar_controles(null)


func _actualizar_controles(_valor) -> void:
	_controlador.habilitado = _sesion.estado == GameSession.Estado.SERVICIO and not _sesion.pausada


func _al_cambiar_cuenta(valor: int) -> void:
	_cuenta = valor


func _process(_delta: float) -> void:
	var s := _sesion
	var texto := "J1: %s\nJ2: %s\n" % [_pulsadas(ACCIONES_J1), _pulsadas(ACCIONES_J2)]
	texto += "Nivel %s | %s%s | Tiempo %.1f s | Puntos %d / cuota %d\n" % [s.nivel.nombre, GameSession.Estado.keys()[s.estado], " (PAUSA)" if s.pausada else "", s.tiempo_restante, s.puntuacion.puntos, s.nivel.cuota]
	if s.estado == GameSession.Estado.BRIEFING:
		texto += "FICHA: \"%s\" (Enter para omitir)\n" % s.nivel.frase_antagonista
	elif s.estado == GameSession.Estado.CUENTA_ATRAS:
		texto += "CUENTA ATRAS: %d\n" % _cuenta
	texto += "Pedidos activos (%d/%d), en espera %d:\n" % [s.gestor_pedidos.activos.size(), s.nivel.cupo_pedidos, s.gestor_pedidos.en_espera.size()]
	for pedido in s.gestor_pedidos.activos:
		texto += "  #%d %s  %.1f s\n" % [pedido.numero, pedido.receta.nombre, pedido.tiempo_restante]
	texto += "Entregados %d | Vencidos %d | Rechazados %d | Quemados %d\n" % [s.resultado.entregados, s.resultado.vencidos, s.resultado.rechazados, s.resultado.quemados]

	var p := GameController.obtener_progreso()
	texto += "PROGRESO: nivel desbloqueado hasta %d | estrellas F:%d J:%d | mejor F:%d J:%d | volumen musica %.1f sfx %.1f\n" % [p.nivel_desbloqueado, p.estrellas_de(1), p.estrellas_de(2), p.mejor_puntaje_de(1), p.mejor_puntaje_de(2), p.volumen_musica, p.volumen_sfx]
	var c := GameController.obtener_codice()
	var nombres := PackedStringArray()
	for entrada in c.entradas:
		nombres.append(c.nombre_visible(entrada))
	texto += "CODICE: " + " | ".join(nombres) + "\n"

	if s.estado == GameSession.Estado.RESULTADOS:
		texto += "RESULTADO: %s | %d estrellas | mas entregado: %s\n" % ["CUOTA CUMPLIDA" if s.resultado.cuota_cumplida else "ORDEN DE EXPULSION", s.resultado.estrellas, s.resultado.plato_mas_entregado]
		if not s.resultado.entradas_nuevas.is_empty():
			texto += "Nueva entrada desbloqueada: %s\n" % s.resultado.entradas_nuevas[0].nombre
		elif s.resultado.dato_curioso != "":
			texto += "Dato curioso: %s\n" % s.resultado.dato_curioso
	if _mensaje != "":
		texto += _mensaje + "\n"
	texto += "[Esc/P pausa] [1/2 nivel] [T R3] [U umbrales y textos] [Y ultimos 5 s] [N +500 puntos] [B borrar progreso] [D danar archivo] [O volumen] [K/M audio]"
	_estado.text = texto


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("pausar"):
		if _sesion.pausada:
			GameController.reanudar()
		else:
			GameController.pausar()
		return
	if evento.is_action_pressed("ui_accept"):
		_sesion.omitir_briefing()
		return
	var tecla := evento as InputEventKey
	if tecla == null or not tecla.pressed or tecla.echo:
		return
	match tecla.keycode:
		KEY_T:
			var pedidos: Array[Dictionary] = [
				{"chef": _chef1, "accion": ChefController.Accion.INTERACTUAR},
				{"chef": _chef2, "accion": ChefController.Accion.INTERACTUAR},
			]
			_controlador.resolver_acciones(pedidos)
		KEY_1:
			_cambiar_nivel(0)
		KEY_2:
			if GameController.nivel_esta_desbloqueado(2):
				_cambiar_nivel(1)
			else:
				_mensaje = "JLB BLOQUEADO: necesitas al menos 1 estrella en Enrico Fermi"
		KEY_U:
			_probar_umbrales()
		KEY_Y:
			_sesion.tiempo_restante = minf(_sesion.tiempo_restante, 5.0)
		KEY_N:
			_sesion.puntuacion.puntos = 500
		KEY_B:
			DirAccess.remove_absolute(ProjectSettings.globalize_path(ARCHIVO_PROGRESO))
			_recargar_progreso("Progreso borrado: se cargo un progreso vacio")
		KEY_D:
			var archivo := FileAccess.open(ARCHIVO_PROGRESO, FileAccess.WRITE)
			if archivo != null:
				archivo.store_string("{{{ esto no es json")
			_recargar_progreso("Archivo danado: se cargo un progreso vacio sin cerrarse")
		KEY_O:
			var actual := GameController.obtener_progreso().volumen_musica
			GameController.ajustar_volumen_musica(0.5 if actual > 0.75 else 1.0)
		KEY_K:
			AudioController.reproducir_pista("partida")
		KEY_M:
			AudioController.reproducir_sfx("boton_menu")


func _recargar_progreso(mensaje: String) -> void:
	GameController.progreso = null
	GameController.asegurar_inicializado()
	_mensaje = mensaje


func _cambiar_nivel(indice: int) -> void:
	nivel_elegido = indice
	get_tree().reload_current_scene()


## Escribe en la pestana Salida la verificacion de umbrales (OB-2), formulas y textos del Codice (AC-CU-1).
func _probar_umbrales() -> void:
	var casos := [
		[250, 249, 0], [250, 250, 1], [250, 349, 1], [250, 350, 2], [250, 449, 2], [250, 450, 3],
		[450, 449, 0], [450, 450, 1], [450, 629, 1], [450, 630, 2], [450, 809, 2], [450, 810, 3],
	]
	var p := Puntuacion.new()
	for caso in casos:
		p.puntos = caso[1]
		var obtenido := p.estrellas(caso[0])
		print("cuota %d, puntos %d -> %d estrellas (esperado %d) %s" % [caso[0], caso[1], obtenido, caso[2], "OK" if obtenido == caso[2] else "FALLA"])
	print("propina base 100 con la mitad del tiempo: %s (esperado 25.0)" % p.propina(100, 0.5, 1.0))
	print("redondeo 12.5 -> %d (esperado 13) | -12.5 -> %d (esperado -12)" % [Puntuacion.redondear(12.5), Puntuacion.redondear(-12.5)])
	for entrada in GameController.obtener_codice().entradas:
		print("Codice %s: %d palabras (maximo 60) %s" % [entrada.nombre, entrada.cantidad_palabras(), "OK" if entrada.cantidad_palabras() <= 60 else "FALLA"])
	for ruta in RUTAS_NIVELES:
		var nivel := load(ruta) as Nivel
		var palabras := nivel.frase_antagonista.split(" ", false).size()
		print("Frase %s: %d palabras (maximo 20) %s" % [nivel.nombre, palabras, "OK" if palabras <= 20 else "FALLA"])
	var antagonista := load("res://data/antagonista.tres") as DatosAntagonista
	print("Antagonista: %s" % antagonista.nombre)


func _pulsadas(acciones: Array[String]) -> String:
	var lista := PackedStringArray()
	for accion in acciones:
		if Input.is_action_pressed(accion):
			lista.append(accion.substr(3))
	return ", ".join(lista)
