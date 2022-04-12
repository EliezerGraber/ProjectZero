extends Area2D

var _timer = null

func _ready():
	get_parent().can_move = false
	_timer = Timer.new()
	add_child(_timer)
	
	_timer.connect("timeout", self, "die")
	_timer.set_wait_time(2.0)
	_timer.set_one_shot(true)
	_timer.start()

func _physics_process(delta):
	for body in get_overlapping_bodies():
		if body != get_parent() and body is KinematicBody2D:
			body.get_node("CombatComponent").burn(4)
			print("Burnt: " + body.name)

func die():
	get_parent().can_move = true
	queue_free()
