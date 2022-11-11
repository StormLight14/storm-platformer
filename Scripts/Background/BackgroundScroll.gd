extends ParallaxLayer

export var scroll_speed = 1

func _process(_delta):
	global_position.x += scroll_speed
	
