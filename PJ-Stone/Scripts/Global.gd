extends Node

func switch_scene(to: Node):
	call_deferred("deferred_switch_scene", to)

func deferred_switch_scene(to: Node):
	get_tree().current_scene.free()
	get_tree().root.add_child(to)
	get_tree().current_scene = to
