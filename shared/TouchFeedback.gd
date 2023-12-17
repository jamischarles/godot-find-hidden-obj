extends Area2D

signal shape_found
signal should_zoom

# right now we align them fully in the editor GUI
# so the circle and collision obj are the exact same size at full size.
# now that we don't use the full size we need to ensure the collision area
# matches the size of the circle at full animation size
# FIXNE: should we be scaling the parent area2d instead?
var MAX_CIRCLE_SIZE = .5 #scale prop

# Dict for an event state map, to keep track of what events are in progress, and how many...
var event_state = {
	status = "no_touch",  # one-touch, # two-touch, # three-touch # drag
	# lua style assign turns key into string (nice)
	
}

# these are the ONLY valid states for the FSM to be in...
var finite_states = {
	"no_touch" : {
		status = "no_touch"
	}, 
	"one_touch_press" : { # in progress
		status = "one_touch_press",
		pos = Vector2()
	}, 
	"one_touch_drag_scroll" : { # in progress
		status = "one_touch_drag_scroll",
		start_pos = Vector2() # position where the drag started
	},
	
	"multi_touch_press": {
		status = "multi_touch_press",
		touch_points = {} # number based dict / array. Will include state for each touch point
	},
	
	"multi_touch_drag_zoom": { # multi touch drag for purpose of zoom in/out in progress
		status = "multi_touch_drag_zoom",
		touch_points = {}, # number based dict / array. Will include state for each touch point
		distance = 0 # distance between the pinched fingers (usually use 0 and 1)
	}
}




## TODO: Verify then add dragging and pinch & zoom
## Like redux i need to fire every time state is updated
## https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html
func handle_touch_events(state, event: InputEvent):
	
	# COMPLETELY ignore mouse events (on desktop we emulate touch events)
	if event is InputEventMouse:
		return
	
	
	match state.status:
		"no_touch": # nothing pressed yet, proceed
			match event.get_class():
				"InputEventScreenTouch":
					print('no_touch+touch', event)
					if event.is_pressed():
						switch_state("one_touch_press", {pos = event.position})
					
		"one_touch_press": # if one is already pressed
			match event.get_class():
				"InputEventScreenTouch":
					if event.is_pressed(): # PRESS
						print("one_press+screenTouch", event)
						
						if event.index == 0:
							switch_state("one_touch_press", {pos = event.position})
							return
						
						# ONLY register as multi-touch if we have finger index > 0
						switch_state("multi_touch_press", {
							touch_points = {
								0: {
									pos = event_state.pos
								},
								1: {
									pos = event.position
								}
							}
						}) # TODO: Capture for EACH item, including the currently saved one
					else: # RELEASE
						draw_tap_feedback_circle(event_state.pos)
						switch_state("no_touch", {})
				"InputEventScreenDrag": #FIXME: check for the deadzone here before we switch to drag event
					#print('InputEventScreenDrag: ', event.index, event_state)
					print("one_press+screenDrag", event, event_state)
					switch_state("one_touch_drag_scroll", {start_pos = event.position})
					#get_viewport().set_input_as_handled()
						
						
		# TODO: Handle ONE TOUCH DRAG == scroll
		
		# FIXME: this one isn't exiting properly... let's step through it...
		"one_touch_drag_scroll": # 
			#print('\none-touch-drag-scroll: ', event.as_text())
			match event.get_class():
				"InputEventScreenTouch":
					if event.is_pressed(): # PRESS
						switch_state("one_touch_press", {pos = event.position})
					else:
						switch_state("no_touch", {}) # releasing during drag means we're just done. Don't draw circle feedback
					# switch to one_touch_press / release
						
						# then re-run this 'release' evt? through the `one_touch_press` path (so it'll release back down)

					#if event.is_pressed(): # PRESS
						## if we are scrolling and add another finger, assume that we didn't quite catch the release of the other finger.
						## instead of assuming we're adding a finger...
						#switch_state("one_touch_press", {pos = event.position})
					#else:
				"InputEventScreenDrag":
					print(event.index)
						
		"multi_touch_press":
			match event.get_class():
				"InputEventScreenTouch":
					if event.is_pressed(): # PRESS
						# stay in this status, but add more fingers
						## Todo capture finger index
						update_multi_touch_pos(event.index, event.position)
					else: # RELEASE ONE finger
						# FIXME: This logic is buggy
						event_state.touch_points.erase(event.index)
						# if down to one finder switch state
						if event_state.touch_points.size() == 1:
							#switch_state("one_touch_press", event_state.touch_points.values()[0])
							## We'll assume that multi touch to 1 touch is actually taking all fingers off
							switch_state("no_touch", {})
							
				"InputEventScreenDrag":
					print('## DRAG:START ', event)
					## do we use a debounce for this or what?
					# capture the new distance
					# TODO: Extract this into a save() function
					# update the distance
					update_multi_touch_pos(event.index, event.position)
					
					
					var distance_between_points = event_state.touch_points[0].pos.distance_to(event_state.touch_points[1].pos)
					switch_state("multi_touch_drag_zoom", {touch_points = event_state.touch_points, distance = distance_between_points})
					
					## change the zoom level based on zoom_rate_change from the pinching action
					
		"multi_touch_drag_zoom": # pinch_zoom operation in progress
			match event.get_class():
				"InputEventScreenDrag":
					var direction
					print('## DRAG:DRAG ', event)

					var zoomLevel = get_tree().current_scene.zoomLevel

					
					## TODO: capture prior distance? So we can get a sense of which way it's moving?
					update_multi_touch_pos(event.index, event.position)
					
					

					## TODO: Normalize distance regardless of zoom
					
					# get new distance
					var distance_between_points = event_state.touch_points[0].pos.distance_to(event_state.touch_points[1].pos)
										
					# calc the distance at the CURRENT zoom level, vs the old distance at the old zoom level (should be apples to apples)
					print('---------------------------------------->')
					print("zoomLevel", zoomLevel)
					print("distance_between_points", distance_between_points)
					print("distance_between_points / zoomLevel", distance_between_points / zoomLevel)					
					if (distance_between_points / zoomLevel - event_state.distance) > 0:
						# positive (getting bigger) == zoom IN
						direction = "ZOOM_IN"
					else:
						# negative (getting smaller) == zoom OUT
						direction = "ZOOM_OUT"
									
					# what should the new zoom quotient be?
					print("distance: old, new: ", event_state.distance, "  |  ", distance_between_points / zoomLevel)
					print('zoom:direction: ', direction)
					
					
					
					var center_point = (event_state.touch_points[0].pos + event_state.touch_points[1].pos) / 2
					
					## FIXME: we need velocity to determine zoom factor change...
					var zoom_factor_change = .1 ## TODO: Reduce this by 10 since we have way more events firing.
					if direction == "ZOOM_OUT":
						zoom_factor_change *= -1 # change sign
						
					# if the distance hasn't changed, make zoom change zero
					#if	event_state.distance == distance_between_points:
						#zoom_factor_change = 0
					
					
					# save the distance (normalized for zoom level)
					event_state.distance = distance_between_points	/ zoomLevel
					emit_should_zoom(center_point, zoom_factor_change)

				"InputEventScreenTouch":
					# switch to multi_touch_press / release
					switch_state("multi_touch_press", {touch_points = event_state.touch_points})
					# then re-run this 'release' evt? through the `multi_touch_press` path
					handle_touch_events(event_state, event)
					
				## TODO: check for drag distance? If it's below X then just ignore it? Is that a hacky way to debounce it?
			
			
func update_multi_touch_pos(fingerIndex: int, newPos: Vector2):
	event_state.touch_points[fingerIndex] = {
		pos = newPos
	}
	
		
					
## Generate the new state 'status' and other props
func switch_state(newStateName: String, payload):
	#print('handle_touch_events->state|event: payload ', newStateName, payload)
	#print('handle_touch_events->state|event: BEFORE ', event_state, newStateName)
	if !finite_states[newStateName]:
		print("not a valid state. Aborting: ", newStateName)
		return
		
		
	event_state = {}
	
	event_state.merge(finite_states[newStateName])
	event_state.merge(payload, true) # will overwrite existing keys.
	print(event_state)#, 'handle_touch_events->state|event: AFTER ', event_state)#, payload)







#@onready var scrollContainer = get_node("/root").get_tree()
@onready var scrollContainer = get_tree().current_scene.get_node('HBoxContainer/MarginContainer/ScrollContainer')



# Called when the node enters the scene tree for the first time.
func _ready():
	# scale the collision shape down to max_size to match circle size
	$CollisionCircle.scale = Vector2(MAX_CIRCLE_SIZE, MAX_CIRCLE_SIZE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_image_container_gui_input(event):
	# EMULATE pinch & zoom while on desktop for FAKE multi touch from laptop
	if event.get_class() == "InputEventMouseButton":
		#print("\n->inside mouse click: ", event)
		if event.alt_pressed && event.shift_pressed:
			#print('MOUSE BUTTON ZOOM OUT HANDLER')
			# emulate multi touch zoom OUT
			simulateMultiTouchZoom({center_of_touch = event.position, direction = "ZOOM_OUT"})
			return

		elif event.is_alt_pressed():
			# emulate multi touch ZOOM IN
			#print('MOUSE BUTTON ZOOM IN HANDLER')
			#print("\nCLICK", event, event.alt_pressed)
			simulateMultiTouchZoom({center_of_touch = event.position, direction = "ZOOM_IN"})
			return

	handle_touch_events(event_state, event)


#var locked = false
#func eventCooldown():
#	locked = true
#	await get_tree().create_timer(1).timeout
#	locked = false
	
	
#	if event.get_class() == "InputEventScreenDrag":
#		eventState.dragged[event.index] = event
#		print("\n### TOUCH SCREEN DRAG", event)
#		return handleZoomTouchEvents(event)
		
#
#
#	## TODO: split this out into separate functions?
#	if event.get_class() == "InputEventScreenTouch":
#		pass
#
#	# store or use it
#	# once we have enough, then make the calc...
#
#	# get start and end pos (or delta between 2 at least)
#	# startPos distance
#	var startPosDistanceBetweenFingers = eventState.pressedEvents[0].position.distance_to(eventState.pressedEvents[1].position)
#	# this will continuously fire...
#	var endPosDistanceBetweenFingers = eventState.dragEvents[0].position.distance_to(eventState.dragEvents[1].position)
#
#
#	print("####START END POS: ", startPosDistanceBetweenFingers, endPosDistanceBetweenFingers)
	# is release?


## Results from REAL zooming:
## start at 266 distance. 
## inc: 1
## note: the zoom changing messes up the positioning of where the finger is, and how that affects the distnace
## TODO: We'll need to translate the distance so it takes zoom_level into account
## end distance at 2709 (but the zoom level messes that up)
## TODO: 1. debounce 2. normalize it for zoom level so the distance is stagnant. 3. reduce the amount of zoom factor por px moved. 4. Add min/max zoom 

## Simulates pinch & zoom
func simulateMultiTouchZoom(props): # for ZOOM
	var centerPos = props.center_of_touch
	var direction = props.direction # ZOOM_IN | ZOOM_OUT
	
	
	
	#print('## SIMULATING multi touch PINCH')
	# INDEX is needed to say which finger / which touch it is (great simple way to 
	# represent that
	var finger1Press = InputEventScreenTouch.new()
	var finger2Press = InputEventScreenTouch.new()
	
	# flip it. Q: Do we even need this? 
	#is_pressed = !is_pressed
	
	
	finger1Press.set_index(0)
	finger2Press.set_index(1)
	finger1Press.pressed = true
	finger2Press.pressed = true
	
	# drag goes from 20 -> 200 -> 400 and opposite
	
	# distance...                   100, 200 (add?) = 300
	if direction == "ZOOM_IN":
		# start close together, then end far apart
		finger1Press.position = Vector2(centerPos.x + 300,centerPos.y + 300)
		finger2Press.position = Vector2(centerPos.x + 300,centerPos.y + 400)
	else:
		# start far apart, then end close together
		finger1Press.position = Vector2(centerPos.x + 300,centerPos.y + 100)
		finger2Press.position = Vector2(centerPos.x + 300,centerPos.y + 600)
	
	
	## FIRST DRAG
	var finger1Drag = InputEventScreenDrag.new()
	var finger2Drag = InputEventScreenDrag.new()
	
	# distance...                     300, 400 (add?) = 700 - Zoom IN
	var finger1posAfterDrag : Vector2
	var finger2posAfterDrag : Vector2
	

	# first drag is center 
	finger1posAfterDrag = Vector2(centerPos.x + 300,centerPos.y + 200)
	finger2posAfterDrag = Vector2(centerPos.x + 300,centerPos.y + 500)
	
	finger1Drag.set_index(0)
	finger1Drag.set_position(finger1posAfterDrag)
	finger1Drag.relative = finger1posAfterDrag - finger1Press.position
	
	finger2Drag.set_index(1)
	finger2Drag.set_position(finger2posAfterDrag)
	finger2Drag.relative = finger2posAfterDrag - finger2Press.position
	
	## SECOND DRAG
	var finger1SecondDrag = InputEventScreenDrag.new()
	var finger2SecondDrag = InputEventScreenDrag.new()
	
	var finger1posAfterSecondDrag : Vector2
	var finger2posAfterSecondDrag : Vector2
	
	if direction == "ZOOM_IN":
		# start close together, then end far apart
		finger1posAfterSecondDrag = Vector2(centerPos.x + 300,centerPos.y + 100)
		finger2posAfterSecondDrag = Vector2(centerPos.x + 300,centerPos.y + 600)
	else:
		# start far apart, then end close together
		finger1posAfterSecondDrag = Vector2(centerPos.x + 300,centerPos.y + 300)
		finger2posAfterSecondDrag = Vector2(centerPos.x + 300,centerPos.y + 400)
	
	finger1SecondDrag.set_index(0)
	finger1SecondDrag.set_position(finger1posAfterSecondDrag)
	finger1SecondDrag.relative = finger1posAfterSecondDrag - finger1Drag.position
	
	finger2SecondDrag.set_index(1)
	finger2SecondDrag.set_position(finger2posAfterSecondDrag)
	finger2SecondDrag.relative = finger2posAfterSecondDrag - finger2Drag.position
	
	## release
	var finger1Release = InputEventScreenTouch.new()
	var finger2Release = InputEventScreenTouch.new()
	
	finger1Release.set_index(0)
	finger1Release.set_position(finger1posAfterDrag)
	
	finger1Release.set_index(1)
	finger2Release.set_position(finger2posAfterDrag) 
	
	# set position?
#	evt.action = 
	
	# emit the 2 simulated events
	Input.parse_input_event(finger1Press)
	Input.parse_input_event(finger2Press)
	
	Input.parse_input_event(finger1Drag)
	Input.parse_input_event(finger2Drag)
	
	Input.parse_input_event(finger1SecondDrag)
	Input.parse_input_event(finger2SecondDrag)
	
	Input.parse_input_event(finger1Release)
	Input.parse_input_event(finger2Release)
#	 a.set_button_index(1)
#     a.set_pressed(true)
#     Input.parse_input_event(a)
	
	
#	var cancel_event = InputEventAction.new()
#	cancel_event.action = "ui_cancel"
#	cancel_event.pressed = true
#	Input.parse_input_event(cancel_event)


func draw_tap_feedback_circle(newPosition:Vector2):
	# move circle (position is relative to parent el "touchFeedback" area2d node
	self.position = newPosition
	
	# is there lag here with this?
	# or because this is physics I probably need to wait to run this until the physics cycle is done...
	# Q: Or can we avoid this if we tie this to the event?
	
	# scale and transparency props are on the circlesprite
#	$CircleSprite.scale = Vector2(3, 3)
	$CircleSprite.scale = Vector2(0, 0)
	$CircleSprite.modulate = Color(1,1,1, .5)
	
	
	# hide
	print('\n\n-->draw_feedback_circle')
	## 2) Tween
	var tween = get_tree().create_tween().set_parallel(false)
#	tween.tween_property(self, "modulate", Color.RED, 3).set_trans(Tween.TRANS_BOUNCE)
#	tween.tween_property(self, "modulate", Color(0.11,1,1,.5), .2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property($CircleSprite, "modulate", Color(0.65,.1,.86,.5), .1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)
	tween.tween_callback(on_tween_done.bind(tween)) # check for overlap
	tween.tween_property($CircleSprite, "scale", Vector2(MAX_CIRCLE_SIZE,MAX_CIRCLE_SIZE), .2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	tween.tween_property($CircleSprite, "modulate", Color(0.65,.1,.86, 0), .01).set_ease(Tween.EASE_OUT)
	## can we push the overlap detection earlier?
	
#	tween.tween_property(self, "scale", Vector2(), 1)
#	tween.tween_property(self, "scale", Vector2(), 1).set_trans(Tween.TRANS_BOUNCE)
		
	# don't remove it since we only have one
	tween.tween_callback(on_tween_done.bind(tween))


func on_tween_done(tween):
	# disable the collision circle
	# OR just set "monitoring" to false
	print('tween DONE')
	# checking for overlap avoids getting stale overlapping areas
	if self.has_overlapping_areas():
		# stop feedback animation
#		tween.stop()
		
		# emit signal that we have a shape that's marked within feedback circle area
		print('overlaps', self.get_overlapping_areas())
		
		# only match one at a time
		var first_found_shape = self.get_overlapping_areas()[0]
		emit_signal("shape_found", first_found_shape)



## alt + shift click zoom out. Just where you click

func getScrollVectorPos():
	return Vector2(scrollContainer.scroll_horizontal, scrollContainer.scroll_vertical)

# if scrollPos has changed
# scroll pos with 
func hasScrollPosChanged(startScrollPos: Vector2, endScrollPos: Vector2):
	if isEventDrag(startScrollPos, endScrollPos):
		return true
	else:
		return false
		
# if within deadzone, then consider it a touch (with a little movement) vs a drag
func isEventDrag(startPos: Vector2, endPos: Vector2):
	
	var drag_distance = startPos.distance_to(endPos)
	# FIXME: Maybe we pull that value so they are always the same...
	# this number (100) lines up PERFECTLY with "scroll_deadzone" on ScrollContainer
	return drag_distance > 100
	
	
	
## debounce this	
#var calls = 0
# where to zoom in, zoom_factor_change:  +2.5 = zoom in 2.5x OR -1.5 = zoom OUT 1.5x
func emit_should_zoom(zoomPosition: Vector2, zoom_factor_change: float):
	emit_signal("should_zoom", zoomPosition, zoom_factor_change)
#	calls += 1
#	await debounceZoom(dist)
#	calls -= 1

# annoying but must do this way...
#@onready var timer = get_tree().create_timer(4).timeout

#func debounceZoom(dist):
##	var shouldLock
#
#	print("calls:before ", calls)
#	await get_tree().create_timer(.5).timeout
#
#
#	print("calls:after ", calls)
#
#	if calls == 1:
#		call_deferred("emit_signal", "should_zoom", true, dist)
##		emit_signal("should_zoom", true, dist)
	


