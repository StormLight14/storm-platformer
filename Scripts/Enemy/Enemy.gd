extends KinematicBody2D

onready var sprite = $EnemySprite/Sprite
onready var animation = $EnemySprite/AnimationPlayer
onready var invincible_timer = $Combat/InvincibleTimer

onready var ledge_check = $MoveCheck/LedgeCheck
onready var side_check = $MoveCheck/SideCheck

export(Resource) var enemyVal
onready var health = enemyVal.health
onready var speed = enemyVal.base_speed

var safe_pos = Vector2.ZERO
var can_be_hit = true

var direction = Vector2.RIGHT
var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

func _ready():
	sprite.frame = 0;
	safe_pos = global_position;

func _physics_process(delta):
	var found_wall = is_on_wall();
	var found_ledge = not ledge_check.is_colliding();

	if found_wall or found_ledge:
		if is_on_floor():
			direction *= -1;
			scale.x *= -1
			
	movement(delta, is_on_floor());
	
	knockback = knockback.move_toward(Vector2.ZERO, enemyVal.friction * delta)
	knockback = move_and_slide(knockback)
	
	velocity = move_and_slide(velocity, Vector2.UP);

func movement(delta, on_floor):	
	if velocity.y < enemyVal.max_gravity:
		velocity.y += enemyVal.gravity * delta;
	
	if on_floor:
		speed += enemyVal.speed_increment;
		if speed > enemyVal.max_speed:
			speed = enemyVal.max_speed;
		velocity.x = direction.x * speed * delta;
	else:
		if global_position.y > 500:
			global_position = safe_pos;
		
				
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
		speed = enemyVal.base_speed;
		
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
