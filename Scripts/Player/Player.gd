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
	#generate new random stuff every game launch
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
	
	#do gravity and increase speed if not max
	if velocity.y < playerVal.max_gravity:
		velocity.y += playerVal.gravity * delta
		
	#called if direction changes
	if velocity.x > 0 and direction != "right":
		flip_all();
		direction = "right";
	if velocity.x < 0 and direction != "left":
		flip_all();
		direction = "left";
	
	#stop animation if not moving
	if velocity.x == 0 and velocity.y == 0:
		animation.stop(true);
		
	if is_on_floor():
		#jump on any up key pressed
		if Input.is_action_pressed("up"):
			if state != ATTACK:
				animation.stop(true);
			velocity.y = -playerVal.jump_strength;
		#set animation to run when moving, if not attacking
		if state != ATTACK:
			if Input.is_action_pressed("right") or Input.is_action_pressed("left"):
				animation.current_animation = "Run";
	else:
		#cancel running animation if in the air
		if animation.current_animation == "Run":
			animation.stop(true);
		
		#teleport back to last checkpoint if falls
		if global_position.y > 500:
			global_position = safe_pos;

func flip_all():
	#flip sprite and knockback direction
	if sprite.flip_h == false:
		sprite.flip_h = true;
		hitbox.knockback_vector = Vector2(-1, 0);
	else:
		sprite.flip_h = false;
		hitbox.knockback_vector = Vector2(1, 0);
		
	#flip all collisions to match sprite
	hitbox.position.x *= -1
	hurtbox.position.x *= -1
	col_shape.position.x *= -1

func attack_input():
	#if not already attacking, call
	if Input.is_action_pressed("SwordAttack") and state != ATTACK:
		state = ATTACK;
		
		#generate random number
		var rand_num = int(round(rand_range(0, 3)));
		if rand_num == 0:
			#set to critical hit if 0 chosen
			#damage has chance to be a bit higher or lower
			hitbox.damage = round(playerVal.damage * rand_range(1.6, 2.0));
			hitbox.is_critical = true;
		else:
			#else set damage to be normal
			#damage has chance to be a bit higher or lower
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

func _on_hit():
	animation.current_animation = "Hit";
