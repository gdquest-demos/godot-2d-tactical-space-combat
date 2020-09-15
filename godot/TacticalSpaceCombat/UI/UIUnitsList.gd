extends Control

export var UIUnit: PackedScene


func setup(units: Array) -> void:
	for unit in units:
		var widget: UIUnit = UIUnit.instance()
		widget.setup(unit)
		add_child(widget)
