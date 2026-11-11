@tool
extends EditorScript
## Verificacion automatica de los sistemas del juego (sin interfaz).
## Como ejecutarla: abrir este script y usar Archivo > Ejecutar (Ctrl+Mayus+X). El resultado sale en la pestana Salida.
## No forma parte del juego: se excluye del build.

const RUTA_PARAMETROS: String = "res://data/estaciones/"

var _total: int = 0
var _fallos: int = 0
var _nodos: Array[Node] = []


func _run() -> void:
	print("=== Verificacion de sistemas de Traditional Kitchen ===")
	_probar_niveles()
	_probar_puntuacion()
	_probar_dispensador()
	_probar_estaciones()
	_probar_pedidos(1, [5.0, 30.0, 55.0, 80.0, 105.0, 130.0])
	_probar_pedidos(2, [5.0, 25.0, 45.0, 65.0, 85.0, 105.0, 125.0, 145.0, 165.0])
	_probar_sesion()
	_probar_codice_y_progreso()
	for nodo in _nodos:
		nodo.free()
	print("=== %d comprobaciones, %d fallos ===" % [_total, _fallos])


func _ok(condicion: bool, descripcion: String) -> void:
	_total += 1
	if not condicion:
		_fallos += 1
	print("%s %s" % ["OK   " if condicion else "FALLA", descripcion])


func _receta(archivo: String) -> Receta:
	return load("res://data/recetas/%s.tres" % archivo) as Receta


func _ing(tipo: Ingrediente.Tipo, estado: Ingrediente.Estado) -> Ingrediente:
	return Ingrediente.new(tipo, estado)


func _avanzar(estacion: Estacion, segundos: float) -> void:
	for i in roundi(segundos / 0.1):
		estacion.actualizar(0.1)


func _avanzar_sesion(sesion: GameSession, segundos: float) -> void:
	for i in roundi(segundos / 0.05):
		sesion.actualizar(0.05)


func _arepa_armada() -> Plato:
	var plato := Plato.new()
	plato.agregar(_ing(Ingrediente.Tipo.MASA, Ingrediente.Estado.COCIDO))
	plato.agregar(_ing(Ingrediente.Tipo.QUESO, Ingrediente.Estado.PICADO))
	return plato


# ---------- Niveles (Tabla 18) ----------
func _probar_niveles() -> void:
	var fermi := Nivel.cargar(1)
	var jlb := Nivel.cargar(2)
	_ok(fermi.duracion == 180.0 and fermi.cuota == 250 and fermi.cupo_pedidos == 3, "Fermi: 180 s, cuota 250, cupo 3")
	_ok(fermi.secuencia_pedidos.size() == 6 and fermi.suma_valores_base() == 360, "Fermi: 6 pedidos con suma de bases 360")
	_ok(jlb.duracion == 210.0 and jlb.cuota == 450 and jlb.cupo_pedidos == 4, "JLB: 210 s, cuota 450, cupo 4")
	_ok(jlb.secuencia_pedidos.size() == 9 and jlb.suma_valores_base() == 650, "JLB: 9 pedidos con suma de bases 650")


# ---------- Puntuacion (Tabla 19) y estrellas ----------
func _probar_puntuacion() -> void:
	var p := Puntuacion.new()
	_ok(p.propina(100, 0.5, 1.0) == 25.0, "Propina: base 100 con la mitad del tiempo = 25 (total 125)")
	var pedido := Pedido.new(_receta("arepa_con_queso"), 1)
	pedido.tiempo_restante = 30.0
	_ok(p.registrar_entrega(pedido) == 63 and p.puntos == 63, "Entrega: 50 + propina 12,5 = 62,5 redondea a 63")
	_ok(p.registrar_vencido(pedido) == -25 and p.puntos == 38, "Vencido: resta el 50 % de la base (-25)")
	_ok(p.registrar_rechazo(pedido) == -12 and p.puntos == 26, "Rechazo: -12,5 redondea hacia el valor mayor (-12)")
	p.puntos = 5
	p.registrar_vencido(Pedido.new(_receta("mute_santandereano"), 2))
	_ok(p.puntos == 0, "El puntaje nunca baja de 0")
	var casos := [
		[250, 249, 0], [250, 250, 1], [250, 349, 1], [250, 350, 2], [250, 449, 2], [250, 450, 3],
		[450, 449, 0], [450, 450, 1], [450, 629, 1], [450, 630, 2], [450, 809, 2], [450, 810, 3],
	]
	var todos := true
	for caso in casos:
		p.puntos = caso[1]
		if p.estrellas(caso[0]) != caso[2]:
			todos = false
	_ok(todos, "Estrellas: los 12 umbrales de Fermi y JLB (OB-2)")


# ---------- Receta, plato y dispensador ----------
func _probar_dispensador() -> void:
	var recetas: Array[Receta] = [_receta("arepa_con_queso"), _receta("empanadas"), _receta("mute_santandereano")]
	var d := DispensadorPlatos.new()
	_nodos.append(d)
	d.recetas = recetas
	_ok(not d.acepta(_ing(Ingrediente.Tipo.MASA, Ingrediente.Estado.CRUDO)), "Dispensador rechaza ingredientes crudos")
	_ok(not d.acepta(_ing(Ingrediente.Tipo.MASA, Ingrediente.Estado.QUEMADO)), "Dispensador rechaza ingredientes quemados")
	_ok(not d.acepta(Item.new()), "Dispensador rechaza lo que no es un ingrediente")
	d.recibir(_ing(Ingrediente.Tipo.QUESO, Ingrediente.Estado.PICADO))
	_ok(not d.puede_entregar(), "Arepa: con solo el queso el plato no esta completo")
	d.recibir(_ing(Ingrediente.Tipo.MASA, Ingrediente.Estado.COCIDO))
	_ok(d.puede_entregar() and d.receta_completada() == recetas[0], "Arepa: completa sin importar el orden de armado")
	var plato := d.retirar_plato()
	_ok(plato != null and plato.coincide(recetas[0]) and d.plato_en_armado == null, "Se retira el plato y el dispensador queda libre")
	d.recibir(_ing(Ingrediente.Tipo.EMPANADA, Ingrediente.Estado.COCIDO))
	_ok(not d.puede_entregar(), "Empanadas: con una sola no esta completo")
	_ok(not d.acepta(_ing(Ingrediente.Tipo.MASA, Ingrediente.Estado.COCIDO)), "Mezcla: no acepta un ingrediente de otra receta")
	d.recibir(_ing(Ingrediente.Tipo.EMPANADA, Ingrediente.Estado.COCIDO))
	_ok(d.puede_entregar() and d.receta_completada() == recetas[1], "Empanadas: completo con 2 unidades")
	_ok(not d.acepta(_ing(Ingrediente.Tipo.EMPANADA, Ingrediente.Estado.COCIDO)), "Empanadas: rechaza una tercera")
	d.retirar_plato()
	d.recibir(_ing(Ingrediente.Tipo.MUTE, Ingrediente.Estado.COCIDO))
	_ok(d.receta_completada() == recetas[2], "Mute: un solo mute cocido completa la receta")


# ---------- Estaciones: tiempos de la Tabla 15 ----------
func _probar_estaciones() -> void:
	var surtidor := Surtidor.new()
	_nodos.append(surtidor)
	surtidor.tipo = Ingrediente.Tipo.QUESO
	surtidor._ready()
	var a := surtidor.retirar() as Ingrediente
	var b := surtidor.retirar() as Ingrediente
	_ok(a != b and a.tipo == Ingrediente.Tipo.QUESO and a.estado == Ingrediente.Estado.CRUDO, "Surtidor: entrega ingredientes crudos sin limite")
	_ok(not surtidor.acepta(a), "Surtidor: no recibe ítems")

	var cesto := CestoBasura.new()
	_nodos.append(cesto)
	_ok(cesto.acepta(a) and cesto.acepta(_arepa_armada()), "Cesto: acepta cualquier ítem")

	var tabla := TablaCortar.new()
	_nodos.append(tabla)
	tabla.parametros = load(RUTA_PARAMETROS + "parametros_tabla.tres") as ParametrosTabla
	tabla._ready()
	var queso := _ing(Ingrediente.Tipo.QUESO, Ingrediente.Estado.CRUDO)
	_ok(tabla.acepta(queso) and not tabla.acepta(_ing(Ingrediente.Tipo.MASA, Ingrediente.Estado.CRUDO)), "Tabla: acepta queso crudo y rechaza masa")
	tabla.recibir(queso)
	tabla.procesar()
	_avanzar(tabla, 1.8)
	_ok(queso.estado == Ingrediente.Estado.CRUDO, "Tabla: el queso sigue crudo a los 1,8 s")
	_avanzar(tabla, 0.4)
	_ok(queso.estado == Ingrediente.Estado.PICADO, "Tabla: el queso queda picado a los 2 s")
	var papa := _ing(Ingrediente.Tipo.PAPA, Ingrediente.Estado.CRUDO)
	tabla.retirar()
	tabla.recibir(papa)
	tabla.procesar()
	_avanzar(tabla, 2.8)
	_ok(papa.estado == Ingrediente.Estado.CRUDO, "Tabla: la papa sigue cruda a los 2,8 s")
	_avanzar(tabla, 0.4)
	_ok(papa.estado == Ingrediente.Estado.PICADO, "Tabla: la papa queda picada a los 3 s")
	var carne := _ing(Ingrediente.Tipo.CARNE, Ingrediente.Estado.CRUDO)
	tabla.retirar()
	tabla.recibir(carne)
	tabla.procesar()
	_avanzar(tabla, 4.8)
	_ok(carne.estado == Ingrediente.Estado.CRUDO, "Tabla: la carne sigue cruda a los 4,8 s")
	_avanzar(tabla, 0.4)
	_ok(carne.estado == Ingrediente.Estado.PICADO, "Tabla: la carne queda picada a los 5 s")
	tabla.retirar()
	var queso2 := _ing(Ingrediente.Tipo.QUESO, Ingrediente.Estado.CRUDO)
	tabla.recibir(queso2)
	tabla.procesar()
	_avanzar(tabla, 1.0)
	var devuelto := tabla.retirar() as Ingrediente
	_ok(devuelto.estado == Ingrediente.Estado.CRUDO and not tabla.cortando, "Tabla: retirar a mitad de corte devuelve el ítem crudo")

	var plancha := _coccion(Plancha.new(), "parametros_plancha.tres")
	var masa := _ing(Ingrediente.Tipo.MASA, Ingrediente.Estado.CRUDO)
	_ok(plancha.acepta(masa) and not plancha.acepta(_ing(Ingrediente.Tipo.QUESO, Ingrediente.Estado.CRUDO)), "Plancha: acepta masa cruda y rechaza queso")
	plancha.recibir(masa)
	_avanzar(plancha, 6.9)
	_ok(plancha.estado == EstacionCoccion.Estado.PROCESANDO, "Plancha: sigue cocinando a los 6,9 s")
	_avanzar(plancha, 0.2)
	_ok(plancha.estado == EstacionCoccion.Estado.LISTO and masa.estado == Ingrediente.Estado.COCIDO, "Plancha: lista a los 7 s")
	_avanzar(plancha, 1.7)
	_ok(plancha.estado == EstacionCoccion.Estado.LISTO, "Plancha: aun sin peligro a los 1,8 s de estar lista")
	_avanzar(plancha, 0.4)
	_ok(plancha.estado == EstacionCoccion.Estado.PELIGRO, "Plancha: alerta de peligro 3 s antes de quemarse")
	_avanzar(plancha, 2.6)
	_ok(plancha.estado == EstacionCoccion.Estado.PELIGRO, "Plancha: sigue en peligro a los 4,8 s")
	_avanzar(plancha, 0.4)
	_ok(plancha.estado == EstacionCoccion.Estado.QUEMADO and masa.estado == Ingrediente.Estado.QUEMADO, "Plancha: se quema a los 5 s de estar lista")
	_ok(not plancha.acepta(_ing(Ingrediente.Tipo.MASA, Ingrediente.Estado.CRUDO)), "Plancha: ocupada, rechaza otro ítem (R2)")

	var plancha2 := _coccion(Plancha.new(), "parametros_plancha.tres")
	plancha2.recibir(_ing(Ingrediente.Tipo.MASA, Ingrediente.Estado.CRUDO))
	_avanzar(plancha2, 3.0)
	var tal_como_estaba := plancha2.retirar() as Ingrediente
	_ok(tal_como_estaba.estado == Ingrediente.Estado.CRUDO and plancha2.estado == EstacionCoccion.Estado.VACIA, "Plancha: retirar a mitad devuelve el ítem crudo")
	plancha2.recibir(tal_como_estaba)
	_avanzar(plancha2, 6.9)
	_ok(plancha2.estado == EstacionCoccion.Estado.PROCESANDO, "Plancha: el temporizador se reinicio")

	var freidora := _coccion(Freidora.new(), "parametros_freidora.tres")
	var empanada := _ing(Ingrediente.Tipo.EMPANADA, Ingrediente.Estado.CRUDO)
	freidora.recibir(empanada)
	_avanzar(freidora, 9.9)
	_ok(freidora.estado == EstacionCoccion.Estado.PROCESANDO, "Freidora: sigue a los 9,9 s")
	_avanzar(freidora, 0.2)
	_ok(freidora.estado == EstacionCoccion.Estado.LISTO, "Freidora: lista a los 10 s")
	_avanzar(freidora, 3.1)
	_ok(freidora.estado == EstacionCoccion.Estado.PELIGRO, "Freidora: peligro 3 s antes de quemarse")
	_avanzar(freidora, 3.0)
	_ok(freidora.estado == EstacionCoccion.Estado.QUEMADO, "Freidora: se quema a los 6 s de estar lista")

	var olla := _coccion(Olla.new(), "parametros_olla.tres")
	_ok(not olla.acepta(_ing(Ingrediente.Tipo.PAPA, Ingrediente.Estado.CRUDO)), "Olla: rechaza papa cruda")
	olla.recibir(_ing(Ingrediente.Tipo.PAPA, Ingrediente.Estado.PICADO))
	_ok(olla.estado == EstacionCoccion.Estado.VACIA, "Olla: con una sola papa no arranca")
	_ok(not olla.acepta(_ing(Ingrediente.Tipo.PAPA, Ingrediente.Estado.PICADO)), "Olla: no acepta dos papas (dos ranuras exclusivas)")
	olla.recibir(_ing(Ingrediente.Tipo.CARNE, Ingrediente.Estado.PICADO))
	_ok(olla.estado == EstacionCoccion.Estado.PROCESANDO, "Olla: arranca al tener papa y carne")
	_avanzar(olla, 24.9)
	_ok(olla.estado == EstacionCoccion.Estado.PROCESANDO, "Olla: sigue a los 24,9 s")
	_avanzar(olla, 0.2)
	var mute := olla.items[0] as Ingrediente
	_ok(olla.estado == EstacionCoccion.Estado.LISTO and olla.items.size() == 1 and mute.tipo == Ingrediente.Tipo.MUTE, "Olla: a los 25 s produce un solo mute")
	_avanzar(olla, 10.0)
	_ok(olla.estado == EstacionCoccion.Estado.QUEMADO, "Olla: se quema a los 10 s de estar lista")

	var olla2 := _coccion(Olla.new(), "parametros_olla.tres")
	olla2.recibir(_ing(Ingrediente.Tipo.PAPA, Ingrediente.Estado.PICADO))
	olla2.recibir(_ing(Ingrediente.Tipo.CARNE, Ingrediente.Estado.PICADO))
	_avanzar(olla2, 5.0)
	var primero := olla2.retirar() as Ingrediente
	_ok(primero.tipo == Ingrediente.Tipo.PAPA and olla2.items.size() == 1 and olla2.estado == EstacionCoccion.Estado.VACIA, "Olla: retirar a mitad devuelve el primer ingrediente y detiene la cocción")


func _coccion(estacion: EstacionCoccion, archivo: String) -> EstacionCoccion:
	_nodos.append(estacion)
	estacion.parametros = load(RUTA_PARAMETROS + archivo) as ParametrosCoccion
	estacion._ready()
	return estacion


# ---------- Pedidos: secuencia fija, cupo y vencimiento ----------
func _probar_pedidos(numero: int, esperadas: Array) -> void:
	var nivel := Nivel.cargar(numero)
	var gestor := GestorPedidos.new()
	gestor.iniciar(nivel)
	var reloj := [0.0]
	var llegadas := []
	var nombres := []
	var vencidos := []
	gestor.pedido_generado.connect(func(p: Pedido) -> void:
		llegadas.append(reloj[0])
		nombres.append(p.receta.nombre))
	gestor.pedido_vencido.connect(func(p: Pedido) -> void: vencidos.append(p.numero))
	var maximo := 0
	var t := 0.0
	while t < nivel.duracion:
		t += 0.05
		reloj[0] = t
		gestor.actualizar(0.05, t)
		maximo = maxi(maximo, gestor.activos.size())
	var a_tiempo := llegadas.size() == esperadas.size()
	if a_tiempo:
		for i in esperadas.size():
			if absf(llegadas[i] - esperadas[i]) > 0.2:
				a_tiempo = false
	_ok(a_tiempo, "%s: los %d pedidos llegan a los 5 s y luego cada intervalo fijo" % [nivel.nombre, esperadas.size()])
	var orden := true
	var secuencia := nivel.secuencia_tipada()
	for i in mini(nombres.size(), secuencia.size()):
		if nombres[i] != secuencia[i].nombre:
			orden = false
	_ok(orden, "%s: la secuencia de recetas es la fija del nivel" % nivel.nombre)
	_ok(maximo <= nivel.cupo_pedidos, "%s: nunca hay mas de %d pedidos activos" % [nivel.nombre, nivel.cupo_pedidos])
	var unicos := {}
	for n in vencidos:
		unicos[n] = true
	_ok(not vencidos.is_empty() and unicos.size() == vencidos.size(), "%s: cada pedido vence una sola vez" % nivel.nombre)


# ---------- Sesion completa: estados, entrega, rechazo, pausa y fin ----------
func _probar_sesion() -> void:
	var nivel := Nivel.cargar(1)
	var barra := BarraEntrega.new()
	var dispensador := DispensadorPlatos.new()
	_nodos.append(barra)
	_nodos.append(dispensador)
	var estaciones: Array[Estacion] = [barra, dispensador]
	var s := GameSession.new()
	s.iniciar(nivel, estaciones, false)
	_ok(s.estado == GameSession.Estado.CUENTA_ATRAS, "Sesion: empieza con la cuenta atras de 3 s")
	_avanzar_sesion(s, 3.2)
	_ok(s.estado == GameSession.Estado.SERVICIO, "Sesion: pasa al servicio tras la cuenta atras")
	_avanzar_sesion(s, 5.1)
	_ok(s.gestor_pedidos.activos.size() == 1, "Sesion: el primer pedido llega a los 5 s")

	barra.recibir(_arepa_armada())
	var puntos := s.puntuacion.puntos
	_ok(puntos >= 74 and puntos <= 75 and s.resultado.entregados == 1, "Entrega correcta: 50 + propina (casi 25) con el pedido casi nuevo")
	_ok(s.gestor_pedidos.activos.is_empty(), "Entrega: el pedido entregado sale de los activos")

	_avanzar_sesion(s, 25.0)
	_ok(s.gestor_pedidos.activos.size() == 1 and s.gestor_pedidos.activos[0].receta.nombre == "Empanadas", "Sesion: a los 30 s llega el pedido de empanadas")
	var antes := s.puntuacion.puntos
	barra.recibir(_arepa_armada())
	_ok(s.puntuacion.puntos == antes - 17 and s.resultado.rechazados == 1 and s.gestor_pedidos.activos.is_empty(), "Plato que no corresponde: cierra el pedido mas antiguo y resta el 25 % (-17)")
	var antes2 := s.puntuacion.puntos
	barra.recibir(_arepa_armada())
	_ok(s.puntuacion.puntos == antes2 and s.resultado.rechazados == 1, "Plato sin pedidos activos: se descarta sin penalizacion")

	var t0 := s.tiempo_restante
	s.pausar()
	_avanzar_sesion(s, 10.0)
	_ok(is_equal_approx(s.tiempo_restante, t0), "Pausa: el reloj no avanza")
	s.reanudar()
	_avanzar_sesion(s, 1.0)
	_ok(absf((t0 - s.tiempo_restante) - 1.0) < 0.1, "Pausa: al reanudar continua desde el mismo valor")

	_avanzar_sesion(s, 24.5)
	_ok(s.gestor_pedidos.activos.size() == 1, "Sesion: hay un pedido activo al acercarse el final")
	s.puntuacion.puntos = 400
	var vencidos_antes := s.resultado.vencidos
	s.tiempo_restante = 2.0
	_avanzar_sesion(s, 2.5)
	_ok(s.estado == GameSession.Estado.RESULTADOS and s.esta_terminada(), "Fin: la partida termina en 0 s y pasa a resultados")
	_ok(s.gestor_pedidos.activos.is_empty() and s.puntuacion.puntos == 400 and s.resultado.vencidos == vencidos_antes, "Fin: los pedidos pendientes se descartan sin sumar ni restar")
	_ok(s.resultado.cuota_cumplida and s.resultado.estrellas == 1 and s.resultado.puntaje == 400, "Fin: 400 puntos en Fermi = cuota cumplida con 1 estrella")


# ---------- Codice y progreso ----------
func _probar_codice_y_progreso() -> void:
	var codice := Codice.new()
	codice.cargar_entradas()
	codice.cargar_desbloqueadas(PackedStringArray())
	_ok(codice.entradas.size() == 3, "Codice: 3 entradas")
	var todas_bloqueadas := true
	var dentro_del_limite := true
	for entrada in codice.entradas:
		if codice.nombre_visible(entrada) != "???":
			todas_bloqueadas = false
		if entrada.cantidad_palabras() > 60:
			dentro_del_limite = false
	_ok(todas_bloqueadas, "Codice: las entradas bloqueadas se muestran como ???")
	_ok(dentro_del_limite, "Codice: cada entrada tiene 60 palabras o menos (AC-CU-1, sin contar las fuentes)")
	var arepa := _receta("arepa_con_queso")
	var nueva := codice.desbloquear(arepa)
	_ok(nueva != null and codice.esta_desbloqueada(nueva), "Codice: la primera entrega desbloquea la entrada")
	_ok(codice.desbloquear(arepa) == null, "Codice: una segunda entrega no vuelve a desbloquear")
	codice.descartar_pendientes()
	_ok(not codice.esta_desbloqueada(nueva), "Codice: salir a mitad de nivel descarta el desbloqueo")
	codice.desbloquear(arepa)
	codice.confirmar()
	_ok(codice.esta_desbloqueada(nueva) and codice.cantidad_desbloqueadas() == 1, "Codice: al terminar el nivel el desbloqueo se confirma")

	var progreso := ProgresoJugador.new()
	var r := ResultadoPartida.new()
	r.nivel = Nivel.cargar(1)
	r.estrellas = 0
	r.puntaje = 100
	progreso.registrar_resultado(r)
	_ok(progreso.nivel_desbloqueado == 1 and not progreso.esta_desbloqueado(2), "Progreso: sin estrellas JLB sigue bloqueado")
	r.estrellas = 2
	r.puntaje = 400
	progreso.registrar_resultado(r)
	_ok(progreso.esta_desbloqueado(2) and progreso.estrellas_de(1) == 2, "Progreso: 1 estrella o mas desbloquea JLB")
	r.estrellas = 1
	r.puntaje = 300
	progreso.registrar_resultado(r)
	_ok(progreso.estrellas_de(1) == 2 and progreso.mejor_puntaje_de(1) == 400, "Progreso: repetir conserva el mejor puntaje y las mejores estrellas")
	r.nivel = Nivel.cargar(2)
	r.estrellas = 3
	progreso.registrar_resultado(r)
	_ok(progreso.nivel_desbloqueado == 2, "Progreso: no existe un nivel 3 que desbloquear")
	progreso.volumen_musica = 0.5
	progreso.entradas_codice = PackedStringArray(["arepa_con_queso"])
	var json := JSON.new()
	json.parse(JSON.stringify(progreso.a_diccionario()))
	var copia := ProgresoJugador.new()
	copia.desde_diccionario(json.data)
	_ok(copia.estrellas_de(1) == 2 and copia.volumen_musica == 0.5 and copia.entradas_codice.has("arepa_con_queso"), "Guardado: el progreso sobrevive a guardar y cargar")
	var danado := ProgresoJugador.new()
	danado.desde_diccionario({"nivel_desbloqueado": "x", "estrellas": 5, "volumen_sfx": "mucho"})
	_ok(danado.nivel_desbloqueado == 1 and danado.volumen_sfx == 1.0, "Guardado: datos danados se ignoran y queda el progreso vacio")
