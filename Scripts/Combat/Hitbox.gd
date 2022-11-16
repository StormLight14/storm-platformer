extends Area2D

onready var hitbox_parent = get_parent()

var damage = 0
var is_critical = false

var attacker_pos = Vector2.ZERO
var knockback_vector = Vector2.ZERO
var knockback_strength = 1
var is_attacking = false

func _process(_delta):
	if hitbox_parent:
		attacker_pos = hitbox_parent.global_position
