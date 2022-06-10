extends Spatial

var columns: int
var rows: int
var colour_counter: float = 0.0
# uses nested lists to store colours
var floor_colours: Array = []

# stores the number -> colour
var colour_dictionary: Dictionary = {}

# called by main to set size
func set_maze_size(width: int, length: int) -> void:
	columns = width
	rows = length
	_fill_with_black()
	_set_mesh_ratio()
	_render()

# fills the vectors array with black
func _fill_with_black() -> void:
	floor_colours.clear()
	var new_list: Array = []
	for _x in range(columns):
		new_list = []
		for _y in range(rows):
			new_list.append(Color.black)
		floor_colours.append(new_list)

# resets colours array to white
func _reset_colour_to(reset_color: Color = Color.white) -> void:
	for x_index in range(floor_colours.size()):
		for y_index in range(floor_colours[x_index].size()):
			if floor_colours[x_index][y_index] != reset_color:
				floor_colours[x_index][y_index] = reset_color

# sets the mesh side length ratio so it matches up with the maze size
func _set_mesh_ratio():
	var mesh: Mesh = $MeshInstance.get_mesh()
	mesh.set("size", Vector2(columns * 2, rows * 2))
	translation = Vector3((columns / 2.0) - 0.5, -0.5, (rows / 2.0) - 0.5)

# packs the data together and sends it to the shader
func _render() -> void:	
	# packs data into the texture
	var texture = _makeTexture(columns, rows, floor_colours)
	
	# sends the texture over to the shader
	var material = $MeshInstance.get_active_material(0)
	material.set_shader_param("vectors", texture)
	material.set_shader_param("vectorsTextureWidth", float(columns))
	material.set_shader_param("vectorsTextureHeight", float(rows))

#https://www.godotforums.org/discussion/27487/passing-an-array-to-a-shader
# takes in a width and length for the size of the texture
# vectors is an array of Color
# preferably the vectors.size() is width * length to show all data
func _makeTexture(width: int, length: int, array_data: Array) -> ImageTexture:
	var w = width
	var l = length
	var img = Image.new()
	img.create(w, l, false, Image.FORMAT_RGBAF)
	img.lock()
	for x_index in range(array_data.size()):
		for y_index in range(array_data[x_index].size()):
			img.set_pixel(x_index, y_index, array_data[x_index][y_index])
	img.unlock()
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	return tex

# sets the state of the floor tiles
func update_floor_states(floor_states: Array) -> void:
	for x_index in range(floor_states.size()):
		for y_index in range(floor_states[x_index].size()):
			if floor_states[x_index][y_index] == 0:
				floor_colours[x_index][y_index] = Color.black
			elif floor_states[x_index][y_index] == 1:
				floor_colours[x_index][y_index] = Color.white
			else:
				if not (floor_states[x_index][y_index] in colour_dictionary.keys()):
					colour_dictionary[floor_states[x_index][y_index]] = Color(randf(), randf(), randf())
				floor_colours[x_index][y_index] = colour_dictionary[floor_states[x_index][y_index]]
	_render()

# clears out the colour dictionary
# essentially randomizing the next set of colours
func flush_colours() -> void:
	colour_dictionary = {}
