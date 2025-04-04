class_name Player extends CharacterBody3D

@onready var head = $Head
@onready var crouching_col: CollisionShape3D = $Crouching_col
@onready var standing_col: CollisionShape3D = $Standing_col
@onready var crouch_check_cast: RayCast3D = $CrouchCheckCast
@onready var camera: Camera3D = $Head/neck/Camera
@onready var neck: Node3D = $Head/neck
@onready var fps: Label = $VBoxContainer/FPS
@onready var state: Label = $VBoxContainer/STATE

#States
var walking = false
var sprinting  = false
var crouching = false
var sliding  = false


const JUMP_VELOCITY = 4.5

#SPEEDS
var speed_current = 8.0
var crouch_Speed = 3.0
var walk_speed = 8.0
#CAMERA SENSITIVITY
@export var sens = 0.2
@export var FOV = 75
#PLAYER GRAVITY
var gravity = 9.8

#STATE TRANSITION SPEED
var lerp_speed = 10.0

#MOVEMENT VARIABLES
var direction = Vector3.ZERO

#CROUCH DEPTH
var crouch_depth = -0.8

var CharacterState = "Standing"


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.fov = FOV


func MouseMove(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x) * sens)
		camera.rotate_x(deg_to_rad( -event.relative.y) * sens)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		
func _input(event):
	MouseMove(event)


func _physics_process(delta):
	fps.text = "FPS:" + str(Engine.get_frames_per_second())
	state.text = "State:" + CharacterState
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	
	if Input.is_action_pressed("crouch"):
		if not is_on_floor():
			speed_current = speed_current
		if is_on_floor():
			speed_current = lerp(speed_current, crouch_Speed, delta * 2)
		head.position.y = lerp(head.position.y, 0.5 + crouch_depth, delta*lerp_speed)
		CharacterState = "Crouching"
		standing_col.disabled = true
		crouching_col.disabled = false
	
		crouching = true
		sprinting = false
		walking = false
		
		
	elif !crouch_check_cast.is_colliding():
		standing_col.disabled = false
		crouching_col.disabled = true
		head.position.y = lerp(head.position.y, 0.5, delta*lerp_speed)
		speed_current = walk_speed
		CharacterState = "Standing"
		
		crouching = false
		sprinting = false
		walking = true
	if not is_on_floor():
		velocity.y -= gravity * delta


	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*lerp_speed)
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed_current
			velocity.z = direction.z * speed_current
		
		else:
			velocity.x = move_toward(velocity.x, 0, speed_current)
			velocity.z = move_toward(velocity.z, 0, speed_current)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed_current, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed_current, delta * 3.0)
	if is_on_floor():
		if Input.is_action_pressed("left"):
			neck.rotation.z = lerp(neck.rotation.z, 0.08, delta * 0.5)
		elif Input.is_action_pressed("right"):
			neck.rotation.z = lerp(neck.rotation.z, -0.08, delta * 0.5)
		else:
			neck.rotation.z = lerp(neck.rotation.z, 0.0, delta * 0.5)
	else:
		neck.rotation.z = lerp(neck.rotation.z, 0.0, delta * 0.5)
	
	
	move_and_slide()
