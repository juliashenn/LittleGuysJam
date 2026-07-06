extends CharacterBody3D

var speed 
const WALK_SPEED = 5.0
const SPRINT_SPEED = 7.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.005
const GRAVITY = 10.0

#head bob
const BOB_FREQ = 2.0
const BOB_AMP = 0.05
var tbob = 0.0

#fov
const BASE_FOV = 75.0
const FOV_CHANGE = 0.75

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(40))
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		#get_tree().paused = false

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#get_tree().paused = true

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed 
			velocity.z = direction.z * speed 
		else:
			velocity.x = lerp(velocity.x, direction.x * speed , delta * 20.0)
			velocity.z = lerp(velocity.z, direction.z * speed , delta * 20.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed , delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * speed , delta * 2.0)
	
	#bob
	tbob += delta * velocity.length()* float(is_on_floor())
	camera.transform.origin = _headbob(tbob)
	
	#fov
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED*2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped * float(Input.is_action_pressed("sprint"))
	camera.fov = lerp(camera.fov, target_fov, delta * 7.0)
	
	move_and_slide()
	
	
func _headbob(t) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(t * BOB_FREQ) * BOB_AMP 
	pos.x = cos(t * BOB_FREQ/2) * BOB_AMP 
	return pos
