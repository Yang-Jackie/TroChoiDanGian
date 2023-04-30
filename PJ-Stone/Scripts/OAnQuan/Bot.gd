extends Node

var main: Node = get_parent()
var turn = 1
var board: Array

func big_cell(cell: int):
	return cell==0 or cell==6

func next(cell: int, dir: int, steps: int = 1):
	cell += dir*steps
	cell %= 12
	if cell < 0: cell += 12
	return cell


func collect(cell: int, dir: int, state: Array):
	if state[cell] == 0: return 0
	var res = state[cell]
	state[cell] = 0
	cell = next(cell, dir)
	if state[cell] == 0: return res + collect(next(cell, dir), dir, state)
	return res


func evaluate(cell: int, dir: int, state: Array) -> int:
	if state[cell] == 0: return -1;
	
	var steps = state[cell]
	state[cell] = 0
	for _i in range(0, steps):
		cell = next(cell, dir)
		state[cell] += 1
	
	cell = next(cell, dir)
	if state[cell] == 0: return collect(next(cell, dir), dir, state)
	elif big_cell(cell): return 0
	return evaluate(cell, dir, state)


func rand(l,r):
	return randi() % (r-l+1) + l


func random_move() -> Vector2:
	if turn == 1: return Vector2(rand(1,5), [-1,1][rand(0,1)])
	else: return Vector2(rand(7,11), [-1,1][rand(0,1)])


func find_move(state: Array, difficulty: int) -> Vector2:
	var res
	var Max=-1
	var times
	if difficulty == 1: times=2
	elif difficulty == 2: times=6
	elif difficulty == 3: times=10
	for _i in range(times):
		var move
		var val
		while true:
			move = random_move()
			val = evaluate(move.x, move.y, state.duplicate())

			if val > -1: break
		if (val > Max):
			Max = val
			res = move
	return res

func _ready():
	randomize()
