extends Node3D


# Array of LODs in the chunk
@onready var lod_array :Array[MeshInstance3D] = []

# Material for all LODs
@export var material :Material

# Heightmap for the chunk
var heightmap :PackedFloat32Array

# Local variables
var LOD_count :int = 5 # Number of LODs to generate
var LOD_offset :int = 0 # Reduce the resolution of all terrain chunks (0-full, 1-half, 2-quarter, etc...)
var location_in_map :Vector2 = Vector2.ZERO
var terrain_size :Vector2 = Vector2(1, 1)



# initialises the heightmap as a PackedFloat32Array and sends the data to the vertex shader
func init(heightfield:PackedFloat32Array, lod_count:int = 5, lod_offset:int=0, location:Vector2 = Vector2.ZERO, size:Vector2 = Vector2(1, 1)) -> Node3D:
	# initialise start variables
	self.LOD_count = lod_count
	self.LOD_offset = lod_offset
	self.location_in_map = location
	self.terrain_size = size
	# Load the section of the heightmap for this chunk
	self.heightmap = heightfield
	# returns itself so that it can be added to the scene tree
	return self


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create a mesh instance 3D and assign a mesh for each LOD
	for lod in LOD_count:
		var instance :MeshInstance3D = MeshInstance3D.new()
		instance.mesh = generate_mesh(lod+2, heightmap, 1000)
		if lod == LOD_count - 1:
			instance.visibility_range_begin = 500 * (2 ** lod) - 100
			instance.visibility_range_begin_margin = 100
			instance.visibility_range_end = 0
			instance.visibility_range_end_margin = 0
		elif lod  == 0:
			instance.visibility_range_begin = 0
			instance.visibility_range_begin_margin = 0
			instance.visibility_range_end = 1000 + 100
			instance.visibility_range_end_margin = 100
		elif lod < LOD_count - 1:
			instance.visibility_range_begin = 500 * (2 ** lod) - 100
			instance.visibility_range_begin_margin = 100
			instance.visibility_range_end = 500 * (2 ** (lod + 1)) + 100
			instance.visibility_range_end_margin = 100
		instance.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
		self.add_child(instance)


# Returns the mesh of the passed LOD level (0 - full detail, 1- half detail, 2-quater, etc...)
# max mesh resolution should be set equal to the heightmap resolution (eg. 512x512 heightmap means 512 in mesh res)
func generate_mesh(LOD:int, heightmap:PackedFloat32Array, height_scale:float = 1000, max_mesh_resolution:int = 512) -> Mesh:
	# Uses the LOD to set the number of vertices in the NxN grid
	var vertex_count :int = max_mesh_resolution / (2 ** LOD) + 1
	var float_vertex_count :float = vertex_count as float
	var size :int = 1024
	var float_size :float = size as float
	
	# Offsets the vertices to centre the plane
	var vertex_offset :Vector3 = Vector3(-size/2, 0, -size/2)
	
	# Calculate the UV space offsets
	var UV_offset = location_in_map * (Vector2(1, 1) / terrain_size)
	var UV_scale = Vector2(1.0 / 1024.0, 1.0 / 1024.0) / terrain_size
	
	# Initialise the surface tool
	var st :SurfaceTool = SurfaceTool.new()
	# Start the surface tool drawing triangle primitives
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var vertex_index :int = 0 # Counts the number of vertices
	var vertex_x :int = 0
	var vertex_y :int = 0
	# create an NxN grid of vertices with UVs
	for y in range(0, size + 1, float_size/(float_vertex_count-1)):
		for x in range(0, size + 1, float_size/(float_vertex_count-1)):
			# sets the UV of the added vertex and then adds the vertex with the correct Y height
			st.set_uv(Vector2(x, y) * UV_scale + UV_offset)
			if (y >= size or y <= 0) and vertex_x % 2 == 1: # Selects all of the edge vertices for smooth lod transitions
				#st.add_vertex(Vector3(x, ((heightmap[vertex_index-(2 ** LOD)] + heightmap[vertex_index+(2 ** LOD)]) / 2) * height_scale, y) + vertex_offset)
				st.add_vertex(Vector3(x, heightmap[vertex_index] * height_scale, y) + vertex_offset) # default
				# TODO - average height of vertices on the Y axis
			else:
				st.add_vertex(Vector3(x, heightmap[vertex_index] * height_scale, y) + vertex_offset)
			
			# Increment the vertex index by 2**LOD or skip (2**LOD)-1 lines if at the end of a row
			if vertex_x % vertex_count == vertex_count - 1 and vertex_x != 0:
				vertex_index += (((2 ** LOD) - 1) * (max_mesh_resolution + 1)) + 1
			else:
				vertex_index += (2 ** LOD)
			
			# Increment the x and y coordinate trackers
			vertex_x += 1
		vertex_y += 1
	#print(vertex_index)
	
	vertex_index = 0 # Counts the number of vertices have had triangles built for them
	# Add the triangle indices to the surface tool
	for y in range(0, vertex_count):
		for x in range(0, vertex_count):
			if (x < vertex_count - 1) and (y < vertex_count - 1):
				add_triangle(st, vertex_index + vertex_count + 1, vertex_index + vertex_count, vertex_index)
				add_triangle(st, vertex_index + vertex_count + 1, vertex_index, vertex_index + 1)
			vertex_index += 1
	
	# Remove duplicate vertices
	st.deindex()
	
	# Calculate normals and tangents for the surface and set the material
	st.generate_normals()
	st.generate_tangents()
	st.set_material(material)
	
	# returns the surface committed to a mesh
	return st.commit()


# adds a triangle to the passed surface tool
func add_triangle(surface_tool:SurfaceTool, a:int, b:int, c:int) -> void:
	surface_tool.add_index(a)
	surface_tool.add_index(b)
	surface_tool.add_index(c)











