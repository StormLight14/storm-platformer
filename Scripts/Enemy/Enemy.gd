extends KinematicBody2D

onready var sprite = $EnemySprite/Sprite
onready var animation = $EnemySprite/AnimationPlayer
onready var navigation_agent = $NavigationAgent2D
onready var invincible_timer = $InvincibleTimer

export var speed = 7000
export var health = 20
export var gravity = 300
export var max_gravity = 400
export var jump_strength = 180
export var friction = 300

var safe_pos = Vector2.ZERO
var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

var can_be_hit = true

func _ready():
	sprite.frame = 0;
	safe_pos = global_position;

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, friction * delta)
	knockback = move_and_slide(knockback)
	
	movement(delta);
	
	velocity = move_and_slide(velocity, Vector2.UP);
	if global_position.y > 500:
		global_position = safe_pos;

func movement(delta):	
	if velocity.y < max_gravity:
		velocity.y += gravity * delta;
		
				
func create_effect(effect_type, value="", type=""):
	match effect_type:
		"float_text":
			var effect_scene = preload("res://Scenes/Effects/TextFloat.tscn").instance();
			effect_scene.text = value;
			effect_scene.velocity = Vector2(rand_range(-50, 50), -100);
			if type == "critical_hit":
				effect_scene.modulate = Color(rand_range(1, 1), rand_range(0.2, 0.5), rand_range(0.2, 0.5), 1.0);
			effect_scene.global_position = global_position;
			get_tree().current_scene.add_child(effect_scene);
		"death":
			queue_free();

func _on_Hurtbox_area_entered(area):
	if can_be_hit == true:
		knockback = area.knockback_vector * area.knockback_strength;
		
		animation.play("hit");
		if area.is_critical == true:
			create_effect("float_text", area.damage, "critical_hit");
		else:
			create_effect("float_text", area.damage);
			
		health -= area.damage;
		if health <= 0:
			create_effect("death");
			
		invincible_timer.start();
		can_be_hit = false;


func _on_InvincibleDelay_timeout():
	can_be_hit = true;
	
