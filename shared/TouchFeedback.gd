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
var eventState = {
	# lua style assign turns key into string (nice)
	# all will be stored by event index
	pressed = {}, # store event by index. If several are in here, then we have multi touch
	released={},
	dragged = {} # store pressed indexes being dragged. Will remain after release for calcs,
	# but will allow us to calc results that we want? Maybe undo this...
	# FIXME: Wipe out
}




######### event helpers
func isMultiTouchPress():
	# this will only give us multitouch press, but not multitouch release
	return eventState.pressed.size() > 1
	
func isMultiTouchDrag():
	return eventState.dragged.size() > 1
	


# Called when the node enters the scene tree for the first time.
func _ready():
	# scale the collision shape down to max_size to match circle size
	$CollisionCircle.scale = Vector2(MAX_CIRCLE_SIZE, MAX_CIRCLE_SIZE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func on_touch_screen(newPosition:Vector2):
	
	# move circle (position is relative to parent el "touchFeedback" area2d node
	self.position = newPosition
	
	# is there lag here with this?
	# or because this is physics I probably need to wait to run this until the physics cycle is done...
	# Q: Or can we avoid this if we tie this to the event?
	
	
	# scale and transparency props are on the circlesprite
#	$CircleSprite.scale = Vector2(3, 3)
	$CircleSprite.scale = Vector2(0, 0)
	$CircleSprite.modulate = Color(1,1,1, .5)
	
	# fade and bounce in
	
	# hide
	print('###on_touch_screen')
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

#func _on_canvas_container_gui_input(event):
#	on_touch_screen() # Replace with function body.
var clickStartPos
var click_circle_pos
func _on_image_container_gui_input(event):
#	print('event', event)

	# we COULD use this to listen for dragging, but we'd still need the distance logic we have 
	# below. Not sure this simplifies anything
#	if event.get_class() == "InputEventScreenDrag":
#		print("DRAG")
#
	## The drag sensitivity here should match the sensitivity on the scrolling 
	## (scroll deadzone on the ScrollContainer) node...


	# FIXME: Improve this touch event routing logic
	# TODO: Make helpers for isTouchDrag, isMultiTouchPress, isMultiTouchRelease
	# I could use the button with multi support, but maybe we just create a eventStateMap instead...
	# yas. Can reuse in the future. LOVE THIS SHIZ

	# listen for FAKE multi touch from laptop
	if event.get_class() == "InputEventMouseButton":
		if event.alt_pressed && event.shift_pressed:
			# emulate multi touch zoom OUT
			pass
		elif event.alt_pressed:
			# emulate multi touch ZOOM IN
			print("\nCLICK", event, event.alt_pressed)
			simulateMultiTouchPinch()

	# TODO: Use pattern matching / switch statement?
#	if event.get_class() == "InputEventScreenDrag":
#		eventState.dragged[event.index] = event
#		print("\n### TOUCH SCREEN DRAG", event)
#		handleZoomTouchEvents(event)
		
		

	## TODO: split this out into separate functions?
	if event.get_class() == "InputEventScreenTouch":
		print("\nTOUCH", event)
		
		print("\n\n##eventState", eventState)
		
#		handleZoomTouchEvents(event)
		if event.double_tap:
			print("DOUBLE TAP")
			emit_should_zoom(event.position) # fire the "should zoom" event
			return
	
		if event.is_pressed():
			eventState.pressed[event.index] = event
			clickStartPos = event.get_position()
#			print('###DOWN')
			
		else:	
			eventState.pressed.erase(event.index)

#			print('###Touch RELEASE')
			var clickEndPos = event.get_position()
			# move the feedback circle
			click_circle_pos = clickEndPos
			
			
			# todo: Add check for multi touch
			if !isEventDrag(clickStartPos, clickEndPos):
				# if touch and NOT drag, then move the touch effect
				print("\n\n##call on_touch_screen()")
				
				if event.double_tap:
					print("DOUBLE TAP")
				else:
					on_touch_screen(clickStartPos)
#				print('SAME POS')

			# if CLICK DRAG do nothing. 
			# LATER detect pinch to zoom IN or OUT
			else:
				print("\n##IS DRAG")
				# for now do NOTHING
				# is multitouch drag

#				return handleZoomTouchEvents(event)

#				print('new pos')
	#		print('click_input', event)
			# compare the release position to the click position
			
	#		print('click_input2', event.get_position())
			
#		destroy_and_spawn_click_circle(event.get_position().x, event.get_position().y)

# handle first touch, and then release?
# TODO: consider using touchscreen button as a giant button overlay to detect the multi touch b
# buttons on that node...
func handleZoomTouchEvents(event):
	print('\n\n##HandleDrag', event.as_text())


	# tells us which finger it is
	var index = event.index
	
	
	match (event.get_class()):
		"InputEventScreenTouch":
			# store in event map
			if event.is_pressed():
				eventState.pressed[index] = event
#				eventState.released.erase(index) # clear the released one. Do we need to store current state?
				
				# are multiple fingers being used atm?
				if isMultiTouchPress():
					var pressedDist = eventState.pressed[0].position.distance_to(eventState.pressed[1].position)
					print('\n\n###pressedDist', pressedDist)
			else:
				eventState.released[index] = event
#				eventState.pressed.erase(index)
				# process it, then wipe it.
			pass
		"InputEventScreenDrag":
			# if it's single drag, we want it to scroll
			# are multiple fingers being dragged?
			
			#get distance and direction it's going in...
			eventState.dragged[index] = event
				
			if isMultiTouchDrag() && isMultiTouchPress():	
				# has the distance between the points INCREASED or decreased?
				var draggedDist = eventState.dragged[0].position.distance_to(eventState.dragged[1].position)
				var pressedDist = eventState.pressed[0].position.distance_to(eventState.pressed[1].position)
				
				#compare dist between touch points
				# has the distance between fingers INCREASED or DECREASED?
#				if draggedDist > pressedDist:
#					# FIXME: Add a check for how many events...
##					print("###########ZOOOM IN")
##					if !locked:
##						pass
##						emit_should_zoom(draggedDist - pressedDist) 
##						eventCooldown()
#				else:
##					print("###########ZOOOM OUUUUUUT")
#					pass
				
				# compare both distances...
				# Should we STORE this somewhere?!?
				
				
			# can we take action until both have been processed? Or do we need to capture which we have so far?
			# like streaming events?

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


## TODO: Simulate pinch

## alt click? + zoom in
var is_pressed = false
func simulateMultiTouchPinch(): # for ZOOM
	# INDEX is needed to say which finger / which touch it is (great simple way to 
	# represent that
	var finger1Press = InputEventScreenTouch.new()
	var finger2Press = InputEventScreenTouch.new()
	
	# flip it. Q: Do we even need this? 
	is_pressed = !is_pressed
	
	
	finger1Press.set_index(0)
	finger1Press.pressed = true
	finger1Press.position = Vector2(200,200)
	
	finger2Press.set_index(1)
	finger2Press.pressed = true
	finger2Press.position = Vector2(300,400)
	
	
	
	var finger1Drag = InputEventScreenDrag.new()
	var finger2Drag = InputEventScreenDrag.new()
	
	finger1Drag.set_index(0)
	finger1Drag.set_position(Vector2(100, 100))
	
	finger2Drag.set_index(1)
	finger2Drag.set_position(Vector2(400, 500))
	
	# set position?
#	evt.action = 
	
	# emit the 2 simulated events
	Input.parse_input_event(finger1Press)
	Input.parse_input_event(finger2Press)
	
	Input.parse_input_event(finger1Drag)
	Input.parse_input_event(finger2Drag)
#	 a.set_button_index(1)
#     a.set_pressed(true)
#     Input.parse_input_event(a)
	
	
#	var cancel_event = InputEventAction.new()
#	cancel_event.action = "ui_cancel"
#	cancel_event.pressed = true
#	Input.parse_input_event(cancel_event)

## alt + shift click zoom out. Just where you click

		
# if within deadzone, then consider it a touch (with a little movement) vs a drag
func isEventDrag(startPos: Vector2, endPos: Vector2):
	var drag_distance = startPos.distance_to(endPos)
	# FIXME: Maybe we pull that value so they are always the same...
	# this number (100) lines up PERFECTLY with "scroll_deadzone" on ScrollContainer
	return drag_distance > 100
	
	
	
## debounce this	
#var calls = 0
func emit_should_zoom(zoomPosition):
	emit_signal("should_zoom", zoomPosition)
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
	


