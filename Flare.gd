extends Area2D

var _timer = null

func _ready():
	_timer = Timer.new()
	add_child(_timer)
	
	_timer.connect("timeout", self, "die")
	_timer.set_wait_time(2.0)
	_timer.set_one_shot(true)
	_timer.start()

func _physics_process(delta):
	print("Burnt:")
	for body in get_overlapping_bodies():
		if body != get_parent() and body is KinematicBody2D:
			body.get_child("CombatComponent").burn(6)
			print(body.name)

func die():
	queue_free()
