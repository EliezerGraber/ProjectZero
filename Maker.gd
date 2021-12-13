extends RigidBody2D

var size 

func makeRoom(_pos, _size):
	position = _pos
	size = _size
	var s = RectangleShape2D.new()
	s.extents = size
	$CollisionShape2D.shape = s
