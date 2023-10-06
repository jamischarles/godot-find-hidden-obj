extends Node


@onready var right_rail_buttons: Array[Node] = $HBoxContainer/right_rail/legend_for_hidden_objects.get_children()

# Called when the node enters the scene tree for the first time.
func _ready():

	
	var clickZones = $HBoxContainer/ScrollContainer/HBoxContainer/CanvasContainer/click_zone_container.get_children()
	# set alpha to 0 so click zones are invisible to user but still active
	# FIXME: Should I just set this in a shared style?!?
	for clickZone in clickZones:
		clickZone.set_modulate(Color(1, 1, 1, 0)) # hide all the clickzones
		clickZone.connect("input_event", on_shape_found.bind(clickZone))# add clickHandlers
		
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#whenever overlapping shapes are found in canvas pass array of overlapping shapes
#func on_canvas_shapes_found(shapes: Array[Area2D]):
#	# compare each overlapping shape passed in (from click circle)
#	for shape in shapes:
#		on_shape_found(shape)

# on hidden shape found
func on_shape_found(viewport, event, shape_idx, clickZoneNode):
	if !isEventClick(event):
		return # bail early
		
	var shape_name = clickZoneNode.name
	mark_clickzone_as_done(clickZoneNode)

#	print('shape.name##', shape.get_name())
	var rr_btn = find_matching_right_rail_button(shape_name)
#	var rr_btn = find_matching_right_rail_button(shape.get_name())
	
	## Right rail button. Disable and fade out
	rr_btn.disabled = true
	# stop using the shader, so we can effect the alpha channel of this
	rr_btn.use_parent_material = true
	rr_btn.set_modulate(Color(1,1,1,.5))
	rr_btn.get_parent().move_child(rr_btn, rr_btn.get_parent().get_child_count()) # move to end
	
	
	# Is the level done?	
	for btn in right_rail_buttons:
		print("name", btn.name)
		if !btn.is_disabled():
			return
			
	end_level()
	
func mark_clickzone_as_done(shape):
	# canvas click zone. Gray out, then disable
	shape.set_modulate(Color(.36, .36, .36, .74))
	# functionally - disable clicks
	shape.set_pickable(false) # bubbles up from collisionlayer. Nice!
	

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



################## UTILS... SHARE ACROSS FILES?
var clickStartPos
var clickEndPos

# returns false or the clickStartPos vector2 of where the click ocurred
func isEventClick(event):
	## The drag sensitivity here should match the sensitivity on the scrolling 
	## (scroll deadzone on the ScrollContainer) node...

	print('##event', event)
	if event.get_class() == "InputEventScreenTouch":
		if event.is_pressed():
			clickStartPos = event.get_position()		
		else:	
			clickEndPos = event.get_position()
			if !isEventDrag(clickStartPos, clickEndPos):
				# if touch and NOT drag, then move the touch effect
#				on_touch_screen(clickStartPos)
				return clickStartPos
			else:
				pass
	return false


		
# if within deadzone, then consider it a touch (with a little movement) vs a drag
func isEventDrag(startPos: Vector2, endPos: Vector2):
	var drag_distance = startPos.distance_to(endPos)
	# FIXME: Maybe we pull that value so they are always the same...
	# this number (100) lines up PERFECTLY with "scroll_deadzone" on ScrollContainer
	return drag_distance > 100
