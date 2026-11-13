extends Node
## Bus de eventos global (Observer). Solo declara senales: sin logica ni estado.
## Emitir:   EventBus.sfx_solicitado.emit("picar")
## Escuchar: EventBus.partida_terminada.connect(_al_terminar_partida)

# Partida: los emite GameController (tambien siguen disponibles en GameController).
signal partida_iniciada(nivel: Nivel)
signal partida_terminada(resultado: ResultadoPartida)
signal receta_entregada(receta: Receta)

# Audio: cualquier nodo pide un efecto sin conocer a AudioController.
signal sfx_solicitado(id: String)
