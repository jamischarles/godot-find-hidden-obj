extends Node


@onready var right_rail_buttons: Array[Node] = $HBoxContainer/right_rail/legend_for_hidden_objects.get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	$HBoxContainer/ScrollContainer/HBoxContainer/CanvasContainer/ClickCircle.connect("found_hidden_objects_on_canvas", on_canvas_shapes_found)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#whenever overlapping shapes are found in canvas pass array of overlapping shapes
func on_canvas_shapes_found(shapes: Array[Area2D]):
	# compare each overlapping shape passed in (from click circle)
	for shape in shapes:
		on_shape_found(shape)

# on match found
func on_shape_found(shape):
#	var firstNode = instance_from_id(firstUid)
	
	# canvas click zone. Gray out, then disable
	shape.set_modulate(Color(.36, .36, .36, .74))
	# functionally - disable clicks
	shape.set_pickable(false) # bubbles up from collisionlayer. Nice!
	
	print('shape.name##', shape.get_name())
	var rr_btn = find_matching_right_rail_button(shape.get_name())
	
	## Right rail button. Disable and fade out
	rr_btn.disabled = true
	# stop using the shader, so we can effect the alpha channel of this
	rr_btn.use_parent_material = true
	rr_btn.set_modulate(Color(1,1,1,.5))
	rr_btn.get_parent().move_child(rr_btn, rr_btn.get_parent().get_child_count()) # move to end
	
	
	# Verify we have no more sets to match
	# ie: Is the level done?
#	$HUD/score_label.set_text("%s / %s" % [current_score, total_match_sets])
	
	for btn in right_rail_buttons:
		print("name", btn.name)
		if !btn.is_disabled():
			return
			
	end_level()

## Pass in the name of the shape(node) then returns that right rail button by that name
func find_matching_right_rail_button(shape_name:String)->Button:
	var searchTerm = Button.new()
	searchTerm.name = shape_name
#	var result = right_rail_buttons.find(searchTerm)
	# find is weird. so using filter instead
	
	## FIXME: error handling?!? This could explode
	return right_rail_buttons.filter(func(x): return x.name == shape_name)[0]

	
	
func end_level():
	$level_complete_panel.visible = true # show the 

# Go back to level_select screen
func _on_home_button_up():
	get_tree().change_scene_to_file("res://level_selector.tscn" )


func _on_btn_level_select_button_up():
	_on_home_button_up()
