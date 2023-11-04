extends Node

@onready var touch_feedback_node = $HBoxContainer/MarginContainer/ScrollContainer/ScrollContent/Control/ImageContainer/TouchFeedback
@onready var right_rail_buttons: Array[Node] = $HBoxContainer/right_rail/ScrollContainer/legend_for_hidden_objects.get_children()


@onready var home_btn = $HBoxContainer/MarginContainer/ScrollContainer/ScrollContent/left_rail_notch_buffer/Home
@onready var lvl_done = $level_complete_panel/MarginContainer/PanelContainer/Control/btn_level_select


@onready var imageSize = $HBoxContainer/MarginContainer/ScrollContainer/ScrollContent/Control/ImageContainer/hidden_objects_image.size
@onready var zoomLevel = 1
## TODO: Figure out max zoom


# Called when the node enters the scene tree for the first time.
func _ready():
	# when TouchFeedback sends us "shape found" we handle that here
	touch_feedback_node.connect("shape_found", on_shape_found)
	# zoom in when zoom in event is fired
	touch_feedback_node.connect("should_zoom", _on_should_zoom)
	
	# connect home btn to menu select
	home_btn.connect("button_up", _on_home_button_up)
	lvl_done.connect("button_up", _on_home_button_up)
	
	
	
	# set width of the scroll
	
	
	
	var clickZones = $HBoxContainer/MarginContainer/ScrollContainer/ScrollContent/Control/ImageContainer/click_zone_container.get_children()
	print("#clickZones", clickZones)
	# set alpha to 0 so click zones are invisible to user but still active
	# FIXME: Should I just set this in a shared style?!?
	for clickZone in clickZones:
		clickZone.set_modulate(Color(1, 1, 1, 0)) # hide all the clickzones
#		clickZone.connect("shape_found", on_shape_found.bind(clickZone))# add clickHandlers
		
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#whenever overlapping shapes are found in canvas pass array of overlapping shapes
#func on_canvas_shapes_found(shapes: Array[Area2D]):
#	# compare each overlapping shape passed in (from click circle)
#	for shape in shapes:
#		on_shape_found(shape)

# on hidden shape found
func on_shape_found(clickZoneNode: Area2D):

	var shape_name = clickZoneNode.name
	
	mark_clickzone_as_done(clickZoneNode)
	mark_right_rail_btn_as_done(shape_name)

	
	
func check_should_end_level(isTweenDone: bool):
	
	var count = 0
	# Is the level done?	
	for btn in right_rail_buttons:
#		print("name", btn.name)
		if !btn.is_disabled():
			count += 1
			
	# how many are still left. If it's one it means we are closing up	
#	print('###count', count)	
#	if isTweenDone:
	if count == 0:	
		end_level()
	# if have one left that we are closing out, then mark as done (faster to show completion screen)		
	elif count == 1 && !isTweenDone: 
		end_level()
	
	
func mark_clickzone_as_done(shape: Area2D):
	# disable collision shape
	var collisionShape = get_collision_shape_from_node(shape)
	collisionShape.disabled = true
	
	
	# canvas click zone. Gray out with animation
#	shape.set_modulate(Color(.36, .36, .36, .74))
	
	# bump z-index high so this animation will pop above the touchfeedback circle
	shape.z_index = 5
	
	# delay starting until the feedback circle is a little later (or move the z-index of this higher)
	var tween = get_tree().create_tween().set_parallel(false)
#	tween.tween_property(self, "modulate", Color.RED, 3).set_trans(Tween.TRANS_BOUNCE)
#	tween.tween_property(self, "modulate", Color(0.11,1,1,.5), .2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(shape, "modulate", Color(.36, .36, .36, .74), .1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN).set_delay(.01)
	tween.tween_property(shape, "scale", Vector2(1.5,1.5), .15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(shape, "scale", Vector2(1,1), .1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
#	tween.tween_property(shape, "modulate", Color(0.65,.1,.86, 0), .1).set_ease(Tween.EASE_OUT)
	
#	tween.tween_property(self, "scale", Vector2(), 1)
#	tween.tween_property(self, "scale", Vector2(), 1).set_trans(Tween.TRANS_BOUNCE)
	
#	shape.z_index = 0 # reset back down
		
	# don't remove it since we only have one
#	tween.tween_callback(on_tween_done)
	
#	shape.disabled = true
	# disable collision detection on this shape
#	shape.shape_owner_get_shape(shape.get_id(), 0)
#	area.shape_owner_get_owner(area_shape_index)
#	shape_owner_get_shape()
	
	
	# functionally - disable clicks (needed when you'd click on each shape)
#	shape.set_pickable(false) # bubbles up from collisionlayer. Nice!
	
	
# marks button as disabled	
func mark_right_rail_btn_as_done(shape_name: String):
	check_should_end_level(false) # TODO: Hate this check. fix it
	
	
	var btn = find_matching_right_rail_button(shape_name)
#	var rr_btn = find_matching_right_rail_button(shape.get_name())
	
	# values to restore at the end
	var btn_min_size = btn.custom_minimum_size
	
	## Right rail button. Disable and fade out
#	btn.disabled = true
	# stop using the shader, so we can effect the alpha channel of this
	btn.use_parent_material = true
#	btn.set_modulate(Color(1,1,1,.5))

	var btn_global_pos = btn.global_position
	print("##global_pos", btn.global_position)
	
	# pull out of parent flow (like pos:absolute)
#	btn.set_position(btn.global_position)
	btn.top_level = true
	btn.z_index = 12 # move high enough so it floats above the right rail
	print("##global_pos", btn.global_position)
	btn.set_position(btn_global_pos)
	print("##global_pos", btn_global_pos)
#	btn_global_pos

	# get position of last btn? Or just the bottom of the screen maybe?
#	get veiwport height so we can move just beyond it	
	var viewport_height = get_viewport().get_visible_rect().size.y
	
	
	var tween = get_tree().create_tween().set_parallel(false)
#	tween.tween_property(self, "modulate", Color.RED, 3).set_trans(Tween.TRANS_BOUNCE)
#	tween.tween_property(self, "modulate", Color(0.11,1,1,.5), .2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(btn, "position", Vector2(btn_global_pos.x, viewport_height), 3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(.01)
	tween.parallel().tween_property(btn, "scale", Vector2(0,0), 1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN).set_delay(.1)
	tween.parallel().tween_property(btn, "custom_minimum_size", Vector2(0,0), 1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN).set_delay(.1)
#	tween.parallel().tween_property(btn, "modulate", Color(1, 1, 1, .5), 3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)
#	tween.tween_property(btn, "scale", Vector2(1.5,1.5), .15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
#	tween.tween_property(btn, "scale", Vector2(1,1), .1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# can we animate this?
	var on_tween_done = func():
		btn.top_level = false # put the positioning back in the parent container
		btn.custom_minimum_size = btn_min_size # restore size
		btn.get_parent().move_child(btn, btn.get_parent().get_child_count()) # move to end
		btn.disabled = true # set disabled style
		check_should_end_level(true) # doesn't hurt to run it multiple times


	# scroll right rail to top?
	
	tween.tween_callback(on_tween_done)
#	tween.finished(btn.set.bind("top_level", false))

	
# need this to get the collision node so we can disable it (because monitoring doesn't work?)	
func get_collision_shape_from_node(shape: Area2D):
	for node in shape.find_children("*", "CollisionPolygon2D"):
		return node
#		print('###node', node)
#		print('node', node.is_class("node"))
#		print('node2', node.get_class())
	

## Pass in the name of the shape(node) then returns that right rail button by that name
func find_matching_right_rail_button(shape_name:String)->Button:
	var searchTerm = Button.new()
	searchTerm.name = shape_name
#	var result = right_rail_buttons.find(searchTerm)
	# find is weird. so using filter instead
	
	## FIXME: error handling?!? This could explode
	return right_rail_buttons.filter(func(x): return x.name == shape_name)[0]

	
	
func end_level():
	# fade out screen
	$level_complete_panel.modulate.a = 0 # set alpha to 0
	$level_complete_panel.visible = true # show the 
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property($level_complete_panel, "modulate", Color(1, 1, 1, 1), 1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN).set_delay(.01)
	tween.tween_property($HBoxContainer, "modulate", Color(1, 1, 1, .3), .7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN).set_delay(.01)
	tween.tween_property($HBoxContainer/right_rail/ScrollContainer, "modulate", Color(1, 1, 1, 0), .7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN).set_delay(.01)


	# don't remove it since we only have one
#	tween.tween_callback(on_tween_done)
	



# Go back to main screen
func _on_home_button_up():
	get_tree().change_scene_to_file("res://main.tscn" )


func _on_btn_level_select_button_up():
	_on_home_button_up()



# is gated...

func _on_should_zoom(zoomPosition):
	# what if we handle the debounce here?
	
	print('\n\n###zoomIn')
	var imageContainerParent: Control = get_node("HBoxContainer/MarginContainer/ScrollContainer/ScrollContent/Control")
	var imageContainer = imageContainerParent.get_node("ImageContainer")
	print("node", imageContainerParent)
#	print("IMAGE RISZE TO ZOOM", canvas_img.size) #does it make more sense to upscale the image?
	# double scale?
#	$HBoxContainer/ScrollContainer.scale = Vector2(2,2)
	# change scrollcontainer child scale and size
	
	# toggle zoomLevel
	if zoomLevel == 1:
		zoomLevel = 2
	else:
		zoomLevel = 1
		
		
	
	

#	imageContainerParent.scale = Vector2(zoomLevel,zoomLevel)
	
	print("##size", imageContainerParent.get_node("ImageContainer"))
	# double the canvas size for scrolling accuracy
	var scrollContent = $HBoxContainer/MarginContainer/ScrollContainer/ScrollContent
	print("####size", scrollContent.custom_minimum_size)
	
	scrollContent.set_custom_minimum_size(imageSize * zoomLevel)
	
	await get_tree().process_frame # needed in this case for changing scale. See docs https://docs.godotengine.org/en/stable/classes/class_control.html
#	imageContainerParent.set_scale(Vector2(zoomLevel,zoomLevel))	
	imageContainer.set_scale(Vector2(zoomLevel,zoomLevel))	
	
	# move AFTER we zoom
	print("zoomLevel", zoomLevel)
#	scroll to where we double tapped
# maybe half  distance? not whole distance?
	print("scroll to:", zoomPosition)
	
	await get_tree().process_frame #again?
	
	var scrollContainer = $HBoxContainer/MarginContainer/ScrollContainer
	# scroll to new place, and take zoomLevel into account
	
	var viewPortWidth = get_viewport().get_visible_rect().size.x
	var viewPortHeight = get_viewport().get_visible_rect().size.y
	
	# try to center that and take current zoom level into account
	scrollContainer.scroll_horizontal = zoomPosition.x * zoomLevel - viewPortWidth / 2 # add buffer so it's center of viewport
	scrollContainer.scroll_vertical = zoomPosition.y * zoomLevel - viewPortHeight / 2
	
	
#	scrollContainer.scroll_horizontal = 200
#	scrollContainer.set_deferred("scroll_horizontal", 2000)
#	scrollContainer.set_deferred("scroll_horizontal", 600)



#	$HBoxContainer/ScrollContainer.custom_minimum_size = canvas_img.size * 1.5
	# resize the child of the ScrollContainer to get the new scroll dimensions
#	$HBoxContainer/MarginContainer/ScrollContainer/HBoxContainer.custom_minimum_size = canvas_img.size * 2
	# or can we just scale that?
#	$HBoxContainer/ScrollContainer/HBoxContainer.scale = Vector2(2,2) # temp scale˚
	
	# resize the scrollContainer according to the new full size
	
#	canvas_img.scale = Vector2(2,2)
#	$HBoxContainer/MarginContainer/ScrollContainer/HBoxContainer/CanvasLayer/Camera2D.zoom = Vector2(0.5,0.5)



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
