extends KinematicBody2D

onready var sprite = $PlayerSprite/Sprite
onready var animation = $PlayerSprite/AnimationPlayer

export var speed = 700 * 10
export var gravity = 300
export var max_gravity = 400
export var jump_strength = 180

var velocity = Vector2.ZERO
var state = IDLE

enum {
	IDLE,
	MOVE,
	ATTACK,
}

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
	velocity.x = (Input.get_action_strength("right") - Input.get_action_strength("left")) * speed * delta
	
	if velocity.y < max_gravity :
		velocity.y += gravity * delta

	if velocity.x < 0:
		sprite.flip_h = true;
	elif velocity.x > 0:
		sprite.flip_h = false;

	if velocity.x == 0 and velocity.y == 0:
		animation.stop(true);
		
	if is_on_floor():
		if Input.is_action_pressed("up"):
			animation.stop(true);
			velocity.y = -jump_strength;
			
		if Input.is_action_pressed("right") or Input.is_action_pressed("left"):
			animation.current_animation = "Run";
	else:
		if animation.current_animation == "Run":
			animation.stop(true);

func move_state(delta):
	if velocity.y < 0:
		animation.current_animation = "Jump";
	elif velocity.y > 0:
		animation.current_animation = "Fall";
	else:
		if velocity.x != 0:
			print("x velocity is not 0");
			animation.current_animation = "Run";
		else:
			print("x velocity is 0");
			state = IDLE;
	
	movement(delta);
	

func attack_state(delta):
	movement(delta);
	animation.current_animation = "SwordAttack";
	

func idle_state(delta):
	animation.current_animation = "Idle";
	
	movement(delta);
	if velocity.x != 0 or velocity.y != 0:
		state = MOVE
	
