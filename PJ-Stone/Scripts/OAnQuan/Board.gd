extends Control

var difficulty: int = 0
var restart: bool = false
var n := 12
var player: int
var cur_cell: int
var cell = preload("res://Scenes/OAnQuan/Cell.tscn")
var board: Array
var score: Array
var state: Array
export var stone1: Resource
export var stone2: Resource

func player_node(cur_player := player):
	return get_node("Player" + String(cur_player+1))


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


func reset():
	for i in range(0, n): 
		if big_cell(i): state[i] = 10
		else: state[i] = 5
		board[i].reset()
	score[0] = 0
	score[1] = 0
	cur_cell = -1
	set_player(0)
	$ButtonLeft.visible = false
	$ButtonRight.visible = false
	player_node(0).reset()
	player_node(1).reset()


func _ready():
	print(difficulty)
	player = 0
	score.resize(2)
	state.resize(n)
	for i in range(0, n):
		board.append(cell.instance())
		board[i].cell_id = i
		
		if big_cell(i):
			$Grid.add_child(board[i])
			if i == 0: $Grid.move_child(board[i], 0)
		else: $Grid/Mid.add_child(board[i])
		if 7<=i and i<12: $Grid/Mid.move_child(board[i], 5)
		
		board[i].connect("selected", self, "cell_selected")
	
	reset()
	$Grid.add_constant_override("separation", 0)
	$Grid/Mid.add_constant_override("hseparation", 0)
	$Grid/Mid.add_constant_override("vseparation", 0)
	$Player2/Display/Name.text = "Player 2"


func next(id: int, dir: int) -> int:
	id += dir
	if id < 0: id += n
	if id >= n: id -= n
	return id

func big_cell(id) -> bool:
	return id == 0 or id == 6

func player1(id)-> bool:
	return 1<=id and id<=5
	
func player0(id) -> bool:
	return 7<=id and id<=11

func near(id) -> Vector2:
	if player0(id): return Vector2(0, 100)
	elif player1(id): return Vector2(0, -60)
	elif id == 0: return Vector2(-90, 75)
	else: return Vector2(90, 75)

func player_position(id = player) -> Vector2:
	if id == 0: return Vector2(10, 45)
	else: return Vector2(914, 45)


func update_score(cur_player, new_score):
	score[cur_player] = new_score
	player_node(cur_player).set_score(new_score)


func set_board_disabled(disabled: bool):
	for i in range(0, n): board[i].disabled = disabled


func set_player(turn: int):
	player = turn
	if difficulty and turn == 1: set_board_disabled(true)
	for i in range(0, 12):
		if state[i] == 0: board[i].disabled = true
		elif turn == 0 and player0(i): board[i].disabled = false
		elif turn == 1 and player1(i): board[i].disabled = false
		else: board[i].disabled = true


func game_over():
	if state[0] > 0 or state[6] > 0:
		yield(get_tree(), "idle_frame")
		return false
	
	$PopupText.visible = true
	$PopupText.text = "GAME OVER"

	for i in range(1, 6):
		yield(collect_endgame(i, 1), "completed")

		if get_tree().paused:
			var action = yield(get_node("Menu"), "game_state")
			if action == 1: return
	
	for i in range(7, n):
		yield(collect_endgame(i, 0), "completed")
		if get_tree().paused:
			var action = yield(get_node("Menu"), "game_state")
			if action == 1: return
	
	yield(get_tree().create_timer(1), "timeout")
	var winner = -1
	if score[0] > score[1]: winner = 0
	elif score[1] > score[0]: winner = 1
	if winner != -1: player_node(winner).set_winner()
	
	yield(get_tree().create_timer(1), "timeout")

	if get_tree().paused:
		var action = yield(get_node("Menu"), "game_state")
		if action == 1: return
	
	$PopupText.visible = false

	if winner != -1: winner = 'PLAYER' + String(winner+1) + ' WINS'
	else: winner = 'DRAW'
	
	$Menu/VBoxContainer/Text.text = winner
	$Menu/VBoxContainer/Resume.visible = false
	$Menu.visible = true
	get_tree().paused = true

	return true


func collect_endgame(id, player_id):
	if state[id] == 0:
		yield(get_tree(), "idle_frame")
		return
	
	#Animation
	var drop = board[id].get_node("Stones")
	if not big_cell(id): drop.rearrange(0.1)
	var children = drop.get_children()
	yield(get_tree().create_timer(0.2), "timeout")
	
	for i in children:
		if i.texture == stone2: #if i is large stone
			state[id] -= 10
			score[player_id] += 10
		else: 
			state[id] -= 1
			score[player_id] += 1

		if get_tree().paused:
			var action = yield(get_node("Menu"), "game_state")
			if action == 1: return
		
		i.send_to(player_node(player_id), 0.25)
		yield(get_tree().create_timer(0.1), "timeout")
		board[id].set_count(state[id])
		update_score(player_id, score[player_id])

	board[id].empty_cell()


func handle_empty_row():
	var l
	var r
	if player == 0: l = 7
	else: l = 1
	r = l+5
	
	yield(get_tree(), "idle_frame")
	for i in range(l, r):
		if state[i] > 0: return
	
	set_board_disabled(true)
	yield(get_tree().create_timer(0.5), "timeout")
	for i in range(l, r): board[i].add_border(Color.red, 2)
	if get_tree().paused:
		var action = yield(get_node("Menu"), "game_state")
		if action == 1: return
	
	for i in range(l, r):
		#Logic
		state[i] = 1 
		score[player] -= 1

		#Animations
		if get_tree().paused:
			var action = yield(get_node("Menu"), "game_state")
			if action == 1: return

		var new_stone = yield(player_node().get_stone(), "completed")
		player_node().set_score(score[player])
		new_stone.send_to(board[i], 0.25)
		yield(get_tree().create_timer(0.15), "timeout")

	yield(get_tree().create_timer(0.2), "timeout")
	if get_tree().paused:
		var action = yield(get_node("Menu"), "game_state")
		if action == 1: return
	
	for i in range(l, r): board[i].remove_border()
	set_player(player)


func collect(id: int, dir: int):
	if get_tree().paused:
		var action = yield(get_node("Menu"), "game_state")
		if action == 1: return
	if state[id] == 0:
		board[id].add_border(Color.red, 2)
		yield(get_tree().create_timer(0.3), "timeout")
		board[id].remove_border()
		return
	
	#Animation
	board[id].add_border(Color.darkorange, 2)
	var drop = board[id].get_node("Stones")
	if not big_cell(id): drop.rearrange(0.1)
	var children = drop.get_children()
	player_node().add_border(Color.darkorange, 2)
	yield(get_tree().create_timer(0.2), "timeout")
	
	for i in children:
		if i.texture == stone2: #if i is large stone
			state[id] -= 10 
			score[player] += 10
		else: 
			state[id] -= 1
			score[player] += 1
		
		if get_tree().paused:
			var action = yield(get_node("Menu"), "game_state")
			if action == 1: return
		i.send_to(player_node(), 0.25)
		yield(get_tree().create_timer(0.1), "timeout")
		board[id].set_count(state[id])
		update_score(player, score[player])

	yield(get_tree().create_timer(0.3), "timeout")
	board[id].remove_border()
	board[id].empty_cell()
	player_node().reset_border()
	if get_tree().paused:
		var action = yield(get_node("Menu"), "game_state")
		if action == 1: return


	id = next(id, dir)
	if state[id] == 0:
		board[id].add_border(Color.green, 2)
		yield(get_tree().create_timer(0.3), "timeout")
		board[id].remove_border()
		yield(collect(next(id, dir), dir), "completed") #Wait until this function finishes, then proceed


func move(id: int, dir: int):
	if get_tree().paused:
		var action = yield(get_node("Menu"), "game_state")
		if action == 1: return

	var steps = state[id]
	var drop = board[id].get_node("Stones").duplicate(7)
	add_child(drop)
	drop.position = board[id].get_global_position()
	board[id].empty_cell()

	drop.move(near(id), 0.1)
	drop.rearrange(0.1)
	yield(get_tree().create_timer(0.3), "timeout")

	if get_tree().paused:
		var action = yield(get_node("Menu"), "game_state")
		if action == 1: return

	state[id] = 0

	for _i in range(0, steps):
		id = next(id, dir)
		state[id] += 1
		
		if get_tree().paused:
			var action = yield(get_node("Menu"), "game_state")
			if action == 1: return
		
		board[id].add_border(Color.green, 2)
		drop.move(board[id].get_global_position() + near(id) - drop.position, 0.1)
		yield(get_tree().create_timer(0.2), "timeout")
		drop.get_child(0).send_to(board[id], 0.1)
		if get_tree().paused:
			var action = yield(get_node("Menu"), "game_state")
			if action == 1: return
		
		yield(get_tree().create_timer(0.2), "timeout")
		board[id].remove_border()

	if get_tree().paused:
		var action = yield(get_node("Menu"), "game_state")
		if action == 1: return

	drop.queue_free()
	id = next(id, dir)
	if state[id] == 0: #Empty cell --> collect stones
		board[id].add_border(Color.green, 2)
		yield(get_tree().create_timer(0.3), "timeout")
		board[id].remove_border()
		yield(collect(next(id, dir), dir), "completed") #Wait until this function finishes, then proceed
		yield(player_node().rearrange(0.15), "completed")
	elif not big_cell(id): #Non-empty cell --> take stones and move
		board[id].add_border(Color.cyan, 2)
		yield(get_tree().create_timer(0.3), "timeout")
		board[id].remove_border()
		yield(move(id, dir), "completed") #Wait until this function finishes, then proceed
	else:
		board[id].add_border(Color.red, 2)
		yield(get_tree().create_timer(0.3), "timeout")
		board[id].remove_border()


func initiate_move(id, dir):
	if cur_cell != -1: board[cur_cell].set_pressed_no_signal(false)
	cur_cell = -1;

	$ButtonLeft.visible = false;
	$ButtonRight.visible = false;

	set_board_disabled(true)
	yield(move(id, dir), "completed")
	if restart: return
	var completed = yield(game_over(), "completed")
	if restart or completed: return
	set_player(not player)
	if restart: return
	yield(handle_empty_row(), "completed")
	if restart: return
	
	if difficulty and player == 1:
		yield(get_tree().create_timer(0.3), "timeout")
		if get_tree().paused:
			var action = yield(get_node("Menu"), "game_state")
			if action == 1: return
		var action = $Bot.find_move(state, difficulty)
		initiate_move(action.x, action.y)


func cell_selected(id: int, pressed: bool):
	if pressed:
		if cur_cell != -1: board[cur_cell].set_pressed_no_signal(false)
		cur_cell = id
	else: cur_cell = -1
	$ButtonLeft.visible = pressed
	$ButtonRight.visible = pressed


func _on_ButtonRight_pressed():
	if player == 0: yield(initiate_move(cur_cell, -1), "completed") #Wait until this function finishes, then proceed
	else: yield(initiate_move(cur_cell, 1), "completed") #Wait until this function finishes, then proceed


func _on_ButtonLeft_pressed():
	if player == 0: yield(initiate_move(cur_cell, 1), "completed") #Wait until this function finishes, then proceed
	else: yield(initiate_move(cur_cell, -1), "completed") #Wait until this function finishes, then proceed


func _on_ButtonMenu_pressed():
	$Menu/VBoxContainer/Text.text = "PAUSED"
	$Menu.visible = true
	get_tree().paused = true
#	if cur_cell != -1: board[cur_cell].pressed = false
