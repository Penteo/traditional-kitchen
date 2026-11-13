extends Node
## Bus de eventos global (Observer). Solo declara senales: sin logica ni estado.
## Emitir:   EventBus.pedido_entregado.emit(jugador_id, puntos)
## Escuchar: EventBus.pedido_entregado.connect(_on_pedido_entregado)

# Pedidos y recetas
signal pedido_generado(receta_id: String)
signal pedido_entregado(jugador_id: int, puntos: int)
signal pedido_vencido(receta_id: String)
signal receta_completada(jugador_id: int, receta_id: String)

# Puntuacion y partida
signal puntuacion_cambiada(puntos_totales: int)
signal tiempo_actualizado(segundos_restantes: int)
signal tiempo_agotado
signal partida_iniciada
signal partida_pausada(en_pausa: bool)
signal partida_terminada(puntos_totales: int)