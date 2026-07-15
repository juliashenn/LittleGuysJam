extends CharacterBody3D
class_name Player

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

@onready var grab_point: Marker3D = $Head/Camera3D/GrabPoint

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var ui: UI = $UI
@export var bird_marker: Marker3D
@onready var ambience: AudioStreamPlayer3D = $ambience
@onready var footsteps: AudioStreamPlayer3D = $footsteps
@onready var wand_sound: AudioStreamPlayer3D = $wandSound
var has_bird_following := false

var found_birds : Array[Bird] = []
var enabled := true

#func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	##
func _unhandled_input(event):
	if not enabled:
		return
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))
	if event is InputEventMouseButton:
		if not ui.settings.visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		##get_tree().paused = false

@export var step_interval: float = 0.5
var step_timer := 0.3

var last_sound 
var sounds = [
	preload("res://Assets/Walk/Grass/GRASS - Walk 1.ogg"),
	preload("res://Assets/Walk/Grass/GRASS - Walk 2.ogg"),
	preload("res://Assets/Walk/Grass/GRASS - Walk 3.ogg"),
	preload("res://Assets/Walk/Grass/GRASS - Walk 4.ogg"),
	preload("res://Assets/Walk/Grass/GRASS - Walk 5.ogg"),
	preload("res://Assets/Walk/Grass/GRASS - Walk 6.ogg"),
	preload("res://Assets/Walk/Grass/GRASS - Walk 7.ogg"),
	preload("res://Assets/Walk/Grass/GRASS - Walk 8.ogg"),
	preload("res://Assets/Walk/Grass/GRASS - Walk short 1.ogg"),
	preload("res://Assets/Walk/Grass/GRASS - Walk short 2.ogg"),
	preload("res://Assets/Walk/Grass/GRASS - Walk short 3.ogg"),
	preload("res://Assets/Walk/Grass/GRASS - Walk short 4.ogg"),
	preload("res://Assets/Walk/Grass/GRASS - Walk short 5.ogg"),
	preload("res://Assets/Walk/Grass/GRASS - Walk short 6.ogg"),
	preload("res://Assets/Walk/Grass/GRASS - Walk short 7.ogg"),
	preload("res://Assets/Walk/Grass/GRASS - Walk short 8.ogg"),
]

func play_random_footstep():
	if sounds.size() == 0:
		return
	var new_sound = sounds.pick_random()
	while new_sound == last_sound and sounds.size() > 1:
		new_sound = sounds.pick_random()
	last_sound = new_sound
	footsteps.stream = new_sound
	footsteps.play()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("cancel"):
		freeze()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		ui.show_settings()
		#get_tree().paused = true
	
	if not enabled:
		return
	if Input.is_action_just_pressed("call"):
		call_bird()
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
	
	if is_on_floor() and Vector2(velocity.x, velocity.z).length() > 0.5:
		if velocity.length() > SPRINT_SPEED - 0.5:
			step_timer -= 1.3 * delta
		else:
			step_timer -= delta
		if step_timer <= 0:
			play_random_footstep()
			step_timer = step_interval
	else:
		step_timer = 0.3
	
	
func _headbob(t) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(t * BOB_FREQ) * BOB_AMP 
	pos.x = cos(t * BOB_FREQ/2) * BOB_AMP 
	return pos
	
func conduct_anim():
	anim.play("conduct")

func poke_anim():
	anim.play("poke")
	


func spell_anim():
	anim.play("swirl")
	wand_sound.play(0.0)

func stop_anim():
	anim.stop(false)
	
func disable(): # for cutscenes
	enabled = false
	camera.clear_current(true)
	ambience.stop()

func freeze(): # for ui
	enabled = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func unfreeze():
	enabled = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if not ambience.playing:
		ambience.play(0.0)

func enable():
	enabled = true
	camera.make_current()
	if not ambience.playing:
		ambience.play(0.0)

func end_scene():
	disable()
	ui.credits()

func blink():
	ui.fadeToBlack()
	ui.fadeFromBlack()

func add_bird(bird: Bird) -> int:
	if found_birds.size() == 0:
		give_dialogue(["Little birds can help you carry note sprites to the stage...", 
		"Once a bird returns to the gazebo, press q to call them over one at a time...",
		"Drag a note to the bird, and it'll carry it back for you"])
	var n: int
	if bird not in found_birds:
		n = found_birds.size()
		found_birds.append(bird)
	else:
		n = found_birds.find(bird)
	return n

func call_bird():
	if not has_bird_following:
		for bird in found_birds:
			if not bird.heading_home and not bird.following_player:
				bird.go_to_player()
				has_bird_following = true
				return

func give_dialogue(strs: Array[String]):
	ui.show_dialogue(strs)
