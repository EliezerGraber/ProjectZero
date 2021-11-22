extends KinematicBody2D

var _timer = null
export(Resource) var BULLET
export(NodePath) onready var gun = get_node(gun) as Position2D
export(NodePath) onready var bullet_parent = get_node(bullet_parent)
var dir: int

func _ready():
	_timer = Timer.new()
	add_child(_timer)
	
	_timer.connect("timeout", self, "shoot_test")
	_timer.set_wait_time(0.5)
	_timer.set_one_shot(false) # Make sure it loops
	_timer.start()
	dir = 1
	
func _process(delta):
	move_and_slide(Vector2(0, 100) * dir)
	if(position.y < 100):
		dir = 1
	if(position.y > 500):
		dir = -1

func shoot_test():
	for i in range(0, 360, 45):
		m_shoot(i)
#takes in angle to shoot at in degrees
func m_shoot(angle:int):
	var b = BULLET.instance()
	bullet_parent.add_child(b)
	b.transform = Transform2D(deg2rad(angle), position).translated(Vector2(55, 0))
	b.direction = Vector2(1,0).rotated(deg2rad(angle))