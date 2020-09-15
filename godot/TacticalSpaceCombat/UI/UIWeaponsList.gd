extends Control

export var UIWeapon: PackedScene


func setup(weapons: Array) -> void:
	for weapon in weapons:
		var widget: UIWeapon = UIWeapon.instance()
		widget.setup(weapon)
		add_child(widget)
