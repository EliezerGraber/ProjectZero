extends Node2D

export var max_hp: int
var cur_hp: int

var fire_timer = null
var burn_timer = null
var freeze_timer = null
var burning = false
var frozen = false

func _ready():
	fire_timer = Timer.new()
	add_child(fire_timer)
	burn_timer = Timer.new()
	add_child(burn_timer)
	freeze_timer = Timer.new()
	add_child(freeze_timer)
	
func _process(delta):
	pass
		
func c_hit(damage):
	if(damage >= cur_hp):
		call_deferred('m_die')
	else:
		call_deferred('m_damage', damage)

func burn(t):
	fire_timer.connect("timeout", self, "extinguish")
	fire_timer.set_wait_time(t)
	fire_timer.set_one_shot(true)
	fire_timer.start()
	
	burn_timer.connect("timeout", self, "c_hit", 0.25)
	burn_timer.set_wait_time(2)
	burn_timer.set_one_shot(false)
	burn_timer.start()
	
	burning = true
	$Fire.visible = true

func freeze(t):
	freeze_timer.connect("timeout", self, "melt")
	freeze_timer.set_wait_time(t)
	freeze_timer.set_one_shot(true)
	freeze_timer.start()
	
	frozen = true
	$Freeze.visible = true
	
func extinguish():
	burn_timer.stop()
	burning = false
	$Fire.visible = false
	
func melt():
	frozen = false
	$Freeze.visible = false

func m_die():
	print('dead')
	cur_hp = 0
	get_parent().queue_free()
	
func m_damage(damage):
	cur_hp = cur_hp - damage
	print('hit: %d/%d' % [cur_hp, max_hp])
