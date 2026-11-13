class_name CreditosView
extends Pantalla
## Cinco bloques (seccion 9.5). Los datos pendientes de registro se indican como tales.


func _construir() -> void:
	_fondo()
	var columna := _columna(1200.0)
	columna.add_child(_etiqueta("Créditos", 56))
	_bloque(columna, "Proyecto", "Traditional Kitchen, proyecto académico, 2026")
	_bloque(columna, "Integrantes", "Yeison Suárez Suárez: desarrollo y programación\nJuan David Sepúlveda Rojas: diseño de juego y niveles\nEber Arley Arias Osorio: arte, animación y audio")
	_bloque(columna, "Institución", "Asignatura Electiva Profesional II: Videojuegos\nPrograma de Ingeniería de Sistemas, Facultad de Ingeniería\nUniversidad de Investigación y Desarrollo")
	_bloque(columna, "Activos de terceros", "Pendiente de registro (nombre, autor, licencia y enlace de cada activo).")
	_bloque(columna, "Avisos de licencia", "Hecho con Godot Engine (licencia MIT).")
	columna.add_child(_boton("Volver", func() -> void: volver_solicitado.emit()))


func _bloque(columna: VBoxContainer, titulo: String, texto: String) -> void:
	columna.add_child(_etiqueta(titulo, 30, HORIZONTAL_ALIGNMENT_CENTER, Color(1.0, 0.85, 0.5)))
	columna.add_child(_etiqueta(texto, 22, HORIZONTAL_ALIGNMENT_CENTER, COLOR_TEXTO_SUAVE))
