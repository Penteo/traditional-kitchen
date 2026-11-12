class_name EscenaCocinaView
extends Node2D
## Arma la cocina de un nivel, conecta chefs, estaciones, HUD y sesion, y maneja la pausa y los resultados.

signal salir_solicitado
signal continuar_solicitado

const ESCENAS_NIVEL: Array[String] = [
	"res://scenes/game/niveles/enrico_fermi.tscn",
	"res://scenes/game/niveles/jlb.tscn",
]
const ESCENA_CHEF: String = "res://scenes/entities/chef.tscn"
const ESCENA_HUD: String = "res://scenes/ui/hud.tscn"
const ESCENA_PAUSA: String = "res://scenes/ui/pausa.tscn"
const ESCENA_RESULTADOS: String = "res://scenes/ui/resultados.tscn"
const ESCENA_OPCIONES: String = "res://scenes/ui/opciones.tscn"
const COLORES_CHEF: Array[Color] = [Color(0.2, 0.4, 1.0), Color(1.0, 0.2, 0.2)]

var nivel: Nivel = null

var _capa_ui: CanvasLayer
var _nivel_escena: Node2D = null
var _chefs: Array[Chef] = []
var _controlador: ChefController = null
var _hud: HUDView = null
var _pausa: PausaView = null
var _opciones: Pantalla = null
var _resultados: ResultadosView = null
var _sesion: GameSession = null
var _efectos: EfectosVisuales = null


## MenuController entrega el nivel antes de anadir la escena al arbol.
func preparar(datos: Dictionary) -> void:
	nivel = datos.get("nivel") as Nivel


func _ready() -> void:
	if nivel == null:
		nivel = Nivel.cargar(1)
	_capa_ui = CanvasLayer.new()
	_capa_ui.layer = 10
	add_child(_capa_ui)
	GameController.partida_terminada.connect(_mostrar_resultados)
	AudioController.reproducir_pista("partida")
	_construir_partida()


func _exit_tree() -> void:
	if is_instance_valid(GameController) and GameController.partida_terminada.is_connected(_mostrar_resultados):
		GameController.partida_terminada.disconnect(_mostrar_resultados)


## Construye (o reconstruye, al reiniciar) todo el nivel desde cero: estaciones vacias, sin ficha, con cuenta atras.
func _construir_partida() -> void:
	_limpiar()
	_nivel_escena = (load(ESCENAS_NIVEL[nivel.numero - 1]) as PackedScene).instantiate() as Node2D
	add_child(_nivel_escena)
	DecoradoNivel.aplicar(_nivel_escena, nivel.numero)
	var estaciones: Array[Estacion] = []
	for hijo in _nivel_escena.get_children():
		if hijo is Estacion:
			estaciones.append(hijo as Estacion)

	var escena_chef := load(ESCENA_CHEF) as PackedScene
	for numero in [1, 2]:
		var chef := escena_chef.instantiate() as Chef
		chef.numero_jugador = numero
		chef.color = COLORES_CHEF[numero - 1]
		chef.position = (_nivel_escena.get_node("SpawnJ%d" % numero) as Marker2D).position
		add_child(chef)
		_chefs.append(chef)

	_controlador = ChefController.new()
	_controlador.habilitado = false
	add_child(_controlador)

	_sesion = GameController.iniciar_partida(nivel, estaciones, false)
	_controlador.ciclo_terminado.connect(GameController.actualizar)

	_hud = (load(ESCENA_HUD) as PackedScene).instantiate() as HUDView
	_capa_ui.add_child(_hud)
	_hud.vincular(_sesion, _chefs)

	_sesion.estado_cambiado.connect(_actualizar_controles)
	_sesion.pausa_cambiada.connect(_actualizar_controles)
	_conectar_audio(estaciones)
	_efectos = EfectosVisuales.new()
	add_child(_efectos)
	_efectos.vincular(_sesion, estaciones)
	_actualizar_controles(null)


func _limpiar() -> void:
	for chef in _chefs:
		_quitar(chef)
	_chefs.clear()
	_quitar(_controlador)
	_quitar(_efectos)
	_quitar(_nivel_escena)
	_quitar(_hud)
	_quitar(_pausa)
	_quitar(_opciones)
	_quitar(_resultados)
	_controlador = null
	_nivel_escena = null
	_efectos = null
	_hud = null
	_pausa = null
	_opciones = null
	_resultados = null


func _quitar(nodo: Node) -> void:
	if nodo == null or not is_instance_valid(nodo):
		return
	var padre := nodo.get_parent()
	if padre != null:
		padre.remove_child(nodo)
	nodo.queue_free()


## Los controles solo estan activos durante el servicio y sin pausa.
func _actualizar_controles(_valor) -> void:
	_controlador.habilitado = _sesion.estado == GameSession.Estado.SERVICIO and not _sesion.pausada


func _unhandled_input(evento: InputEvent) -> void:
	if not evento.is_action_pressed("pausar"):
		return
	get_viewport().set_input_as_handled()
	if _opciones != null:
		_cerrar_opciones()
	elif _resultados != null:
		return
	elif _sesion.pausada:
		_reanudar()
	else:
		_pausar()


func _pausar() -> void:
	if _sesion.estado != GameSession.Estado.SERVICIO:
		return
	GameController.pausar()
	_pausa = (load(ESCENA_PAUSA) as PackedScene).instantiate() as PausaView
	_pausa.continuar_solicitado.connect(_reanudar)
	_pausa.reiniciar_solicitado.connect(_construir_partida)
	_pausa.opciones_solicitado.connect(_abrir_opciones)
	_pausa.salir_solicitado.connect(_salir)
	_capa_ui.add_child(_pausa)


func _reanudar() -> void:
	GameController.reanudar()
	_quitar(_pausa)
	_pausa = null


func _abrir_opciones() -> void:
	if _opciones != null:
		return
	_opciones = (load(ESCENA_OPCIONES) as PackedScene).instantiate() as Pantalla
	_opciones.volver_solicitado.connect(_cerrar_opciones)
	_capa_ui.add_child(_opciones)


func _cerrar_opciones() -> void:
	_quitar(_opciones)
	_opciones = null


## Salir a mitad de nivel: vuelve al menu principal sin guardar nada de esta partida.
func _salir() -> void:
	GameController.abandonar_partida()
	salir_solicitado.emit()


func _mostrar_resultados(resultado: ResultadoPartida) -> void:
	_quitar(_pausa)
	_pausa = null
	_resultados = (load(ESCENA_RESULTADOS) as PackedScene).instantiate() as ResultadosView
	_resultados.preparar({"resultado": resultado})
	_resultados.reintentar_solicitado.connect(_construir_partida)
	_resultados.continuar_solicitado.connect(func() -> void: continuar_solicitado.emit())
	_capa_ui.add_child(_resultados)


# ---------- Efectos de sonido (Tabla 23): suenan cuando existan los archivos ----------
func _conectar_audio(estaciones: Array[Estacion]) -> void:
	var gestor := _sesion.gestor_pedidos
	gestor.pedido_generado.connect(func(_p: Pedido) -> void: AudioController.reproducir_sfx("pedido_nuevo"))
	gestor.pedido_entregado.connect(func(_p: Pedido) -> void: AudioController.reproducir_sfx("entrega_aceptada"))
	gestor.pedido_vencido.connect(func(_p: Pedido) -> void: AudioController.reproducir_sfx("rechazo_vencimiento"))
	gestor.pedido_rechazado.connect(func(_p: Pedido) -> void: AudioController.reproducir_sfx("rechazo_vencimiento"))
	for estacion in estaciones:
		var coccion := estacion as EstacionCoccion
		if coccion != null:
			coccion.estado_cambiado.connect(_al_cambiar_estado_coccion)
		var tabla := estacion as TablaCortar
		if tabla != null:
			tabla.corte_iniciado.connect(func() -> void: AudioController.reproducir_sfx("picar"))
	for chef in _chefs:
		chef.item_cambiado.connect(func() -> void: AudioController.reproducir_sfx("tomar_soltar"))
	_controlador.accion_invalida.connect(func(_c: Chef) -> void: AudioController.reproducir_sfx("accion_invalida"))


func _al_cambiar_estado_coccion(nuevo: EstacionCoccion.Estado) -> void:
	match nuevo:
		EstacionCoccion.Estado.LISTO:
			AudioController.reproducir_sfx("estacion_lista")
		EstacionCoccion.Estado.PELIGRO:
			AudioController.reproducir_sfx("peligro_quemado")
		EstacionCoccion.Estado.QUEMADO:
			AudioController.reproducir_sfx("quemado")
