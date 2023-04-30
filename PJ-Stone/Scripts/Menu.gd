extends CanvasLayer

signal game_state(id) #0: resume, 1: discard current game


func _on_Resume_pressed():
	get_tree().paused = false
	visible = false
	emit_signal("game_state", 0)


func _on_Restart_pressed():
	emit_signal("game_state", 1)
	get_tree().current_scene.restart = true
	yield(get_tree().create_timer(0.2), "timeout")
	get_tree().paused = false;
	visible = false

	get_tree().call_deferred("reload_current_scene")


func _on_Exit_pressed():
	emit_signal("game_state", 1)
	get_tree().current_scene.restart = true
	yield(get_tree().create_timer(0.2), "timeout")
	get_tree().paused = false
	Global.switch_scene(load("res://Scenes/TitleScreen.tscn").instance())
