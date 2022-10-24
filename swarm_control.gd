extends Control

@export var swarm: Node3D
@export var grid: Node3D
@export var vegetation: Node3D

@export var swarm_size_label: Label
@export var entity_scale_label: Label
@export var max_speed_label: Label
@export var influence_radius_label: Label
@export var coherence_label: Label
@export var separation_label: Label
@export var alignment_label: Label
@export var distances_computed_label: Label
@export var distances_time_label: Label
@export var swarm_time_label: Label

@export var swarm_size_slider: HSlider
@export var entity_scale_slider: HSlider
@export var max_speed_slider: HSlider
@export var influence_radius_slider: HSlider
@export var coherence_slider: HSlider
@export var separation_slider: HSlider
@export var alignment_slider: HSlider

@export var show_center: CheckButton
@export var show_grid: CheckButton
@export var show_vegetation: CheckButton

@export var distances_plot_panel: Panel
@export var swarm_plot_panel: Panel

@export var split_container : HSplitContainer
@export var subviewport : SubViewport

var viewport_width = ProjectSettings.get_setting('display/window/size/viewport_width')
var viewport_height = ProjectSettings.get_setting('display/window/size/viewport_height')

# Called when the node enters the scene tree for the first time.
func _ready():
	split_container.size = Vector2(viewport_width, viewport_height)
	split_container.split_offset = int(viewport_width/3)
	subviewport.size.x = viewport_width - split_container.split_offset
	subviewport.size.y = viewport_height
	
	swarm_size_slider.value = swarm.swarm_entity_count
	swarm_size_label.text = str(swarm_size_slider.value)
	entity_scale_slider.value = swarm.swarm_entity_scale
	entity_scale_label.text = str(entity_scale_slider.value)
	max_speed_slider.value = swarm.swarm_entity_max_speed
	max_speed_label.text = str(max_speed_slider.value)
	influence_radius_slider.value = swarm.swarm_entity_influence_radius
	influence_radius_label.text = str(influence_radius_slider.value)
	coherence_slider.value = swarm.swarm_coherence_rate
	coherence_label.text = str(coherence_slider.value)
	separation_slider.value = swarm.swarm_separation_rate
	separation_label.text = str(separation_slider.value)
	alignment_slider.value = swarm.swarm_alignment_rate
	alignment_label.text = str(alignment_slider.value)
	show_center.button_pressed = swarm.swarm_center.visible
	show_grid.button_pressed = grid.visible
	show_vegetation.button_pressed = vegetation.visible


func _on_max_speed_slider_value_changed(value):
	swarm.swarm_entity_max_speed = value
	max_speed_label.text = str(value)


func _on_influence_slider_value_changed(value):
	swarm.swarm_entity_influence_radius = value
	influence_radius_label.text = str(value)


func _on_coherence_slider_value_changed(value):
	swarm.swarm_coherence_rate = value
	coherence_label.text = str(value)

func _on_separation_slider_value_changed(value):
	swarm.swarm_separation_rate = value
	separation_label.text = str(value)


func _on_alignment_slider_value_changed(value):
	swarm.swarm_alignment_rate = value
	alignment_label.text = str(value)


func _on_show_center_check_button_toggled(button_pressed):
	swarm.swarm_center.visible = button_pressed


func _on_show_grid_check_button_toggled(button_pressed):
	grid.visible = button_pressed
	

func _on_swarm_size_slider_drag_ended(value_changed):
	if value_changed:
		swarm.update_swarm_size(swarm_size_slider.value)
		swarm_size_label.text = str(swarm_size_slider.value)
		show_center.button_pressed = swarm.swarm_center.visible


func _on_swarm_swarm_distance_count_changed(value):
	distances_computed_label.text = str(value)


func _on_swarm_swarm_distance_matrix_time_updated(value):
	distances_time_label.text = String.num(value, 1) + ' ms'
	distances_plot_panel.record_point(value)


func _on_swarm_swarm_process_time_updated(value):
	swarm_time_label.text = String.num(value, 1) + ' ms'
	swarm_plot_panel.record_point(value)


func _on_entity_size_slider_drag_ended(value_changed):
	if value_changed:
		swarm.update_entity_scale(entity_scale_slider.value)
		entity_scale_label.text = str(entity_scale_slider.value)
		show_center.button_pressed = swarm.swarm_center.visible


func _on_restart_button_pressed():
	swarm.respawn_swarm()
	show_center.button_pressed = swarm.swarm_center.visible


func _on_show_vegetation_check_button_toggled(button_pressed):
	vegetation.visible = button_pressed
