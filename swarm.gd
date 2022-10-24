extends Node3D

signal swarm_distance_count_changed(value)
signal swarm_distance_matrix_time_updated(value)
signal swarm_process_time_updated(value)

@export var swarm_entity_scene : PackedScene
var swarm_entity_count = 50
var swarm_entity_scale = 1.5
var swarm_entity_influence_radius = 2.0
var swarm_entity_max_speed = 10.0
var swarm_bounding_box = 10
var swarm_center : SwarmCenter
var swarm_center_material = preload('res://red_entity.tres')
var swarm_coherence_rate = 0.04
var swarm_separation_rate = 0.6
var swarm_alignment_rate = 0.25
var swarm = []
var swarm_distance_matrix = []
var swarm_distance_count
var swarm_distance_matrix_time
var swarm_process_time
#var swarm_multimesh_instance : MultiMeshInstance3D
#var swarm_multimesh : MultiMesh

func _ready():
	_initialize_swarm()
	_initialize_swarm_center()
	_compute_distance_matrix()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var start_time = Time.get_ticks_usec()
	for i in range(swarm_entity_count):
		var swarm_entity = swarm[i]
		if swarm_entity.perching:
			continue
		var neighbors = _find_neighbors(i)
		
		# Coherence
		swarm_entity.velocity += swarm_coherence_rate * (swarm_center.position - swarm_entity.position)
		if len(neighbors) > 0:
			var alignment_velocity = Vector3.ZERO
			for swarm_entity_neighbor in neighbors:
				# Separation
				var diff = swarm_entity.position - swarm_entity_neighbor.position
				if diff != Vector3.ZERO:
					swarm_entity.velocity += swarm_separation_rate * diff.inverse()
				# Alignment
				alignment_velocity += swarm_entity_neighbor.velocity
			alignment_velocity /= len(neighbors)
			swarm_entity.velocity = swarm_entity.velocity.lerp(alignment_velocity, swarm_alignment_rate)
		
		# Bounding box
		swarm_entity.velocity += _bounding_box(i)
		
		# Limiting entity speed
		swarm_entity.velocity = swarm_entity.velocity.limit_length(swarm_entity_max_speed)
		
		# Update entity position and rotation
		swarm_entity.position += swarm_entity.velocity * delta
		swarm_entity.rotation.y = atan2(swarm_entity.velocity.x, swarm_entity.velocity.z)
		
	_compute_distance_matrix()
	_update_swarm_center()
	swarm_process_time = (Time.get_ticks_usec() - start_time) / 1000.0
	emit_signal('swarm_process_time_updated', swarm_process_time)

func _bounding_box(i: int) -> Vector3:
	var v = Vector3.ZERO
	if swarm[i].position.x < -swarm_bounding_box:
		v.x = 5.0
	elif swarm[i].position.x > swarm_bounding_box:
		v.x = -5.0
	if swarm[i].position.y < -swarm_bounding_box:
		v.y = 5.0
		if randf() > 0.5:
			swarm[i].perch()
			swarm[i].position.y = -swarm_bounding_box
	elif swarm[i].position.y > swarm_bounding_box:
		v.y = -5.0
	if swarm[i].position.z < -swarm_bounding_box:
		v.z = 5.0
	elif swarm[i].position.z > swarm_bounding_box:
		v.z = -5.0
	return v
	
func _find_neighbors(i: int) -> Array[SwarmEntity]:
	# Find local neighbors
	var neighbors = []
	for j in range(swarm_entity_count):
		if i != j and swarm_distance_matrix[i][j] < swarm_entity_influence_radius:
			neighbors.append(swarm[j])
	return neighbors

func _compute_distance_matrix() -> void:
	var start_time = Time.get_ticks_usec()
	for i in range(swarm_entity_count):
		for j in range(i+1, swarm_entity_count):
			var d = swarm[i].position.distance_to(swarm[j].position)
			swarm_distance_matrix[i][j] = d
			swarm_distance_matrix[j][i] = d
	swarm_distance_matrix_time = (Time.get_ticks_usec() - start_time) / 1000.0
	emit_signal('swarm_distance_matrix_time_updated', swarm_distance_matrix_time)
		
func _initialize_swarm() -> void:
	swarm.resize(swarm_entity_count)
	swarm_distance_matrix.resize(swarm_entity_count)
	var distance_count = 0
	for i in range(swarm_entity_count):
		var swarm_entity = swarm_entity_scene.instantiate()
		swarm_entity.scale = swarm_entity_scale * swarm_entity.scale
		swarm_entity.name = 'SwarmEntity' + str(i)
		swarm_entity.position = Vector3(
			randf_range(-swarm_bounding_box, swarm_bounding_box),
			randf_range(-swarm_bounding_box, swarm_bounding_box),
			randf_range(-swarm_bounding_box, swarm_bounding_box)
			)
		swarm_entity.velocity = Vector3(
			randf_range(-swarm_entity_max_speed, swarm_entity_max_speed),
			randf_range(-swarm_entity_max_speed, swarm_entity_max_speed),
			randf_range(-swarm_entity_max_speed, swarm_entity_max_speed)
			)
		swarm_entity.velocity = swarm_entity.velocity.limit_length(swarm_entity_max_speed)
		
		swarm[i] = swarm_entity
		swarm_distance_matrix[i] = []
		swarm_distance_matrix[i].resize(swarm_entity_count)
		swarm_distance_matrix[i].fill(0)
		for j in range(i+1, swarm_entity_count):
			distance_count += 1
		add_child(swarm_entity)
	swarm_distance_count = distance_count
	emit_signal('swarm_distance_count_changed', swarm_distance_count)

func _initialize_swarm_center() -> void:
	swarm_center = SwarmCenter.new()
	swarm_center.name = 'SwarmCenter'
	swarm_center.mesh = SphereMesh.new()
	swarm_center.mesh.radius = 0.2 * swarm_entity_scale
	swarm_center.mesh.height = 0.4 * swarm_entity_scale
	swarm_center.mesh.surface_set_material(0, swarm_center_material)
	swarm_center.velocity = Vector3.ZERO
	swarm_center.visible = false
	_update_swarm_center()
	add_child(swarm_center)
	
func _update_swarm_center() -> void:
	var sum = Vector3.ZERO
	for swarm_entity in swarm:
		sum += swarm_entity.position
	swarm_center.position = sum / swarm_entity_count

func _remove_swarm_entities() -> void:
	for e in swarm:
		remove_child(e)
	remove_child(swarm_center)
	swarm = []

func respawn_swarm() -> void:
	_remove_swarm_entities()
	_initialize_swarm()
	_initialize_swarm_center()
	_compute_distance_matrix()

func update_swarm_size(count: int) -> void:
	swarm_entity_count = count
	respawn_swarm()
	
func update_entity_scale(size: float) -> void:
	swarm_entity_scale = size
	respawn_swarm()
