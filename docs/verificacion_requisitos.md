# Verificación de requisitos de Traditional Kitchen

Estado al 11 de noviembre de 2026. Estados: Implementado, Verificado, Pendiente, Fuera de alcance.

## Requisitos funcionales

| ID | Requisito | Cómo se verifica | Estado |
|---|---|---|---|
| RF-01 | Selección y desbloqueo de niveles | Con progreso vacío solo Fermi es seleccionable; con 1 estrella en Fermi se desbloquea JLB | Implementado |
| RF-02 | Control cooperativo local | Prueba G1: ambos chefs a la vez, 10 de 10 cruces bloqueados, acción simultánea: solo J1 | Verificado (repetir en la máquina de evaluación) |
| RF-03 | Manejo de ítems y estaciones (R1, R2, R5) | Tabla 14 del GDD | Implementado |
| RF-04 | Corte, cocción y alertas | Tiempos de la Tabla 15; íconos verde, ámbar parpadeante y negro | Implementado (alertas sonoras sin archivos) |
| RF-05 | Emplatado y validación de entrega | Las 3 recetas se completan en cualquier orden; plato incorrecto rechazado | Implementado |
| RF-06 | Pedidos | Secuencia fija, cupo 3 o 4, tarjetas con barra verde, ámbar y roja | Implementado |
| RF-07 | Puntuación y estrellas | Umbrales 249/250, 349/350, 449/450 en Fermi y 449/450, 629/630, 809/810 en JLB | Implementado |
| RF-08 | Reloj y pausa | Esc o P detiene reloj, estaciones y pedidos | Implementado |
| RF-09 | HUD y pantalla de resultados | Todos los elementos con datos coherentes; Reintentar sin ficha | Implementado |
| RF-10 | Ficha de receta y Códice | AC-CU-1 a AC-CU-3 | Implementado (textos sin fuentes) |
| RF-11 | Guardado de progreso y volumen | AC-CU-6: el progreso persiste tras cerrar y abrir | Implementado |
| RF-12 | Menús y pantallas informativas | Figura 5 del GDD; aviso académico visible en el menú principal | Implementado |
| RF-13 | Audio | 10 SFX y 2 pistas con volumen ajustable | Pendiente (faltan los archivos) |
| RF-14 | Telemetría local | Eventos en un CSV | Fuera de alcance (decisión del 10 de noviembre) |

## Requisitos no funcionales

| ID | Requisito | Cómo se verifica | Estado |
|---|---|---|---|
| RNF-01 | Compatibilidad y hardware mínimo | El build abre en un PC sin Godot y completa ambos niveles | Pendiente |
| RNF-02 | Rendimiento | Promedio de 60 FPS o más sin caídas bajo 45 FPS por más de 2 s; menú en 15 s o menos | Pendiente |
| RNF-03 | Estabilidad | 3 de 3 sesiones de 30 minutos sin cierres | Pendiente |
| RNF-04 | Usabilidad | Playtest con 6 testers: 4 explican las reglas y 4 alcanzan la cuota de Fermi | Pendiente |
| RNF-05 | Veracidad del contenido cultural | Fuente registrada para cada afirmación del Códice | Pendiente (fuentes sin registrar) |
| RNF-06 | Licencias y originalidad | 100 % de los activos de terceros en el registro; sin elementos de Overcooked 2 | Pendiente |
| RNF-07 | Mantenibilidad | Todo entra por pull request revisado; el README basta para abrir, compilar y exportar | Pendiente |
| RNF-08 | Control de alcance | El build no incluye escena de prueba ni opcionales | Pendiente (retirar prueba_g1 antes de la entrega) |

## Objetivos del MVP

| ID | Objetivo | Estado |
|---|---|---|
| OB-1 | Dos jugadores completan los dos niveles sin bloqueos | Pendiente |
| OB-2 | Ciclo principal y umbrales de estrellas | Implementado |
| OB-3 | Códice de 3 entradas con fuente registrada | Pendiente (fuentes) |
| OB-4 | Build exportado, estable y fluido | Pendiente |
| OB-5 | Validación con jugadores ajenos al equipo | Pendiente |
| OB-6 | Documentación y licencias | Pendiente |