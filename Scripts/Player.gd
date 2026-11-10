extends CharacterBody3D


const SPEED = 7.0
const JUMP_VELOCITY = 7.5
const SENSITIVITY = 0.003

const BOB_FREQ = 2.5
const BOB_AMP = 0.05
var bob_progress:float = 0.0


@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction:Vector3 = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	bob_progress += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(bob_progress);

	move_and_slide()

func _headbob(prog) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(prog*BOB_FREQ)*BOB_AMP
	pos.x = cos(prog*BOB_FREQ/2)*BOB_AMP
	
	return pos
	
