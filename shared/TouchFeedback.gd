extends Area2D

signal shape_found
signal should_zoom

# right now we align them fully in the editor GUI
# so the circle and collision obj are the exact same size at full size.
# now that we don't use the full size we need to ensure the collision area
# matches the size of the circle at full animation size
# FIXNE: should we be scaling the parent area2d instead?
var MAX_CIRCLE_SIZE = .5 #scale prop

var min_zoom = 0
var max_zoom = 2


var zoom_level = 1
var last_drag_distance = 0
var zoom_sensitivity = 10
var zoom_speed = 0.05


# keep track of event clicks
var events = {}
var scroll_start_pos: Vector2


# Dict for an event state map, to keep track of what events are in progress, and how many...
#var event_state = {
	#status = "no_touch",  # one-touch, # two-touch, # three-touch # drag
	## lua style assign turns key into string (nice)
	#
#}
#
## these are the ONLY valid states for the FSM to be in...
#var finite_states = {
	#"no_touch" : {
		#status = "no_touch"
	#}, 
	#"one_touch_press" : { # in progress
		#status = "one_touch_press",
		#pos = Vector2()
	#}, 
	#"one_touch_drag_scroll" : { # in progress
		#status = "one_touch_drag_scroll",
		#start_pos = Vector2() # position where the drag started
	#},
	#
	#"multi_touch_press": {
		#status = "multi_touch_press",
		#touch_points = {} # number based dict / array. Will include state for each touch point
	#},
	#
	#"multi_touch_drag_zoom": { # multi touch drag for purpose of zoom in/out in progress
		#status = "multi_touch_drag_zoom",
		#touch_points = {}, # number based dict / array. Will include state for each touch point
		#distance = 0 # distance between the pinched fingers (usually use 0 and 1)
	#}
#}




## TODO: Verify then add dragging and pinch & zoom
## Like redux i need to fire every time state is updated
## https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html





#@onready var scrollContainer = get_node("/root").get_tree()
@onready var scrollContainer = get_node('%ScrollContainer')



# Called when the node enters the scene tree for the first time.
func _ready():
	# scale the collision shape down to max_size to match circle size
	$CollisionCircle.scale = Vector2(MAX_CIRCLE_SIZE, MAX_CIRCLE_SIZE)
	
	min_zoom = get_min_zoom_from_image_size()
	
	## start at minimum zoom allowed
	print('min_zoom', min_zoom)
	
func get_min_zoom_from_image_size():
	var imageSize = get_node('%hidden_objects_image').size
	imageSize.x += 111 # account for home button left notch
	
	# based on screenSize (pretty fixed)
	var min_width_allowed = scrollContainer.size.x - 15  # 1742 (2000 - 258) 258 is right rail
	var min_height_allowed = scrollContainer.size.y - 15 # 1000 (since viewport is 2000x1000
	
	#print('imageSize', imageSize)
	#print("Vector2(min_width_allowed, min_height_allowed)", Vector2(min_width_allowed, min_height_allowed))
	
	# FIXME: Can I simplify this math?	
	var min_zoom_allowed_vector = (Vector2(min_width_allowed, min_height_allowed) / imageSize)
	#print("min_zoom_allowed_vector", min_zoom_allowed_vector)
	var min_zoom_allowed = max(min_zoom_allowed_vector.x, min_zoom_allowed_vector.y)

	return min_zoom_allowed
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	

func _on_image_container_gui_input(event):
	# I bet it's relative to THAT node now...
	# So if we want to keep it in _unhandled, we have to get the x,y of that and offset it manually
	#print('event.pos gui_input', event.position)
	if event is InputEventScreenDrag:
		if event.index < 2: # save 0 and 1 only
			events[event.index] = event
			
	
	if event is InputEventScreenTouch:
		if event.pressed:
			scroll_start_pos = getScrollVectorPos()
			#drag_start_pos = event.position
			
			# ignore any touch past the first 2 fingers...
			if event.index < 2: # save 0 and 1 only
				events[event.index] = event
				
			get_viewport().set_input_as_handled()
		
		else:
			#print('touch-release', event)
			## Reading...
			# https://forum.godotengine.org/t/godot-3-0-2-get-global-position-from-touchscreen/27397
			## Avoid showing touch feedback after pinch-zoom. 
			
			# TODO: Could I just use a scrollEvent? That I can reset?
			var scroll_end_pos = getScrollVectorPos()
			var hasScrolled = hasScrollPosChanged(scroll_start_pos, scroll_end_pos) # this uses the built in deadzone in the scrollcontainer
			
			if !hasScrolled: 
				draw_tap_feedback_circle(event.position)
			
			# agressively release. Assume if one finger is releasing, they all are...
			#events.erase(event.index)
			events.erase(0)
			events.erase(1)
			
			
			# mark this event as handled so it doesn't get processed by unhandled_input...
			#https://www.nightquestgames.com/handling-user-input-in-godot-4-learn-how-to-do-it-properly/
			get_viewport().set_input_as_handled()
			
			## Avoid showing touch feedback after pinch-zoom. 
			## TODO: Consider erasing ALL events after one finger releases...
			#if events.is_empty():
				#print('dragging=false')
				#is_dragging = false
			#drag_start_pos = event.position # FIXME
			
			


func _unhandled_input(event):
	# EMULATE pinch & zoom while on desktop for FAKE multi touch from laptop
	#if event.get_class() == "InputEventMouseButton":
		##print("\n->inside mouse click: ", event)
		#if event.alt_pressed && event.shift_pressed:
			##print('MOUSE BUTTON ZOOM OUT HANDLER')
			## emulate multi touch zoom OUT
			#simulateMultiTouchZoom({center_of_touch = event.position, direction = "ZOOM_OUT"})
			#return
#
		#elif event.is_alt_pressed():
			## emulate multi touch ZOOM IN
			##print('MOUSE BUTTON ZOOM IN HANDLER')
			##print("\nCLICK", event, event.alt_pressed)
			#simulateMultiTouchZoom({center_of_touch = event.position, direction = "ZOOM_IN"})
			#return

	handle_touch_events(event)

# single touch drag (need to capture this separately, because of coord system). 
var unhandled_start_pos: Vector2
func handle_touch_events(event: InputEvent):
	
	# COMPLETELY ignore mouse events (on desktop we emulate touch events)
	if event is InputEventMouse:
		#print('event', event.position)
		#print('event', event.global_position)
		return
	
		#if event is InputEventMouseButton && event.is_alt_pressed() && event.is_shift_pressed():
			#zoom_level *= 0.95
			##zoom -= Vector2(.05, .05)
		#
		#elif event is InputEventMouseButton && event.is_alt_pressed():
			#zoom_level *= 1.05
			#zoom += Vector2(.5, .5)
			#limit_right = img_size.x + 258 * zoom.x
			#print('limit_right', limit_right)
			#set_physics_process(true)
		
	# zoom via smartpad on mac
	# nice way to emulate some of the same functionaolity on desktop
	if event is InputEventMagnifyGesture:
		var new_zoom = clamp(zoom_level * event.factor, min_zoom, max_zoom)
		print('new_zoom:after', new_zoom)
		#print("new_zoom", new_zoom)
		zoom_level = new_zoom
		emit_should_zoom(event.position, zoom_level)
		return
		#zoom_level = clamp(zoom.x * new_zoom, min_zoom, max_zoom)
		#print("new_zoom from mac pad", new_zoom)
		#zoom = Vector2.ONE * new_zoom
		#zoom = lerp(zoom, Vector2.ONE * new_zoom, 0.4)

	
	# we need to handle both of these in gui_input_event because bubbling order will mess things up
	
			
			## handle this from the other gui_input_event so it calcs the top left
			## offset properly
			
	if event is InputEventScreenDrag:
		print('event-drag ', event)
		#if event.index < 2: # save 0 and 1 only
			#events[event.index] = event
			
		if events.size() == 1:
			
			
			#var relative_dist: Vector2 = event.relative.rotated(rotation)
			#var dist = relative_dist.distance_to(relative_dist)
			#print('dist', relative_dist)
			#is_dragging = true
			pass
			# Q: Can we just let this pass through to the scrollcontainer?
			
			
			#var screenSize = get_viewport().get_visible_rect().size
			
			
			#posChangeBufferX += event.relative.rotated(rotation).x * zoom.x # Does this even help?
			#posChangeBufferY += event.relative.rotated(rotation).y
		elif events.size() == 2:
			
			# distance between finger and thumb
			var drag_distance = events[0].position.distance_to(events[1].position)
			print('drag_dist: ', drag_distance)
			
			# dead zone for when to start zoom
			# this logic seems to work pretty well
			if abs(drag_distance - last_drag_distance) > zoom_sensitivity:
				# zoom in or zoom out? (flip it. Not sure why that's needed)
				var new_zoom = (1 + zoom_speed) if drag_distance > last_drag_distance else (1 - zoom_speed)
				print('new_zoom:before', new_zoom)
				new_zoom = clamp(zoom_level * new_zoom, min_zoom, max_zoom)
				print('new_zoom:after', new_zoom)
				#print("new_zoom", new_zoom)
				zoom_level = new_zoom
				print('zoom_level', zoom_level)
				last_drag_distance = drag_distance
				emit_should_zoom(event.position, zoom_level)

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
#func simulateMultiTouchZoom(props): # for ZOOM
	#var centerPos = props.center_of_touch
	#var direction = props.direction # ZOOM_IN | ZOOM_OUT
	#
	#
	#
	##print('## SIMULATING multi touch PINCH')
	## INDEX is needed to say which finger / which touch it is (great simple way to 
	## represent that
	#var finger1Press = InputEventScreenTouch.new()
	#var finger2Press = InputEventScreenTouch.new()
	#
	## flip it. Q: Do we even need this? 
	##is_pressed = !is_pressed
	#
	#
	#finger1Press.set_index(0)
	#finger2Press.set_index(1)
	#finger1Press.pressed = true
	#finger2Press.pressed = true
	#
	## drag goes from 20 -> 200 -> 400 and opposite
	#
	## distance...                   100, 200 (add?) = 300
	#if direction == "ZOOM_IN":
		## start close together, then end far apart
		#finger1Press.position = Vector2(centerPos.x + 300,centerPos.y + 300)
		#finger2Press.position = Vector2(centerPos.x + 300,centerPos.y + 400)
	#else:
		## start far apart, then end close together
		#finger1Press.position = Vector2(centerPos.x + 300,centerPos.y + 100)
		#finger2Press.position = Vector2(centerPos.x + 300,centerPos.y + 600)
	#
	#
	### FIRST DRAG
	#var finger1Drag = InputEventScreenDrag.new()
	#var finger2Drag = InputEventScreenDrag.new()
	#
	## distance...                     300, 400 (add?) = 700 - Zoom IN
	#var finger1posAfterDrag : Vector2
	#var finger2posAfterDrag : Vector2
	#
#
	## first drag is center 
	#finger1posAfterDrag = Vector2(centerPos.x + 300,centerPos.y + 200)
	#finger2posAfterDrag = Vector2(centerPos.x + 300,centerPos.y + 500)
	#
	#finger1Drag.set_index(0)
	#finger1Drag.set_position(finger1posAfterDrag)
	#finger1Drag.relative = finger1posAfterDrag - finger1Press.position
	#
	#finger2Drag.set_index(1)
	#finger2Drag.set_position(finger2posAfterDrag)
	#finger2Drag.relative = finger2posAfterDrag - finger2Press.position
	#
	### SECOND DRAG
	#var finger1SecondDrag = InputEventScreenDrag.new()
	#var finger2SecondDrag = InputEventScreenDrag.new()
	#
	#var finger1posAfterSecondDrag : Vector2
	#var finger2posAfterSecondDrag : Vector2
	#
	#if direction == "ZOOM_IN":
		## start close together, then end far apart
		#finger1posAfterSecondDrag = Vector2(centerPos.x + 300,centerPos.y + 100)
		#finger2posAfterSecondDrag = Vector2(centerPos.x + 300,centerPos.y + 600)
	#else:
		## start far apart, then end close together
		#finger1posAfterSecondDrag = Vector2(centerPos.x + 300,centerPos.y + 300)
		#finger2posAfterSecondDrag = Vector2(centerPos.x + 300,centerPos.y + 400)
	#
	#finger1SecondDrag.set_index(0)
	#finger1SecondDrag.set_position(finger1posAfterSecondDrag)
	#finger1SecondDrag.relative = finger1posAfterSecondDrag - finger1Drag.position
	#
	#finger2SecondDrag.set_index(1)
	#finger2SecondDrag.set_position(finger2posAfterSecondDrag)
	#finger2SecondDrag.relative = finger2posAfterSecondDrag - finger2Drag.position
	#
	### release
	#var finger1Release = InputEventScreenTouch.new()
	#var finger2Release = InputEventScreenTouch.new()
	#
	#finger1Release.set_index(0)
	#finger1Release.set_position(finger1posAfterDrag)
	#
	#finger1Release.set_index(1)
	#finger2Release.set_position(finger2posAfterDrag) 
	#
	## set position?
##	evt.action = 
	#
	## emit the 2 simulated events
	#Input.parse_input_event(finger1Press)
	#Input.parse_input_event(finger2Press)
	#
	#Input.parse_input_event(finger1Drag)
	#Input.parse_input_event(finger2Drag)
	#
	#Input.parse_input_event(finger1SecondDrag)
	#Input.parse_input_event(finger2SecondDrag)
	#
	#Input.parse_input_event(finger1Release)
	#Input.parse_input_event(finger2Release)
#	 a.set_button_index(1)
#     a.set_pressed(true)
#     Input.parse_input_event(a)
	
	
#	var cancel_event = InputEventAction.new()
#	cancel_event.action = "ui_cancel"
#	cancel_event.pressed = true
#	Input.parse_input_event(cancel_event)


func draw_tap_feedback_circle(newPosition:Vector2):
	print('newPosition', newPosition)
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
	if startScrollPos == endScrollPos:
		return false
	else:
		return true
	#if isEventDrag(startScrollPos, endScrollPos):
		#return true
	#else:
		#return false
		
# if within deadzone, then consider it a touch (with a little movement) vs a drag
func isEventDrag(startPos: Vector2, endPos: Vector2):
	
	var drag_distance = startPos.distance_to(endPos)
	# FIXME: Maybe we pull that value so they are always the same...
	# this number (100) lines up PERFECTLY with "scroll_deadzone" on ScrollContainer
	return drag_distance > 100
	
	
	
## debounce this	
#var calls = 0
# where to zoom in, zoom_factor_change:  +2.5 = zoom in 2.5x OR -1.5 = zoom OUT 1.5x
func emit_should_zoom(zoomPosition: Vector2, new_zoom_level: float):
	## TODO: deprecate passing the zoomPosition
	emit_signal("should_zoom", new_zoom_level)
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
	




