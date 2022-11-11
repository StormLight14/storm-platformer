extends KinematicBody2D

onready var sprite = $PlayerSprite/Sprite
onready var animation = $PlayerSprite/AnimationPlayer
onready var hitbox_col = $Combat/Hitbox/HitboxShape
onready var hitbox = $Combat/Hitbox
onready var hurtbox = $Combat/Hurtbox
onready var col_shape = $PlayerCollision

export(Resource) var playerVal

var can_be_hit = true

var velocity = Vector2.ZERO
var state = IDLE
var direction = "right"
var safe_pos = Vector2.ZERO

enum {
	IDLE,
	MOVE,
	ATTACK,
}

func _ready():
	randomize();
	
	safe_pos = global_position;
	hitbox.damage = playerVal.damage;
	hitbox.knockback_strength = playerVal.knockback_strength;
	hitbox.knockback_vector = Vector2(1, 0);

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ATTACK:
			attack_state(delta)
		IDLE:
			idle_state(delta)

	velocity = move_and_slide(velocity, Vector2.UP)

func movement(delta):
	velocity.x = (Input.get_action_strength("right") - Input.get_action_strength("left")) * playerVal.speed * delta
	
	if velocity.y < playerVal.max_gravity:
		velocity.y += playerVal.gravity * delta
		
	if velocity.x > 0 and direction != "right":
		flip_all();
		direction = "right";

	if velocity.x < 0 and direction != "left":
		flip_all();
		direction = "left";

	if velocity.x == 0 and velocity.y == 0:
		animation.stop(true);
		
	if is_on_floor():
		if Input.is_action_pressed("up"):
			if state != ATTACK:
				animation.stop(true);
			velocity.y = -playerVal.jump_strength;
		if state != ATTACK:
			if Input.is_action_pressed("right") or Input.is_action_pressed("left"):
				animation.current_animation = "Run";
	else:
		if animation.current_animation == "Run" and state != ATTACK:
			animation.stop(true);
		if global_position.y > 500:
			global_position = safe_pos;

func flip_all():
	if sprite.flip_h == false:
		sprite.flip_h = true;
		hitbox.knockback_vector = Vector2(-1, 0);
	else:
		sprite.flip_h = false;
		hitbox.knockback_vector = Vector2(1, 0);
		
	hitbox.position.x *= -1
	hurtbox.position.x *= -1
	col_shape.position.x *= -1

func attack_input():
	if Input.is_action_pressed("SwordAttack") and state != ATTACK:
		state = ATTACK;
		
		var rand_num = int(round(rand_range(0, 3)));
		if rand_num == 0:
			hitbox.damage = round(playerVal.damage * rand_range(1.6, 2.0));
			hitbox.is_critical = true;
		else:
			hitbox.damage = round(playerVal.damage * rand_range(0.8, 1.2));
			hitbox.is_critical = false;
			
		hitbox_col.disabled = false;
		

func move_state(delta):
	if velocity.y < 0:
		animation.current_animation = "Jump";
	elif velocity.y > 0:
		animation.current_animation = "Fall";
	else:
		if velocity.x != 0:
			animation.current_animation = "Run";
		else:
			state = IDLE;
	
	attack_input();
	movement(delta);

func attack_state(delta):
	movement(delta);
	animation.current_animation = "SwordAttack";
	hitbox.attacker_pos = global_position;
	hitbox.is_attacking = true;

func idle_state(delta):
	animation.current_animation = "Idle";
	
	attack_input();
	movement(delta);
	if velocity.x != 0 or velocity.y != 0:
		state = MOVE;
	
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "SwordAttack":
		animation.stop(true);
		state = MOVE;
		hitbox_col.disabled = true;
		hitbox.is_attacking = false;
