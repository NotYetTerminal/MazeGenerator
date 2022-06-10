extends Camera

var direction: Vector3 = Vector3.ZERO
var move_speed: float = 0.5
var zoom_speed: float = 5.0
var zoom_size: float = 1.0

# puts camera in intital position
# in the centre of the maze
func give_size(floor_width: int, floor_length: int) -> void:
	zoom_size = max(floor_width, floor_length) * 1.1
	size = zoom_size
	translation = Vector3((floor_width / 2.0) - 0.5, 20, (floor_length / 2.0) - 0.5)

# moves the camera
func _physics_process(delta: float) -> void:
	direction = Vector3.ZERO
	
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_backward"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	
	direction = direction.normalized()
	translation += direction * move_speed * zoom_size * delta
	
	if Input.is_action_just_released("zoom_in"):
		zoom_size -= zoom_speed * zoom_size * delta
		size = zoom_size
	if Input.is_action_just_released("zoom_out"):
		zoom_size +=  zoom_speed * zoom_size * delta
		size = zoom_size
