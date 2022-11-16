extends Node2D

onready var player = get_parent();
onready var hitbox_col = $Hitbox/HitboxShape;
onready var hit_timer = $HitTimer;
onready var invincible_timer = $InvincibleTimer;

signal hit

func _ready():
	connect("hit", player, "_on_hit")

func _on_Hurtbox_area_entered(area):
	invincible_timer.start();
	player.can_be_hit = false;
	
	emit_signal("hit");

func _on_InvincibleTimer_timeout():
	player.can_be_hit = true;
