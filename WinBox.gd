extends Area2D

var active_ = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	for body in get_overlapping_bodies():
		if body.name == "Player" and active_ == true:
			get_tree().change_scene("res://WinScreen.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
