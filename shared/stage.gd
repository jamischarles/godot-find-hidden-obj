extends Node

# TODO: make this auto increment? Use another node id?

#@export_file("./img.png") 
@export var img: CompressedTexture2D


# FIFO array limit 2
# todo: add the shape idx too, because we don't want to allow clicking the same item twice for a match.
# clamp this 
#var last_2_zones_clicked: Array[Dictionary] = []
#var current_score = 0 # how many have been solved so far?
#@onready var total_match_sets: int = $click_zone_container.get_child_count() / 2 #expect click_zones / 2
#var total_match_sets = 10

# quality assertions. Can we make these dev only?!?
# OR should I use these to verify match?
var assert_verify_matches = {} # [name]: [count]. Then assert that each is exactly two.


# from canvas
var selected_canvas_shapes_ref: Array[Area2D]

# from right rail
var selected_obj_ref2: Button

# tracks our touch target on big image
var canvas_click_circle: Polygon2D


@onready var legend_button_group: ButtonGroup = $HBoxContainer/right_rail.get("legend_button_group")
@onready var clickZoneContainer = $HBoxContainer/ScrollContainer/HBoxContainer/CanvasContainer/click_zone_container


# Simplest shape solution...
# Draw a few polygons that have the 3-4 shapes I care about 
# circle etc... Then duplicate those whenever I need a new kind of shape.
# then use programming to create the collisionshape and place it based on that...
# Then we could have the same solution for all kinds of shapes.

# Next steps....
# 1. add all animals
# 2. test build on ipad
# 3. Commit and push to GH
# 4. Add hint
# 5. add click target feedback? just on screen. and on legend item...



# 1. Handle "matchIsFound"
#	X- disable collision zones
#	X- mark them as grayed out
#	- keep count of matches "3/5"
#	X- fix positioning bug


# Once I have a stable build, commit and push to github...

# 2. Add support for other shapes
#  X- circle
#  X- capsule
#  - square (LATER)

#LATER




# 1. Use a nicer image (no watermark)
# 2. lay out the template / hints
# 3. Create a scene for "clickzone".
# 4. Create each as an instance, then allow a separate polygon to be defined 
# ^ fix the signals (automagically?) for that... similar to how we do it with the gems?
# 5. copy from shape to collision with code
# 6. add code to black out the legend and matched pair
# ?7. create a copy in the legend, and hook them both up
# 8. write logic that says they must be clicked next to each other (make that obvious in the UI)




# Cleanup...
# Consider mirror nodes? that we can move around with exact same shape?

# Called when the node enters the scene tree for the first time.
func _ready():
#	TODO: automagically copy the polygon for collision detection
#	https://ask.godotengine.org/10501/polygon2d-coordinates-to-collisionpolygon2d

	legend_button_group.connect("changed", on_button_group_change)
	print('legend_button_group', legend_button_group)
	
	$HBoxContainer/ScrollContainer/HBoxContainer/CanvasContainer/ClickCircle.connect("found_hidden_objects_on_canvas", on_canvas_shapes_found)
	# connect to all click zones so we can act on them from here?
	# do we need to?
	# yes let's try this for now. We can change later...
	# Can I auto assign all the children in the container to the group? Or maybe just use this to get all the children...
	#var guards = get_tree().get_nodes_in_group("click_zone_group")
	
	
#	print("##animalsBtnGroup", animalsBtnGroup)
	
	
#	var clickZones =$HBoxContainer/ScrollContainer/click_zone_container.get_children()
#	var clickZones =$HBoxContainer/ScrollContainer/Control.get_children()
	var clickZones =$HBoxContainer/ScrollContainer/HBoxContainer/CanvasContainer/click_zone_container.get_children()
	
#	var clickZones = []
	#for clickZone in clickZones:
	for i in len(clickZones):
	
		
		var clickZone = clickZones[i]
		print('x', clickZone.get_class())
		if clickZone.get_class() != "Area2D": continue

		# 1) verify there's a shape. Create a matching collision shape
		var shape = clickZone.get_child(0) # assume only one shape child
#		print('type', shape.type)



		
		# TODO: support othere shapes as well...
		if shape.get_class() == "Polygon2D":
			var polygon = shape.get_polygon()
			var matching_click_target = CollisionPolygon2D.new()
			clickZone.add_child(matching_click_target)
			
			matching_click_target.set_polygon(polygon)
			
		
			
			#matching_click_target.shape.set_polygon(polygon)
		elif shape.get_class() == "CollisionShape2D":
			var polygon: PackedVector2Array
#			print('shape', shape.get_shape())
#			print('shape2', shape.get_shape().get_rect())
#			var otherShape = shape.get_shape().get_rect()
			
			var collisionShape = shape.get_shape()
			
			
			var radius = collisionShape.radius
#			var position = collisionShape.get_rect().position
			var position = clickZone.position
			
			
			if collisionShape.get_class() == "CircleShape2D":
				# we want to explicitly set x,y to zero, because the parent controls the positioning
				polygon = generate_circle_polygon(radius, 40, Vector2(0,0))
				
			elif collisionShape.get_class() == "CapsuleShape2D":
				var height = collisionShape.height
				polygon = generate_capsule_polygon(radius, 40, height)
				
			
			print('pos0', clickZone.position)
			print('pos1', shape.position)
			print('pos2', collisionShape.get_rect().position)
			
#			print('shapeClass', shape.get_shape().get_class())
#			print('shapeClass', shape.get_shape().height)
#			print('shapeClass', shape.get_shape().radius)
#			print('shapeClass', )
			
			# TODO: check for capsule, square, circle...
			
#			if 
			
			
			
			
			# 40pt min for smooth circle?
#			var polygon: PackedVector2Array = generate_circle_polygon(radius, 40, position)
#			var polygon: PackedVector2Array = generate_circle_polygon(radius, 40, Vector2(0,0))
			
			var visible_shape = Polygon2D.new()
#			visible_shape.draw_colored_polygon()
			
			clickZone.add_child(visible_shape)
#			visible_shape.draw_circle(Vector2(500,200), 500, Color(1,1,1,1))
#			visible_shape.draw_circle(Vector2(800,500), 500, Color(1,1,1,1))
			print('drawing circle', visible_shape)
			visible_shape.set_polygon(polygon)
#			visible_shape.draw_colored_polygon(polygon, Color(1,1,1,1))
			
			
			
			print('visible?', visible_shape.is_visible_in_tree())
#			visible_shape.position = Vector2(200, 300)
			print('pos', visible_shape.position)
			# with circle I guess you only need x,y and radius
#			CircleShape2D
			
			# what about capsule and square?
			#CapsuleShape2D
			# x,y, radius, height

			# rect: x,y, size: width,height			
#			RectangleShape2D

			
			# f
			
#			
			
			
			var matching_click_target = CollisionPolygon2D.new()
			clickZone.add_child(matching_click_target)
			
#			matching_click_target.set_polygon(shape.get_shape())
			
#			shape.get_shape().draw()
			
		
		# if node is Node
		
#		print('shape', shape.polygon) # maybe what we need to copy?
#		print('shape1', shape.get_shape())
#		print('shape2', shape.get_polygon())


		# Verify that each collision shape has position of 0,0
		# we need to use parent for positioining so clickzones line up with visual part
		assert( int(shape.position.x) == 0 && int(shape.position.y) == 0, "ERROR: Each child CollisionShape MUST be 0,0 to avoid clickZone drift: %s, shape name:%s" % [shape.position, clickZone.name]);

		# 2) verify each shape has a name
		# throw when shape_names aren't assigned for each click zone
		# https://ask.godotengine.org/54948/throw-exception-or-error
		# confusing because eval is opposite for err
#		var name = clickZone.shape_name
#		assert( name != "", "ERROR: You must give each clickZone a shape_name value.");
		
		# node name
		var name = clickZone.get_name()
		
		# add up the canvas clickzones
		if assert_verify_matches.has(name):
			assert_verify_matches[name] += 1
		else:
			assert_verify_matches[name] = 1
		
		# TODO: add assertion to ensures there's a matching pair for each one... (same shape and size)?
		# we can create a dictionary and count that each one has 2
		
		print("i", i)
		print('nodeNUm', clickZone.get_instance_id())
#		clickZone.shape_uid = i
		
		# listen to click for each click shape
#		clickZone.connect('click_shape_clicked', on_shape_clicked)
		
		# hide all the click zones so they are invisble

		# set alpha to 0 so click zones are invisible to user but still active
		clickZone.set_modulate(Color(1, 1, 1, 0))
		
	# assert that each clickZone has exactly one match (by name)
	# TODO: Fix this for right rail
	
	# VERIFY: there should be exactly one of each currently in the clickzones
	for zone in assert_verify_matches:
		assert(assert_verify_matches[zone] == 1, "ClickZones: %s has %s" % [zone, assert_verify_matches[zone]])

	# count the right_rail button node names,
	var legendButtons = $HBoxContainer/right_rail/legend_for_hidden_objects.get_children()
	for btn in legendButtons:
		var btn_name = btn.get_name()
		## TODO: Reuse this? in fn?
		if assert_verify_matches.has(btn_name):
			assert_verify_matches[btn_name] += 1
		else:
			assert_verify_matches[btn_name] = 1
			
	# verify there's a match for each (exactly count of 2 now)
#	for zone in assert_verify_matches:
#		assert(assert_verify_matches[zone] == 2, "ClickZone/legendBtn mismatch: %s has %s" % [zone, assert_verify_matches[zone]])
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# Any time we click on a shape, or a right rail button we want to compare for a match
func compare_for_match(selected_object1, selected_object2):
	print('eval for match: ', selected_object1, selected_object2)
	
	# ensure we have 2 objects selected we can compare
	if !selected_object1 || !selected_object2: return

	
#	get which animal button is pressed
	
	# get selected right rail animal
	
	print("COMPARE:", selected_object1, selected_object2)
	
	
	if selected_object1.name == selected_object2.name:	
		## disable and color canvas collision shape click_zone
		on_match_found(selected_object1, selected_object2)
		
		
	
	
	
	# get current active click target on canvas (with circle)

# when a shape on the canvas is clicked, run the comparison
#func on_shape_clicked(shape_name: String, shape: Area2D):
#	selected_animal = shape
#	compare_for_match(shape, animalsBtnGroup.get_pressed_button())
	
		
#whenever the right rail selection changes it'll get updated in selected_object2
func on_button_group_change():
	print('button group changed!!')
	selected_obj_ref2 = legend_button_group.get_pressed_button()
	
	## TODO: Simplify and reuse
	
	for shape in selected_canvas_shapes_ref:
		compare_for_match(shape, selected_obj_ref2)
#	print('selectedAnimal2: ', selected_animal2)

#whenever overlapping shapes are found in canvas pass array of overlapping shapes
func on_canvas_shapes_found(shapes: Array[Area2D]):
	selected_canvas_shapes_ref = shapes
	# compare each overlapping shape passed in (from click circle)
	for shape in shapes:
		compare_for_match(shape, legend_button_group.get_pressed_button())

# on match found
func on_match_found(animal1, obj2: Button):
#	var firstNode = instance_from_id(firstUid)
	
	# canvas click zone. Gray out, then disable
	animal1.set_modulate(Color(.36, .36, .36, .74))
	# functionally - disable clicks
	animal1.set_pickable(false) # bubbles up from collisionlayer. Nice!
	
	
	## Right rail button. Disable and fade out
	obj2.disabled = true
	# stop using the shader, so we can effect the alpha channel of this
	obj2.use_parent_material = true
	obj2.set_modulate(Color(1,1,1,.5))
	obj2.get_parent().move_child(obj2, obj2.get_parent().get_child_count()) # move to end
	
#	obj2.icon.set_modulate(Color(1,1,1,.2))
#	obj2.icon.modulate = Color(1,1,1,.2)


	
	
#	 $Button.modulate = Color(0.5,0.5,0.5,1)
#  $$Button/sprite_itemIcon.modulate = Color(0.25,0.25,0.25)
	
	
	# Verify we have no more sets to match
	# ie: Is the level done?
#	current_score += 1
#	$HUD/score_label.set_text("%s / %s" % [current_score, total_match_sets])
	var right_rail_buttons = $HBoxContainer/right_rail/legend_for_hidden_objects.get_children()
	for btn in right_rail_buttons:
		print("name", btn.name)
		if !btn.is_disabled():
			return
			
	end_level()
#	for i in len(right_rail_buttons):
#		var btn = right_rail_buttons[i]
	
	

		# destroy the old one, create the new...
		# or do we just emulate and have the parent draw?
#		Yes. let's do that...
	
	
	
func end_level():
	$level_complete_panel.visible = true # show the 
	
#func destroy_and_spawn_click_circle(x:float,y:float):
##	
#	# destroy the old circle if it exists
#	if canvas_click_circle: canvas_click_circle.queue_free()
#
#	print('destroy: ', x,y)
#	var clickCircle: Area2D = Area2D.new()
#	var collision: CollisionShape2D = CollisionShape2D.new()
#	var shape: CircleShape2D = CircleShape2D.new()
#	shape.radius = 70
#
#
#
#	clickCircle.add_child(collision)
##	collision.shape.set("shape", "CircleShape2D")
#	collision.shape = shape

	# circle polygon
#	_draw(x,y)
	
	# TODO: Add tweening
	
	
	
#func _on_click_zone_input_event(viewport, event, shape_idx):
##	https://docs.godotengine.org/en/4.1/tutorials/inputs/inputevent.html
#	if event is InputEvent:
#		if event.is_pressed():
#			print("event", event)
#			print('shape# ', shape_idx)
#			print('SKUNK')
#	if event.pressed: 
#		print("view", viewport)
	
#		print("shape_idx", shape_idx)
#		print('click!')
	# Q: Can we use the ID to tie the source and matched animal together?

# UTILS ---------------


# interesting!!!
# @desc something
# TODO: add assertion for num_sides
# if num_sides is < 3 (triangle) then it won't show up. 4 is square. interesting...
# https://ask.godotengine.org/81776/how-to-shape-polygon2d-into-a-circle
func generate_circle_polygon(radius: float, num_sides: int, pos: Vector2) -> PackedVector2Array:
	var angle_delta: float = (PI * 2) / num_sides
	var vector: Vector2 = Vector2(radius, 0)
	var polygon: PackedVector2Array
	
	for _i in num_sides:
		polygon.append(vector + pos)
		vector = vector.rotated(angle_delta)
		
	return polygon
	

# Capsule
# A capsule is a circle, cut in half, with a rectangle shoved in the middle
# https://github.com/godotengine/godot-proposals/issues/3495#issuecomment-960461612
func generate_capsule_polygon(radius: float, num_sides_for_ends: int, height: float) -> PackedVector2Array:
	var polygon: PackedVector2Array
	
	var i_divisor: = float(num_sides_for_ends - 1)
	
#	https://www.mathsisfun.com/polar-cartesian-coordinates.html
	
	for i in num_sides_for_ends:
		polygon.append(polar2cartesian(radius, (float(i) / i_divisor) * PI) + Vector2(0, height / 2))
	for i in num_sides_for_ends:
		polygon.append(-polar2cartesian(radius, (float(i) / i_divisor) * PI) + Vector2(0, -height / 2))
	
	return polygon


# https://stackoverflow.com/questions/76698768/how-to-use-polygon2d-node-in-godot-to-create-a-regular-polygon
# https://www.mathsisfun.com/polar-cartesian-coordinates.html
func polar2cartesian(r, theta):
	var x = r * cos(theta)
	var y = r * sin(theta)
	return Vector2(x, y)

# Go back to level_select screen
func _on_home_button_up():
	get_tree().change_scene_to_file("res://level_selector.tscn" )


func _on_btn_level_select_button_up():
	_on_home_button_up()
