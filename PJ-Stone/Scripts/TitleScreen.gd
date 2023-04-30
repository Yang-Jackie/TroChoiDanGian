extends Control

var game = preload("res://Scenes/OAnQuan/OAnQuan.tscn").instance()

func _on_PVE_pressed():
	$Mode.visible = false
	$Difficulty.visible = true


func _on_PVP_pressed():
	game.difficulty = 0
	Global.switch_scene(game)


func _on_Easy_pressed():
	game.difficulty = 1
	Global.switch_scene(game)


func _on_Normal_pressed():
	game.difficulty = 2
	Global.switch_scene(game)


func _on_Hard_pressed():
	game.difficulty = 3
	Global.switch_scene(game)
