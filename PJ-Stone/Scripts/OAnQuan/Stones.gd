extends Node2D

var velocity := Vector2.ZERO
var acceleration := Vector2.ZERO

func move(distance: Vector2, duration: float):
	var cur_position = position
	var time_left = duration
	while time_left > 0:
		var elapsed = get_process_delta_time()
		time_left -= elapsed
		yield(get_tree(), "idle_frame")
		position += elapsed * distance / duration
		
	position = cur_position + distance


func send_to(node: Node, duration: float):
	var new_position = node.place_stone()
	var world = get_tree().current_scene
	position = get_global_position()
	get_parent().remove_child(self)
	world.add_child(self)
	yield(move(new_position + node.stone_holder() - position, duration), "completed")
	get_parent().remove_child(self)
	node.add_stone(self)
	self.position = new_position


func rearrange(duration: float):
	var children = get_children()
	for i in children:
		var new_position = Vector2(rand_range(30, 70), rand_range(20, 40))
		i.move(new_position - i.position, duration)
	yield(get_tree().create_timer(duration), "timeout")
		
func _ready():
	set_process(false)
