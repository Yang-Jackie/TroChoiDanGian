extends Button


var cell_id
var count := 0
var stone1 = preload("res://Assets/OAnQuan/Rock1.png")
var stone2 = preload("res://Assets/OAnQuan/Rock2.png")
signal selected(id, pressed)

func big_cell():
	return cell_id == 0 or cell_id == 6


func set_count(val):
	count = val
	$Count.text = String(count)


func create_stone(large = false):
	var new_stone = Sprite.new()
	new_stone.set_script(load("res://Scripts/OAnQuan/Stones.gd"))
	if large: 
		new_stone.texture = stone2
		new_stone.scale = Vector2.ONE * 0.15
	else: 
		new_stone.texture = stone1
		new_stone.scale = Vector2.ONE * 0.5
	return new_stone


func remove_stone(times:=1):
	if count == 0 or times == 0: return
	$Stones.get_child(-1).queue_free()
	set_count(count-1)
	remove_stone(times-1)


func place_stone(_large:=false):
	var position : Vector2
	if big_cell():
		position.y = rand_range(30, 170)
		if cell_id == 0: position.x = rand_range(20 + abs(position.y - 100)/2, 75)
		else: position.x = rand_range(20, 75 - abs(position.y - 100)/2.1)
	else: position = Vector2(rand_range(20, 75), rand_range(20, 75))
	return position


func stone_holder():
	return get_global_position()


func add_stone(new_stone: Node, large:=false):
	$Stones.add_child(new_stone)
	new_stone.position = place_stone(large)
	
	if large: $Stones.move_child(new_stone, 0)
	if large: set_count(count+10)
	else: set_count(count+1)
	

func set_width(state: StyleBoxFlat, width):
	for i in ["left", "right", "bottom", "top"]: state.set("border_width_" + i, width)


func add_border(color, width):
	var border = get_stylebox("normal")
	border.border_color = color
	set_width(border, width)


func add_shade(degree = 0.25):
	var appearance = get_stylebox('normal')
	appearance.bg_color = Color(70/255, 70/255, 70/255, degree)

func remove_border():
	var border = get_stylebox("normal")
	border.border_color = Color.black
	set_width(border, 1)


func empty_cell():
	var children = $Stones.get_children()
	for i in children: i.queue_free()
	set_count(0)


func reset():
	empty_cell()
	if big_cell(): add_stone(create_stone(true), true)
	else:
		for _i in range(0, 5): add_stone(create_stone())
	set_pressed_no_signal(false)
	if cell_id == 6: $Count.rect_position = Vector2(0, 70)
	remove_border()

func half_circle(state: StyleBoxFlat, side: String):
	state.set("corner_radius_top_" + side, 100)
	state.set("corner_radius_bottom_" + side, 100)
	state.corner_detail = 20

func _ready():
	randomize()
	add_stylebox_override("disabled", get_stylebox("normal"))
	
	if not big_cell(): return
	
	for i in ["normal", "pressed", "hover"]:
		if cell_id == 0: half_circle(get_stylebox(i), "left")
		else: half_circle(get_stylebox(i), "right")

func _toggled(button_pressed):
	emit_signal("selected", cell_id, button_pressed)
