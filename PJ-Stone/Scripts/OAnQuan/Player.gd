extends Control

export var stone1: Resource
export var stone2: Resource

func set_score(new_score):
	$Display/Points.text = String(new_score)


func place_stone(_large = false) -> Vector2:
	return Vector2(rand_range(20, 80), rand_range(20, 80))


func stone_holder():
	return get_global_position() + Vector2(10, 46)


func rearrange(duration: float):
	var children = $Display/Store.get_children()
	for i in children:
		var new_position = Vector2(rand_range(20, 80), rand_range(20, 80))
		i.move(new_position - i.position, duration)
		if i.texture == stone2: $Display/Store.move_child(i, 0) 
	yield(get_tree().create_timer(duration), "timeout")


func add_stone(new_stone = null) -> Node:
	if new_stone == null:
		new_stone = Sprite.new()
		new_stone.texture = stone1
		new_stone.scale = Vector2.ONE * 0.5
		new_stone.set_script(load("res://Scripts/OAnQuan/Stones.gd"))
	new_stone.position = place_stone()
	$Display/Store.add_child(new_stone)
	return new_stone


func get_stone() -> Node:
	var stones = $Display.get_node("Store")
	if stones.get_child_count() == 0: add_stone()
	if stones.get_child(stones.get_child_count()-1).texture == stone2: #if only contains large stone
		#Some effects for removing the large stone and adding small ones
		stones.get_child(stones.get_child_count()-1).free()
		for _i in range(10): add_stone()
		yield(rearrange(0.1), "completed")
	var res = stones.get_child(stones.get_child_count()-1)
	yield(get_tree(), "idle_frame")
	return res


func add_border(color, width):
	$Display/Store.border_color = color
	$Display/Store.border_width = width


func reset_border():
	$Display/Store.border_color = Color.black
	$Display/Store.border_width = 1


func reset():
	$Display/Points.text = "0"
	var stones = $Display/Store.get_children()
	for i in stones: i.queue_free()

func set_winner():
	var label = $Display.get_node("Name")
	label.get_font("font").outline_color = Color.red
	label.get_font("font").outline_size = 2
	label.get_font("font").size += 4
	label = $Display.get_node("Points")
	label.get_font("font").outline_color = Color.red
	label.get_font("font").outline_size = 2
	label.get_font("font").size += 4

func _ready():
	reset()
	randomize()


