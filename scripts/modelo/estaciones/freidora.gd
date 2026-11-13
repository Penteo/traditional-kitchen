class_name Freidora
extends EstacionCoccion
## Fríe cada empanada cruda (10 s, ventana de 6 s).


func _configurar() -> void:
	nombre = "Freidora"
	color_placeholder = Color(0.8, 0.55, 0.2)
	tipos_aceptados = [Ingrediente.Tipo.EMPANADA]
	estado_requerido = Ingrediente.Estado.CRUDO
	items_para_iniciar = 1
