extends Node2D


var Room = preload("res://Maker.tscn")
var Player = preload("res://Player.tscn")
var tile_size = 32
var num_rooms = 55
export(int) var w = 35
export(int) var h = 35
var wanted_rooms = 10
var spread = 200
var path   #will be Astar pathfinding object
var start_room = null
var start_point
var end_room = null
var play_mode = false
var player = null
var dead_ends = []
var dead_end_rooms = []
onready var Map = $TileMap

func _ready():
	randomize()
	makeRooms()

func makeRooms():
	for i in range(num_rooms):
		var pos = Vector2(rand_range(-spread, spread),rand_range(-spread, spread))
		var r = Room.instance()
		r.makeRoom(pos, Vector2(w,h)*tile_size)
		$Rooms.add_child(r)
	#wait for moving to stop
	yield(get_tree().create_timer(1.1), "timeout")
	#cull the rooms
	for i in num_rooms - wanted_rooms:
		remove_room(rand_range(0,$Rooms.get_child_count()))
	#assing each room position
	var room_positions = []
	for room in $Rooms.get_children():
		room_positions.append(Vector2(room.position.x, room.position.y))
	path = find_mst(room_positions)
	make_map()

func remove_room(rand_room):
	$Rooms.get_child(rand_room).free()

#func _draw():
	#give each room outline so visible
	#for room in $Rooms.get_children():
	#	draw_rect(Rect2(room.position - room.size, room.size * 2), Color(32,228,0), false)
	#if path:
	#	for p in path.get_points():
	#		for c in path.get_point_connections(p):
	#			var pp = path.get_point_position(p)
	#			var cp = path.get_point_position(c)
	#			draw_line(Vector2(pp.x, pp.y), Vector2(cp.x, cp.y), Color(0.86, 0.08, 0.24, 1), 15, true)

#func _process(delta):
#	update()

#func _input(event):
#	if event.is_action_pressed('ui_focus_next'):
#		make_map()
#	if event.is_action_pressed('ui_cancel'):
#		if !play_mode:
#			player = Player.instance()
#			add_child(player)
#			player.position = path.get_point_position(start_point)
#			play_mode = true

func find_mst(nodes):
	#Prim's algorithm
	var path = AStar2D.new()
	path.add_point(path.get_available_point_id(), nodes.pop_front())
	#repeat until no more nodes
	while nodes:
		var min_dist = INF #min distance so far
		var min_p = null #position of closest
		var p = null #current position
		for p1 in path.get_points():
			p1 = path.get_point_position(p1)
			for p2 in nodes:
				if p1.distance_to(p2) < min_dist:
					min_dist = p1.distance_to(p2)
					min_p = p2
					p = p1
		var n = path.get_available_point_id()
		path.add_point(n, min_p)
		path.connect_points(path.get_closest_point(p), n)
		nodes.erase(min_p)
	return path

func make_map():
	Map.clear()
	#fill area w/ wall tiles, then clear out rooms
	var full_rect = Rect2()
	for room in $Rooms.get_children():
		var r = Rect2(room.position-room.size, room.get_node("CollisionShape2D").shape.extents*2)
		full_rect = full_rect.merge(r)
	var topleft = Map.world_to_map(full_rect.position)
	var bottomright = Map.world_to_map(full_rect.end)
	for x in range(topleft.x, bottomright.x):
		for y in range(topleft.y, bottomright.y):
			Map.set_cell(x,y,0)
	# clear out rooms & corridors
	var corridors = []
	for room in $Rooms.get_children():
		var s = (room.size / tile_size).floor()
		var pos = Map.world_to_map(room.position)
		var ul = (room.position / tile_size).floor() - s
		for x in range (2, s.x * 2 - 1):
			for y in range (2, s.y * 2 - 1):
				Map.set_cell(ul.x + x, ul.y + y, 2)
		var p = path.get_closest_point(Vector2(room.position.x, room.position.y))
		for conn in path.get_point_connections(p):
			if not conn in corridors:
				var start = Map.world_to_map(Vector2(path.get_point_position(p).x, path.get_point_position(p).y))
				var end = Map.world_to_map(Vector2(path.get_point_position(conn).x, path.get_point_position(conn).y))
				carve_path(start, end)
		corridors.append(p)
	# find dead ends
	for point in path.get_points():
		var connections = path.get_point_connections(point)
		if connections.size() == 1:
			dead_ends.append(point)
	# extend to rooms, not just points
	for room in $Rooms.get_children():
		for dead_end_point in dead_ends:
			if Map.world_to_map(room.position) == Map.world_to_map(path.get_point_position(dead_end_point)):
				dead_end_rooms.append(room)
	for room in dead_end_rooms:
		var s = (room.size / tile_size).floor()
		var ul = (room.position / tile_size).floor() - s
		for x in range (2, s.x * 2 - 1):
			for y in range (2, s.y * 2 - 1):
				Map.set_cell(ul.x + x, ul.y + y, 1)
	find_start_room()


func carve_path(pos1, pos2):
	var x_diff = sign(pos2.x - pos1.x)
	var y_diff = sign(pos2.y - pos1.y)
	if x_diff == 0:
		x_diff = pow(-1.0, randi() % 2)
	if y_diff == 0:
		y_diff = pow(-1.0, randi() % 2)
	var x_y = pos1
	var y_x = pos2
	if (randi() % 2) > 0: 
		x_y = pos2
		y_x = pos1
	for x in range (pos1.x, pos2.x, x_diff):
		Map.set_cell(x, x_y.y, 2)
		Map.set_cell(x, x_y.y + y_diff, 2)
		Map.set_cell(x, x_y.y + 2*y_diff, 2)
		Map.set_cell(x, x_y.y + 3*y_diff, 2)
		Map.set_cell(x, x_y.y - y_diff, 2)
		Map.set_cell(x, x_y.y - 2*y_diff, 2)
		Map.set_cell(x, x_y.y - 3*y_diff, 2)
	for y in range (pos1.y, pos2.y, y_diff):
		Map.set_cell(y_x.x, y, 2)
		Map.set_cell(y_x.x + x_diff, y, 2)
		Map.set_cell(y_x.x + 2*x_diff, y, 2)
		Map.set_cell(y_x.x + 3*x_diff, y, 2)
		Map.set_cell(y_x.x - x_diff, y, 2)
		Map.set_cell(y_x.x - 2*x_diff, y, 2)
		Map.set_cell(y_x.x - 3*x_diff, y, 2)

func find_start_room():
	start_point = dead_ends[randi() % dead_ends.size()]
	for room in $Rooms.get_children():
		var r_pos = Map.world_to_map(room.position)
		var p_pos = Map.world_to_map(path.get_point_position(start_point))
		if r_pos == p_pos:
			start_room == room
	player = Player.instance()
	add_child(player)
	player.position = path.get_point_position(start_point)
	play_mode = true
