# Traditional Kitchen

Videojuego de cocina cooperativo local para 2 jugadores (Windows).
Proyecto académico, Electiva Profesional II: Videojuegos, UDI.

Integrantes: Yeison Suárez Suárez, Juan David Sepúlveda Rojas, Eber Arley Arias Osorio.

## Requisitos
- Godot: versión 4.7.1 estable (build 4.7.1.stable.official.a13da4feb, con la que se verificó que el proyecto importa y las pruebas pasan)
- Git y Git LFS

## Cómo abrir el proyecto
1. Clonar el repositorio.
2. Abrir Godot, pulsar Importar y elegir el archivo project.godot.

## Cómo ejecutar
Pulsar F5 (la escena principal es scenes/main/main.tscn).

## Cómo exportar
Project > Export > Windows Desktop, salida en la carpeta builds/.

## Cómo jugar
Objetivo: preparar y entregar los pedidos antes de que se acabe el tiempo. Si se alcanza la cuota de puntos del nivel, se asegura la permanencia en la universidad. Se juega entre dos personas en el mismo teclado.

| Acción      | Jugador 1 (azul) | Jugador 2 (rojo)                                           |
| ----------- | ---------------- | ---------------------------------------------------------- |
| Moverse     | W, A, S, D       | Flechas                                                    |
| Interactuar | F                | `.` (punto)                                                |
| Procesar    | G                | `/` (en un teclado latinoamericano esa tecla muestra `-`)  |

- Interactuar: recoger, depositar, retirar y entregar.
- Procesar: cortar en la tabla.
- Pausa: Esc o P.

## Descargar el juego
Para jugar sin instalar Godot, descargar `Traditional Kitchen.exe` desde la página de [Releases](https://github.com/Penteo/traditional-kitchen/releases/tag/v0.1.0) (Windows).

## Documentación
En la carpeta docs/ están el seguimiento de requisitos (verificacion_requisitos.md), las fuentes del Códice (fuentes_codice.md) y el registro de activos (registro_activos.md). El archivo del GDD debe agregarse a esta carpeta antes de la entrega.

## Pruebas
Abrir tests/pruebas_sistemas.gd en el editor de Godot y usar Archivo > Ejecutar (Ctrl+Mayús+X); el resultado sale en la pestaña Salida.
