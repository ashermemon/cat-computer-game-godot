extends CharacterBody3D

# basics
const SPRINT_SPEED = 14.5
const WALK_SPEED = 7.0
const JUMP_VELOCITY = 7.5
const SENSITIVITY = 0.003

# bob
const BOB_FREQ = 2.5
const BOB_AMP = 0.05
var bob_progress:float = 0.0

# fov
const BASE_FOV = 95.0
const FOV_MULTIPLIER = 1.7

# wall jump
const WALL_JUMP_FORCE_UP = 4.0
const WALL_JUMP_FORCE_AWAY = 8.0

var speed:float = WALK_SPEED
var last_wall = null

var camera_start_pos: Vector3
var character_start_rot: Vector3

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var character = $"character-gamer2"

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_start_pos = camera.transform.origin
	character_start_rot = character.rotation
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:

		head.rotate_y(-event.relative.x * SENSITIVITY)
		

		camera.rotate_x(-event.relative.y * SENSITIVITY)
		

		var camera_rot = camera.rotation
		camera_rot.x = clamp(camera_rot.x, deg_to_rad(-40), deg_to_rad(60))
		camera.rotation = camera_rot
		

func _physics_process(delta: float) -> void:
	
	character.rotation.y = head.rotation.y + character_start_rot.y
	
	# Add the gravity
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	var wall_normal := get_wall_normal()
	var horizontal_velocity := Vector3(velocity.x, 0, velocity.z)
	var incoming_speed: float = horizontal_velocity.dot(-wall_normal)
	
	var bounce = max(incoming_speed, 1.0)
	
	var can_wall_jump: bool = not last_wall.is_equal_approx(wall_normal) if last_wall else true
	
	if is_on_wall_only() and Input.is_action_just_pressed("jump") and can_wall_jump:
		velocity.x = wall_normal.x * WALL_JUMP_FORCE_AWAY * bounce
		velocity.z = wall_normal.z * WALL_JUMP_FORCE_AWAY * bounce
		velocity.y = WALL_JUMP_FORCE_UP
		last_wall = wall_normal
		#move_and_slide()
		#return

	# Handle sprint
	speed = SPRINT_SPEED if Input.is_action_pressed("sprint") and is_on_floor() else WALK_SPEED

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction:Vector3 = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		last_wall = null
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x *speed, delta *8.0)
			velocity.z = lerp(velocity.z, direction.z *speed, delta *8.0)
	else:
		velocity.x = lerp(velocity.x, direction.x *speed, delta *3.0)
		velocity.z = lerp(velocity.z, direction.z *speed, delta *3.0)
	bob_progress += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = camera_start_pos + _headbob(bob_progress)
	
	
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2 )
	var target_fov = BASE_FOV + FOV_MULTIPLIER * velocity_clamped
	camera.fov =lerp(camera.fov, target_fov, delta * 6.0)

	move_and_slide()
	

func _headbob(prog) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(prog*BOB_FREQ)*BOB_AMP
	pos.x = cos(prog*BOB_FREQ/2)*BOB_AMP
	
	return pos
	
