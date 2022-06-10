extends Node

var width: int = 100
var length: int = 100

var iterate_pressed: bool = false

# uses nested lists to store states
# 0 wall
# 1+ floor
var floor_states: Array = []

# startup stuff
func _ready() -> void:
	# randomizes seed
	randomize()
	
	# initial setup
	_set_up_maze_size()

# wates if he iterate button is pressed down
func _process(_delta: float) -> void:
	if iterate_pressed:
		floor_states = $AutomataGenerator.create_maze(1)
		_update_floor_states(floor_states)

# updates the floor texture
func _update_floor_states(states: Array) -> void:
	$MazeFloor.update_floor_states(states)

# sets up the new maze size
func _set_up_maze_size():
	$Camera.give_size(width, length)
	$MazeFloor.set_maze_size(width, length)
	$AutomataGenerator.set_parameters(width, length)
	floor_states = $AutomataGenerator.create_maze(0)
	_update_floor_states(floor_states)

# generates a new base noise
func _on_NewNoiseButton_pressed():
	floor_states = $AutomataGenerator.create_maze(0)
	_update_floor_states(floor_states)

# sets iteration to true
func _on_IterateButton_button_down():
	iterate_pressed = true

# sets iteration to false
func _on_IterateButton_button_up():
	iterate_pressed = false

# iterates until walls
func _on_WallIterateButton_pressed():
	floor_states = $AutomataGenerator.create_maze(2)
	_update_floor_states(floor_states)

# colours in spaces
func _on_ColourSpacesButton_pressed():
	$MazeFloor.flush_colours()
	floor_states = $AutomataGenerator.create_maze(3)
	_update_floor_states(floor_states)

# removes walls between spaces
func _on_RemoveWallsButton_pressed():
	floor_states = $AutomataGenerator.create_maze(4)
	_update_floor_states(floor_states)

# sets the size of the maze
func _on_SetSizeButton_pressed():
	width = int($MainUI/SizeSetting/XSpinBox.value)
	length = int($MainUI/SizeSetting/YSpinBox.value)
	_set_up_maze_size()

# does all of the actions together and only renders at the end
func _on_DoAllButton_pressed():
	$MazeFloor.flush_colours()
	floor_states = $AutomataGenerator.auto_create_maze()
	_update_floor_states(floor_states)
