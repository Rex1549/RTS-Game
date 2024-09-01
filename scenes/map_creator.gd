extends Node3D


# Chunk object
const MAP_CHUNK :Resource = preload("res://scenes/terrain/map_chunk.tscn")

# Texture data
@export var heightmap = Texture2D
@export var diffuse :Array[Texture2D]

# Terrain settings
@export var size :Vector2i = Vector2i(2, 2):
	set(value):
		if value[0] < 1 or value[1] < 1: printerr("Negative terrain size specified !!!")
		else: size = value
	get:
		return size
var heightmaps :Array[PackedFloat32Array]

# Debug info - TODO


func _ready() -> void:
	self.heightmaps = split_texture2D_into_packedFloat32Arrays(heightmap)
	initialise_map()


func initialise_map() -> void:
	# Calculate offset in order to centre the entire map on the origin
	var offset = Vector3(-((size[0] - 1) * 1024) / 2, 0, -((size[1] - 1) * 1024) / 2)
	
	var heightmap_index :int = 0
	# Instanciate a mesh for each 1024x1024 chunk
	for z in size[0]:
		for x in size[1]:
			var chunk :Node3D = MAP_CHUNK.instantiate().init(heightmaps[heightmap_index], 5, 2, Vector2(x, z), size)
			chunk.position = Vector3(x * 1024, 0, z * 1024) + offset
			self.add_child(chunk)
			heightmap_index += 1


# Takes in a grayscale texture2D and returns an array of float32s
func texture2D_to_packedFloatArray(texture:Texture2D) -> PackedFloat32Array:
	var image :Image = texture.get_image()
	image.convert(Image.FORMAT_RF)
	var array :PackedFloat32Array = image.get_data().to_float32_array()
	return array


# Splits a texture2D into NxN equal sized overlapping heightmaps.
# Accepted resolutions are 1024x1024 and all multiples of these
func split_texture2D_into_packedFloat32Arrays(texture:Texture2D) -> Array[PackedFloat32Array]:
	# Identify how many splits to make
	var chunks_count :Vector2i = texture.get_size() / 512
	self.size = chunks_count
	
	# Initialise the array of arrays that will be exported
	var output :Array[Image] = []
	
	# Convert texture to an image
	var image :Image = texture.get_image()
	image.convert(Image.FORMAT_RF)
	
	# Create an empty packed byte array of 513x513 size
	var array :PackedFloat32Array = PackedFloat32Array()
	array.resize(513*513)
	#array.fill(0)
	var byte_array :PackedByteArray = array.to_byte_array()
	
	# Split the image into NxN sub-images
	for Y in chunks_count[1]:
		for X in chunks_count[0]:
			var blit :Image = Image.new()
			blit.set_data(513, 513, false, Image.FORMAT_RF, byte_array)
			blit.blit_rect(image, Rect2i(Vector2i(512 * X, 512 * Y), Vector2i(513, 513)), Vector2i(0, 0))
			output.append(blit)
	
	# Convert each image into a packed float 32 array and return them
	var returned_array :Array[PackedFloat32Array] = []
	for i in range(output.size()):
		returned_array.append(output[i].get_data().to_float32_array())
	
	# Return these arrays
	return returned_array







