extends Node

const size_percentage: float = 0.1

const alive_states: Array = [1, 2, 3, 4, 5]
const born_states: Array = [3]

var max_width: int = 0
var max_length: int = 0
var command: int = -1
var iterations_count: int = 0

# uses nested lists to store states
# 0 wall
# 1+ floor
var states: Array = []

onready var generation_label = get_node("../MainUI/Info/GenerationsLabel")
onready var time_label = get_node("../MainUI/Info/TimeTakenLabel")

# sets script parameters
func set_parameters(width: int, length: int) -> void:
	max_width = width
	max_length = length

# creates a maze based on cellular automata
func create_maze(command_number: int) -> Array:
	var start_time: int = OS.get_system_time_msecs()
	command = command_number
	
	match(command):
		0:
			# clears the array
			_fill_empty_states()
			# start off with random centre
			_make_random_noise()
			iterations_count = 0
		1:
			# iterate the cells
			var _t = _iterate_generation()
			iterations_count += 1
			
		2:
			# iterate until all four walls have been modified
			while not _check_all_walls_changed():
				iterations_count += 1
				# cellular automata may stop depending on the seed
				if not _iterate_generation():
					break
		3:
			# colours in all of the different spaces
			_colour_spaces()
		4:
			# removes walls between spaces
			_remove_walls()
	
	# update ui with info
	generation_label.text = "Generations: " + str(iterations_count)
	time_label.text = "Time Taken: " + str(OS.get_system_time_msecs() - start_time) + "ms"
	return states

# auto creates the whole maze in one go
func auto_create_maze() -> Array:
	var start_time: int = OS.get_system_time_msecs()
	
	# clears the array
	_fill_empty_states()
	
	# start off with random centre
	_make_random_noise()
	iterations_count = 0
	
	# iterate the cells
	var _t = _iterate_generation()
	iterations_count += 1
	
	# iterate until all four walls have been modified
	while not _check_all_walls_changed():
		iterations_count += 1
		# cellular automata may stop depending on the seed
		if not _iterate_generation():
			break
	
	# colours in all of the different spaces
	_colour_spaces()
	
	# removes walls between spaces
	_remove_walls()
	
	# clears the spaces
	_colour_spaces()
	
	# update ui with info
	generation_label.text = "Generations: " + str(iterations_count)
	time_label.text = "Time Taken: " + str(OS.get_system_time_msecs() - start_time) + "ms"
	return states

# colours in all of the different spaces
func _colour_spaces() -> void:
	var labeled_locs: Array = []
	var new_x: Array = []
	var available_colours: Array = []
	for index in range(2, 100):
		available_colours.append(index)
	var current_colour: int = 0
	var valid_neighbour_x: bool = false
	var valid_neighbour_y: bool = false
	var deleting_colour: int = 1
	
	for x_check in range(max_width):
		new_x = []
		for y_check in range(max_length):
			valid_neighbour_x = false
			valid_neighbour_y = false
			if states[x_check][y_check]:
				if x_check != 0:
					if labeled_locs[x_check - 1][y_check] != 0:
						valid_neighbour_x = true
						
				if y_check != 0:
					if new_x[y_check - 1] != 0:
						valid_neighbour_y = true
				
				if valid_neighbour_x and valid_neighbour_y:
					if labeled_locs[x_check - 1][y_check] != new_x[y_check - 1]:
						deleting_colour = labeled_locs[x_check - 1][y_check]
						available_colours.insert(0, deleting_colour)
						for x_index in range(labeled_locs.size()):
							for y_index in range(labeled_locs[x_index].size()):
								if labeled_locs[x_index][y_index] == deleting_colour:
									labeled_locs[x_index][y_index] = new_x[y_check - 1]
						for x_index in range(y_check):
							if new_x[x_index] == deleting_colour:
								new_x[x_index] = new_x[y_check - 1]
						
					new_x.append(new_x[y_check - 1])
				elif valid_neighbour_x:
					new_x.append(labeled_locs[x_check - 1][y_check])
				elif valid_neighbour_y:
					new_x.append(new_x[y_check - 1])
				else:
					if available_colours.size() == 0:
						for index in range(current_colour + 1, current_colour + 21):
							available_colours.append(index)
					current_colour = available_colours.pop_front()
					new_x.append(current_colour)
			else:
				new_x.append(0)
		labeled_locs.append(new_x)
	
	# remaps all of the colours to start from 2 going up
	var colour_index: int = 1
	var mapper: Dictionary = {}
	for x_index in range(labeled_locs.size()):
		for y_index in range(labeled_locs[x_index].size()):
			if labeled_locs[x_index][y_index] != 0:
				if not (labeled_locs[x_index][y_index] in mapper.keys()):
					colour_index += 1
					mapper[labeled_locs[x_index][y_index]] = colour_index
				labeled_locs[x_index][y_index] = mapper[labeled_locs[x_index][y_index]]
	
	states = labeled_locs

# removes the walls between disconnected spaces
func _remove_walls() -> void:
	var same_walls: Dictionary = {}
	var neighbours: Array = []
	var breaking: bool = false
	var previous_num: int = -1
	var index: int = 0
	var max_colours: int = 0
	
	# collects all of the walls that have a neighbouring coloured cell
	for x in range(max_width):
		for y in range(max_length):
			if states[x][y] == 0:
				neighbours = []
				if x != 0:
					if states[x - 1][y] != 0:
						neighbours.append(states[x - 1][y])
				if x != max_width - 1:
					if states[x + 1][y] != 0:
						neighbours.append(states[x + 1][y])
				if y != 0:
					if states[x][y - 1] != 0:
						neighbours.append(states[x][y - 1])
				if y != max_length - 1:
					if states[x][y + 1] != 0:
						neighbours.append(states[x][y + 1])
				
				breaking = false
				for value in neighbours:
					for value_2 in neighbours:
						if value != value_2:
							breaking = true
							break
					if breaking:
						break
				
				if breaking:
					neighbours.sort()
					while index < neighbours.size():
						if index != 0:
							if previous_num == neighbours[index]:
								neighbours.pop_at(index)
								index -= 1
						previous_num = neighbours[index]
						index += 1
					
					if neighbours.size() == 2:
						if neighbours in same_walls.keys():
							same_walls[neighbours].append([x, y])
						else:
							same_walls[neighbours] = [[x, y]]
			else:
				if states[x][y] > max_colours:
					max_colours = states[x][y]
	
	# removes spaces with no neighbour walls
	if max_colours != 2:
		for colour_index in range(2, max_colours + 1):
			breaking = false
			for pairs in same_walls.keys():
				if colour_index in pairs:
					breaking = true
					break
			if not breaking:
				for x_index in range(states.size()):
					for y_index in range(states[x_index].size()):
						if states[x_index][y_index] == colour_index:
							states[x_index][y_index] = 0
	
	# clears a random wall from available pair walls
	var chosen_loc: Array = []
	for key in same_walls.keys():
		chosen_loc = same_walls[key][randi() % same_walls[key].size()]
		states[chosen_loc[0]][chosen_loc[1]] = 1

# iterates one generation
func _iterate_generation() -> bool:
	# get the number of alive neighbours of each square
	var alive_neighbours: Array = _get_alive_neighbours()
	
	# merge two lists together of new cells
	var new_state_cells: Array = []
	var new_list: Array = []
	var value: int = 0
	for x_index in range(states.size()):
		new_list = []
		for y_index in range(states[x_index].size()):
			value = alive_neighbours[x_index][y_index]
			new_list.append(int((value in born_states) or 	# get all of the newly born cells
								(value in alive_states and	# get all of the still alive cells
								states[x_index][y_index]))) # get only the alive cells
		new_state_cells.append(new_list)
	
	var changed: bool = states != new_state_cells
	if changed:
		states = new_state_cells
	
	return changed

# gets the number of alive neighbours for each cell
func _get_alive_neighbours() -> Array:
	# set up blank array
	var out_array: Array = []
	var new_list: Array = []
	for x_index in range(states.size()):
		new_list = []
		for _y_index in range(states[x_index].size()):
			new_list.append(0)
		out_array.append(new_list)
	
	# add to each cell depending on neighbouring cells
	for x_index in range(states.size()):
		for y_index in range(states[x_index].size()):
			if states[x_index][y_index] != 0:
				if x_index != 0:
					out_array[x_index - 1][y_index] += 1			# left
					if y_index != 0:
						out_array[x_index - 1][y_index - 1] += 1	# bottom_left
					if y_index != max_length - 1:
						out_array[x_index - 1][y_index + 1] += 1	# up_left
				
				if x_index != max_width - 1:
					out_array[x_index + 1][y_index] += 1			# right
					if y_index != 0:
						out_array[x_index + 1][y_index - 1] += 1	# bottom_right
					if y_index != max_length - 1:
						out_array[x_index + 1][y_index + 1] += 1	# up_right
				
				if y_index != 0:
					out_array[x_index][y_index - 1] += 1			# bottom
				
				if y_index != max_length - 1:
					out_array[x_index][y_index + 1] += 1			# up
			
	return out_array

# checks if at least one cell at each wall has changed
func _check_all_walls_changed() -> bool:
	var bottom_changed = _OR(states[0])
	var left_changed = _OR(_get_across_y(0, states))
	var top_changed = _OR(states[-1])
	var right_changed = _OR(_get_across_y(-1, states))
	
	return top_changed and left_changed and bottom_changed and right_changed

# fills the states array with all dead cells
func _fill_empty_states() -> void:
	states.clear()
	var new_list: Array = []
	for x in max_width:
		new_list = []
		for y in max_length:
			new_list.append(0)
		states.append(new_list)

# fills the centre of the grid with random noise
# based on size_percentage
func _make_random_noise() -> void:
	# get centre square size
	var centre_width: int = int(ceil(max_width * size_percentage))
	var centre_length: int = int(ceil(max_length * size_percentage))
	
	# get true centre
	var x_centre: float = (max_width + 1) / 2.0
	var y_centre: float = (max_length + 1) / 2.0
	
	# get the starting position of inserting the noise
	var x_start: int = int(floor(x_centre - (centre_width / 2.0)))
	var y_start: int = int(floor(y_centre - (centre_length / 2.0)))
	
	# insert random noise
	for x_index in range(centre_width):
		for y_index in range(centre_length):
			states[x_start + x_index][y_start + y_index] = randi() % 2

# gets a column of array
func _get_across_y(index: int, full_array: Array) -> Array:
	var out_array: Array = []
	for row in full_array:
		out_array.append(row[index])
	return out_array

# performs boolean OR operation on all elements
func _OR(items: Array) -> bool:
	for value in items:
		if value:
			return true
	return false
