extends CharacterBody2D

@export var _run_speed: float = 100;
@export var _acceleration: float = 500;
@export var _friction: float = 500;
@export var _roll_speed: float = 130;

var _roll_vector: Vector2 = Vector2.RIGHT;

@onready var animationTree = $AnimationTree;
@onready var animationState = animationTree.get("parameters/playback");

enum states {
	MOVE,
	ROLL
}

var _current_state: states;

func _ready():
	_current_state = states.MOVE;
	animationTree.active = true;

## Called when player input is detected.
## @param event: InputEvent
## @return void
func _input(event):
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		return;

	# Only process input if the player is in the MOVE state.
	if _current_state == states.MOVE:
		# If the player presses the roll button, then the player should roll.
		if event.is_action_pressed("roll"):
			# sets the _current_state to states.ROLL
			_current_state = states.ROLL;
			

# delta = time between frames
func _physics_process(delta):
	match _current_state:
		states.MOVE:
			move(delta);
		states.ROLL:
			roll();
			
# delta = time between frames
# This function will move the player according to the player's input.
# @param delta: float
# @return void
func move(delta: float):
	var input_vector = Vector2.ZERO;

	# Get input vector from player input.
	# Input.get_action_strength("move_right") - Input.get_action_strength("move_left") will return 0 if neither action is pressed, 
	# 1 if move_right is pressed, -1 if move_left is pressed, and a value between -1 and 1 if both actions are pressed.
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left");

	# Input.get_action_strength("move_down") - Input.get_action_strength("move_up") will return 0 if neither action is pressed,
	# 1 if move_down is pressed, -1 if move_up is pressed, and a value between -1 and 1 if both actions are pressed.
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up");

	# Normalize input vector to prevent diagonal movement from being faster.
	input_vector = input_vector.normalized();

	# If input_vector is zero, then the player is not pressing any movement keys.
	if input_vector == Vector2.ZERO:
		animationTree.set("parameters/Idle/blend_position", input_vector);
		animationState.travel("Idle");

		# If the player is not pressing any movement keys, then the player should slow down.
		# move_toward() will move the player toward the target velocity, but will not exceed the target velocity.
		velocity = velocity.move_toward(Vector2.ZERO, _friction * delta);

		# move_and_slide() will move the player according to the velocity, and will also apply gravity.
		move_and_slide();
		return;

	# This will be used in the roll() function.
	# This will be used to determine which direction the player should roll.
	_roll_vector = input_vector;

	animationTree.set("parameters/Walk/blend_position", input_vector);
	animationTree.set("parameters/Roll/blend_position", input_vector);

	animationState.travel("Walk");

	# If the player is pressing movement keys, then the player should speed up.
	# move_toward() will move the player toward the target velocity, but will not exceed the target velocity.
	velocity = velocity.move_toward(input_vector * _run_speed, _acceleration * delta);
	
	# move_and_slide() will move the player according to the velocity, and will also apply gravity.
	# move_and_slide() will also stop the player from moving if the player is colliding with a wall.
	move_and_slide();

## Called when the player presses the roll button.
## @return void
func roll():
	velocity = _roll_vector * _roll_speed;
	animationState.travel("Roll");
	move_and_slide();

## Called when the roll animation ends.
## @return void
func on_roll_ended():
	_current_state = states.MOVE;
