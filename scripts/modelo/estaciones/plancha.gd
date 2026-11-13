class_name Plancha
extends EstacionCoccion
## Asa la masa de arepa (7 s, ventana de 5 s).


func _configurar() -> void:
	nombre = "Plancha"
	color_placeholder = Color(0.45, 0.45, 0.5)
	tipos_aceptados = [Ingrediente.Tipo.MASA]
	estado_requerido = Ingrediente.Estado.CRUDO
	items_para_iniciar = 1
