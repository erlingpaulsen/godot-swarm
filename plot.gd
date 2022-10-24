extends Control

# The length of the horizontal axis (usually seconds)
@export var x_axis = 10.0

# The speed at which the axis will adjust to changed data range
@export var lerp_axis = 0.9

@export_color_no_alpha var graph_color : Color = Color(1.0, 0.0, 0.0)

var graph = []
var current_time: float = 0.0
var y_min: float = INF
var y_max: float = -INF

func _process(delta):
	current_time += delta
	queue_redraw()

func _draw():
	var new_y_min = +INF
	var new_y_max = -INF

	# Compute range of data
	for i in range(len(graph)):
		new_y_min = min(new_y_min, graph[i][1])
		new_y_max = max(new_y_max, graph[i][1])

	if new_y_min == INF:
		# No data
		y_min = INF
		y_max = -INF
		return

	# Update displayed range
	if y_min == INF:
		y_min = new_y_min
		y_max = new_y_max
	else:
		y_min = lerp(y_min, new_y_min, lerp_axis)
		y_max = lerp(y_max, new_y_max, lerp_axis)

	# Compute plot area
	var area_pos = Vector2(4, 2)
	var area_size = size - Vector2(6, 6)

	draw_curve(graph_color, area_pos, area_size)

func draw_curve(color: Color, area_pos: Vector2, area_size: Vector2):
	var points = []
	for i in range(len(graph)):
		var x = graph[i][0]
		x = (x - (current_time - x_axis)) / x_axis * area_size.x + area_pos.x
		var y = graph[i][1]
		y = (y_max - y) / (y_max - y_min) * area_size.y + area_pos.y
		points.append(Vector2(x, y))
	points.append(points[-1])

	draw_polyline(points, color)

# Add a point to a curve at a X position
func add_point(x_value: float, y_value: float) -> void:
	graph.append([x_value, y_value])

	var pos = 0
	while pos < len(graph) and graph[pos][0] < current_time - x_axis:
		pos += 1
	if pos > 0:
		graph = graph.slice(pos, len(graph))

# Add a point to a curve using the current time as X position
func record_point(value: float) -> void:
	add_point(current_time, value)
