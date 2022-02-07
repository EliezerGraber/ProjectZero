"""
This script controls the dynamic camera.
"""
extends Camera2D

# Radius of the zone in the middle of the screen where the cam doesn't move
export (int) var max_distance = 100

#func input(event: InputEvent):
#	if event is InputEventMouseMotion: # If the mouse moved...
#		var _target = event.position - get_viewport().size * 0.5	# Get the mouse position relative to the middle of the screen
#		self.position = lerp(self.position,$"../Player".position + (_target.normalized() * clamp(_target.length(),0,max_distance) * 0.5),0.1)
func _physics_process(delta):
#	self.position = lerp(self.position,$"../Player".position,.1)
	# CHANGE THIS LATER
	if is_instance_valid($"../Player"):
		self.position = lerp(self.position,$"../Player".position + get_global_mouse_position().normalized(),0.1)
