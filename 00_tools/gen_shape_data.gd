@tool # only runs when we have the associated node selected _click_zones
extends Control
# hacky way to shortcut creating a plugin w/o creating a proper plugin 
# need to make a proper plugin for this?
#extends EditorPlugin



# use poly POSITION as center point
# use polygon for shaping
# save to disk


# 1. Add on-screen buttons (in a panel?)
# 2. CREATE clickzone
# 3. Renders it on screen via right rail...
# 4. Adds it to the array? (do we need to export it?)
# Q: Can we have the code update the right rail thing?
# 5. Renders it on the page and then we can control it.
# 6. Manipulating it updates the array
# Maybe we try to do it w/o exported thing first. THEN we add a "SAVE" button...
# how do we name each shape?
# we can manually name the node... Yes.

#@export var image_regions: Array Rect2
#@export(Array, Rect2) var image_regions

#export(Array, AtlasTexture) var textures




## add a button to add another item
# TODO: 
# add a new poly with a basic shape (square?)
# then we can move it around etc...
# Clicking save would serialize and save to a resource with simple objects (class needed?)

## test comment
@export var add_clickzone = false :
	get:
		return add_clickzone
	set(value):
		add_clickzone_handler()
		add_clickzone = false

@export_category("Adjust position for all click_zones") #######################		

## test 
@export var move_all_zones_offset = Vector2(0,0) 

## Clickzone we want to move the position of
#@export var selected_clickzone: Polygon2D

## on enter make the movement. Or just convert this to the movement with another button?
## ACTION: Moves polygon from current position to New Position ^ 
## and sets the each polygon point relative to the new center point based on new position
@export var move_all_clickzones = false :
	get:
		return load_shapes
	set(value):
		# adjust all shapes by 
		for zone in get_node("click_zone_container").get_children():
			# REQUIRES that polygons be centered first (via "auto_move_to_center")
			zone.position += move_all_zones_offset 
		move_all_clickzones = false

# TODO: make this happen automagically during export. See if the shape is off, then move it 
## Automagically detect centroid of the shape, and move the polygon position there
## then move all the polygons so they are relative to that 0,0 center
@export var auto_move_to_center  = false :
	get:
		return auto_move_to_center
	set(value):
#		find_center_of_shape()
		auto_move_to_center = false
		
		## for now just loop and fix ALL the clickzone center points
		for zone in get_node("click_zone_container").get_children():
			auto_calc_shape_center_and_move_shape_there(zone)
		


		
@export_category("Load & Save") #########################
## To LOAD shapes from and SAVE shapes and image to
@export var selected_folder: String
## LOADS new shapes from selected_folder
@export var load_shapes = false :
	get:
		return load_shapes
	set(value):
		load_shapes_handler()
		load_shapes = false		
		
## SAVES shapes to selected_folder
@export var save_shapes = false :
	get:
		return save_shapes
	set(value):
		save_shapes_handler()
		save_shapes = false



# hacky way to shortcut creating a plugin w/o creating a proper plugin 
# need to make a proper plugin for this?
#extends EditorPlugin



# use poly POSITION as center point
# use polygon for shaping
# save to disk


# 1. Add on-screen buttons (in a panel?)
# 2. CREATE clickzone
# 3. Renders it on screen via right rail...
# 4. Adds it to the array? (do we need to export it?)
# Q: Can we have the code update the right rail thing?
# 5. Renders it on the page and then we can control it.
# 6. Manipulating it updates the array
# Maybe we try to do it w/o exported thing first. THEN we add a "SAVE" button...
# how do we name each shape?
# we can manually name the node... Yes.

#@export var image_regions: Array Rect2
#@export(Array, Rect2) var image_regions

#export(Array, AtlasTexture) var textures




## add a button to add another item
# TODO: 
# add a new poly with a basic shape (square?)
# then we can move it around etc...
# Clicking save would serialize and save to a resource with simple objects (class needed?)






# global nodes
@onready var image = $TextureRect
@onready var clickZones: Array[Node] = $click_zone_container.get_children()
@onready var buttonImageRegions: Array[Node] = $button_image_container.get_children()
	


# Q: Do we set a dirty flag here?
# CollisionObject2D requires a shape attached to it...
# Polygon2D??





# Called when the node enters the scene tree for the first time.
func _ready():

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

	# do we need to make this @tool?
	# render all the regions on the canvas

# add new polygon on canvas
## TODO: Turn this into a plugin?!?
func add_clickzone_handler():
	var poly = Polygon2D.new()
	# turn transparency down
	poly.color.a = .5
	$click_zone_container.add_child(poly)
	
	poly.set_name("new_poly")
	
	var polygon: PackedVector2Array
	
	
#	var radius = 5
#	var height = 300
#	var polygon = generate_capsule_polygon(radius, 40, height)
	
	poly.set_polygon(polygon)
	
	# set this scene root as owner so it'll persist the creation of the node
	poly.set_owner(get_tree().edited_scene_root)
	
	
#	if(self in EditorPlugin.new()):
		# set focus to new node
		
	# TODO: Needs to be a proper plugin to be able to modify the selected node
#	var editor = get_editor_interface()
#	editor.edit_node(poly)
#	var editor = EditorInterface
#	var sec = editor.get_editor_interface()
	
#	print("##editor", sec)
		# TODO: Add a check here
#	EditorPlugin.new().get_editor_interface().set_selection(poly)
#	self.get_editor_interface().get_selection()

#	var editor = EditorPlugin.get_editor_interface()
	
	
	var editor = EditorPlugin.new().get_editor_interface()
	print("##", editor)
##	editor.edit_node(poly)
##	editor.add_node(poly)
#
#	# change the scene tree selection to new node created
	var sel = editor.get_selection()
	sel.clear()
	sel.add_node(poly)
#
##	EditorInterface.
#	print("ADD CLICKZONE")
	
# allows us to load (READ) (and save) shapes from a target folder...	
# input/output folder should be the same
# but we can say "LOAD" and "SAVE" separately
func load_shapes_handler():
	# load the data file
	# load the image
	
	
	
#	var loaded_data = load("res://02/src/shape_data")
	var loaded_data_raw = FileAccess.open("%s/src/shape_data.txt" % selected_folder, FileAccess.READ)
	var loaded_data = str_to_var(loaded_data_raw.get_as_text()) # deserialize back into the data structure
	
	# EXPECT this to ref the 00_canvas_images location (backups for all images)
	var loaded_image = load(loaded_data["imageData"].src)
	
	
	# set up 2 images (1 full, 1 with legend hidden)
	var atlasTexture = AtlasTexture.new()
	atlasTexture.atlas = loaded_image
	# set atlas region to entire image (for now)
#	atlasTexture.region = Rect2(0, 0, atlasTexture.atlas.get_width(), atlasTexture.atlas.get_height())
	atlasTexture.region = loaded_data["imageData"].region
	
	# assign new image to the 2 image nodes
	$TextureRect.texture = atlasTexture
	
	var w = loaded_data["imageData"].size.x
	var h = loaded_data["imageData"].size.y
	$TextureRect_w_legend.texture = atlasTexture.duplicate()
	$TextureRect_w_legend.texture.set_region(Rect2(0,0, w, h)) # full height of img

	
	
	
	# remove all existing clickzones
	for zone in $click_zone_container.get_children():
		$click_zone_container.remove_child(zone)
	
	# create clickzones from stored data
	for zoneData in loaded_data["clickZones"]:
		var poly = Polygon2D.new()
		# attach to tree
		$click_zone_container.add_child(poly)
		
		poly.name = zoneData.name
		poly.position = Vector2(zoneData["pos_x"], zoneData["pos_y"])
		poly.polygon = zoneData["polygon"]
		# turn transparency down
		poly.color.a = .5
		
		
		# persist
		poly.set_owner(get_tree().edited_scene_root)
		
		
	# remove existing button_image rects
	for rect in $button_image_container.get_children():
		$button_image_container.remove_child(rect)	
		
	# create button_image reference rects from stored data
	for loaded_region in loaded_data["buttonRegions"]:
		var region = ReferenceRect.new()
		$button_image_container.add_child(region)
		
		region.name = loaded_region.name
		
		# we can't SET rect (only get it) so we set it like so
		region.set_position(loaded_region.rect.position)
		region.set_size(loaded_region.rect.size)
		
		# persist new nodes in tree
		region.set_owner(get_tree().edited_scene_root)
		
		
	
#	print('loaded_data1', loaded_image)
#	print('loaded_data2', loaded_data)
#	print('loaded_data3', loaded_data.get_var())
	
	# deserialize the data from the file and load it into the scene tree
	# 1) Reproduce the (named) button images (with correct atlas ref)
	# 2) Reproduce the (named) polygons
	
	
	
	
	

	
# WRITES shapes to disc in the target folder	
# TODO: Extract all the serialize -> deserialize logic?
func save_shapes_handler():
	print("SAVE TO DISK")
	
	
	# Assert that it's safe to export
	run_assertions_on_tree()
	
	# gather the data we want to save
	# create data structure
	# save it
	
	
	print("###buttonImageRegions", buttonImageRegions)
	

	
#	var data = { "key": "value", "another_key": 123, "lock": Vector2() }
	
	var data = {"imageData": {}, "clickZones": [], "buttonRegions": []}
	
#	print('data', data)
	var img_path = $TextureRect.texture.atlas.resource_path
	
	# capture image rect data
	data["imageData"] = {
		"src": img_path,
		"size": image.size, # total image size (no region restrictions)
		"region": image.texture.region # region of image minus legend
	}
	
	
	# capture clickzone shapes
	for zone in $click_zone_container.get_children():
		data["clickZones"].append({
			# Vector2 is not supported by JSON
			"name": zone.name,
			"pos_x" : zone.position.x, 
			"pos_y" : zone.position.y,
			"polygon": zone.get_polygon()
		})
		
		
		
	## capture button_image rects for subregions
	for region in $button_image_container.get_children():
		data["buttonRegions"].append({
			# Vector2 is not supported by JSON
			"name": region.name,
			"rect" : region.get_rect(), 
		})



#	buttonImageRegions
		
	## TODO: Do the same for subregions for button legend	
#	print('data2', data)
	
#	var packed = PackedDataContainer.new().pack(data)
	
	# prep the data
#	var json = JSON.new()
	# Check if there is any error while parsing the JSON string, skip in case of failure
#	var parse_result = json.parse(json_string)
#	var json_string = JSON.stringify(data)
	
	
	# WAYYY to hard to use. So using JSON for now.
	# Later use binary?
#	https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html
#	var packed = PackedDataContainer.new()
#	print('packed', packed)
#	packed.pack(data)
	
	
	# create folder if it doesn't exist yet
	DirAccess.make_dir_recursive_absolute("res://%s/src/" % selected_folder)
	
	# save data file with shapes
#	ResourceSaver.save(packed, "%s/src/shape_data.res" % dest_folder)
	var save_shapes = FileAccess.open("%s/src/shape_data.txt" % selected_folder, FileAccess.WRITE)
	
	# save as binary (non human readable, but preserves data stuctures)
#	save_shapes.store_var(data, true)
	
#	https://www.gdquest.com/tutorial/godot/best-practices/save-game-formats/
	# save human readable non-json format that prerves godot data types
	# TODO consider saving different props on dipp lines...
#	save_shapes.store_line(var_to_str(data))
	save_shapes.store_string(var_to_str(data))
	
	
#	save_shapes.store_line(var_to_str(data["clickZones"]))
	
	
	
#	save_shapes.store_pascal_string(data)
#	ResourceSaver.save(data, "%s/src/shape_data.res" % selected_folder)

	
	# save/copy image
#
	
#	DirAccess.copy

#	var dir = DirAccess.open(selected_folder + "/src")
#	var img_content = FileAccess.open(img_path, FileAccess.READ)
##	print('img', img_test)
#	var dest_file = FileAccess.open("res://%s/src/img.png" % dest_folder, FileAccess.WRITE)
#	dest_file.store_buffer(img_content)
#	dir.copy(img_path,"res://%s/src" % dest_folder);

	## TODO: Move to separate function
	print('image copy: ', img_path, " -> res://%s/src/img.png" % selected_folder) 
	var res = DirAccess.copy_absolute(img_path, "res://%s/src/img.png" % selected_folder)
	print('image copy status: ', res, img_path) # code 0 == SUCCESS!!!
#	var directory = Directory.new()
#	var dirErr = directory.open(basePath)
#	if dirErr != OK:
#		printerr("Couldn't open directory " + basePath)
#		return
	
	
###################### assertion code
# node name

var assert_verify_matches

## Runs the assertions on the tree before we export to ensure the nodes are properly set up and named
func run_assertions_on_tree():
	# wipe out assertion data structure
	assert_verify_matches = {}
	
	for zone in $click_zone_container.get_children():
		var name = zone.get_name()

		# add up the canvas clickzones
		if assert_verify_matches.has(name):
			assert_verify_matches[name] += 1
		else:
			assert_verify_matches[name] = 1
			
			
		#VERIFY: No clickZone positions should be OUTSIDE the canvas or on the edge...
		assert(zone.position.x > 0 && zone.position.y > 0, "ClickZones: %s has position at edge or off canvas. Please fix" % zone)

	# TODO: add assertion to ensures there's a matching pair for each one... (same shape and size)?
	# we can create a dictionary and count that each one has 2

#	print("i", i)
#	print('nodeNUm', clickZone.get_instance_id())

#


#	# count the right_rail button node names,
	var legendButtons = $button_image_container.get_children()
	for btn in legendButtons:
		var btn_name = btn.get_name()
		## TODO: Reuse this? in fn?
		if assert_verify_matches.has(btn_name):
			assert_verify_matches[btn_name] += 1
		else:
			assert_verify_matches[btn_name] = 1
	
	
	#VERIFY: there should be exactly one of each currently in the clickzones
	for zone in assert_verify_matches:
		assert(assert_verify_matches[zone] == 2, "ClickZones: %s has %s" % [zone, assert_verify_matches[zone]])
		
	
	
	
	
	
	
## Auto calc center, and move the polygons there
## Just fix all shapes for now...
func auto_calc_shape_center_and_move_shape_there(clickZoneShape):
	var centerOfShape = centroid_of_polygon(clickZoneShape.polygon)
#	print("###centroid", centerOfShape)
	
	## take center of shape (which is relative to polygon2d position, and
	## adjust so new position is (0,0) based
	## ie: Vector2(800,100) and (-500, 0) will result in
	## Vector2(300,100) (* -1 flips the sign so we don't get double negative = pos)
	var newPos = centerOfShape - clickZoneShape.position * -1
	
	# move position of shape to new center
	move_polygon_handler(clickZoneShape, newPos)
	
# FIXME: Consider getting the new_position automatically from shape_gravity or similar...
# then this could be, "set_polygons_relative_to_shape_gravity_center_point
# moves POSITION of area, and adjusts the polygon shape to balance that.
## @ shouldMoveShape - boolean. If set to true, it'll actually move the shape and not just center the position with the polygons
func move_polygon_handler(selected_zone: Polygon2D, new_pos:Vector2):

	# distance between old and new position and the distance we have to move each polygon
	var delta = new_pos - selected_zone.position
	print("delta to move: ", delta)
	
	# move the shape area to new position by delta
	selected_zone.set_position(new_pos)
	
	# move each polygon point in polygon shape to new delta relative to new area position
	for i in len(selected_zone.polygon): # move each point by delta
		selected_zone.polygon[i] -= delta
#		point = point + delta
	
	# assign modified clone of polygon to clickzone shape (because it was a copy)
#	selected_clickzone.set_polygon(poly)





# https://github.com/godotengine/godot/issues/58552#issuecomment-1053192791
func centroid_of_polygon(poly_array: PackedVector2Array):
	# stolen javascript solution from https://stackoverflow.com/a/43747218
	var first = poly_array[0]; var last = poly_array[len(poly_array) - 1]
	# original solution assumed first and last points are the same
	# Godot doesn't do that, at least in BitMap.opaque_to_polygons()
	if first != last:
		poly_array.append(first)
	# sum the area as we go
	var twice_area: float = 0.0
	# weighted sum of centroids of triangles; later divide by area
	var coord: Vector2
	var n_pts = len(poly_array)
	# used inside loop
	var p1: Vector2; var p2: Vector2; var j: float; var f: float
	# iterate over triangles: (0, 1, 2), (0, 2, 3), ... (0, n-2, n-1)
	# if one of the points is Point 0, resulting area/weight is 0 anyway
	for i in range(0, n_pts):
		j = posmod(i - 1, n_pts)
		p1 = poly_array[i]; p2 = poly_array[j]
		# the signed area of a triangle is the cross product of two of the sides divided by two
		f = (p1 - first).cross(p2 - first)
		twice_area += f
		# add contribution to weighted sum of centers;
		# p1 + p2 - 2 * first == (p1 - first) + (p2 - first)
		coord += (p1 + p2 - 2 * first) * f
	# multiply the total area by 3 (6 from actual area of polygon)
	# (even though I don't know why)
	f = twice_area * 3
	# finally, divide the weighted sum of the coordinates by that area
	var centroid = coord / f + first
	return centroid


	
## warn in the GUI tree when hidden shapes are mismatched or misnamed
#https://docs.godotengine.org/en/stable/tutorials/plugins/running_code_in_the_editor.html
# Only works when opening the scene?
#func _get_configuration_warnings():
#	var warnings = []
#
#	if title == "":
#		warnings.append("Please set `title` to a non-empty value.")
#
#	if description.length() >= 100:
#		warnings.append("`description` should be less than 100 characters long.")
#
#	# Returning an empty array means "no warning".
#	return warnings
	
	
#	ResourceSaver.save(packed, "%s/src/shape_data.res" % dest_folder)
	
#	var scene_new = PackedScene.new()

#	scene_new.pack(frog0)
#	ResourceSaver.save(scene_new, "res://00/stage_new.tscn")
	

## UTILS #########################################################	
## TODO: Make this a util we can include?!?

# interesting!!!
# @desc something
# TODO: add assertion for num_sides
# if num_sides is < 3 (triangle) then it won't show up. 4 is square. interesting...
# https://ask.godotengine.org/81776/how-to-shape-polygon2d-into-a-circle
#func generate_circle_polygon(radius: float, num_sides: int, pos: Vector2) -> PackedVector2Array:
#	var angle_delta: float = (PI * 2) / num_sides
#	var vector: Vector2 = Vector2(radius, 0)
#	var polygon: PackedVector2Array
#
#	for _i in num_sides:
#		polygon.append(vector + pos)
#		vector = vector.rotated(angle_delta)
#
#	return polygon
#
#
## Square...
#
## Capsule
## A capsule is a circle, cut in half, with a rectangle shoved in the middle
## https://github.com/godotengine/godot-proposals/issues/3495#issuecomment-960461612
#func generate_capsule_polygon(radius: float, num_sides_for_ends: int, height: float) -> PackedVector2Array:
#	var polygon: PackedVector2Array
#
#	var i_divisor: = float(num_sides_for_ends - 1)
#
##	https://www.mathsisfun.com/polar-cartesian-coordinates.html
#
#	for i in num_sides_for_ends:
#		polygon.append(polar2cartesian(radius, (float(i) / i_divisor) * PI) + Vector2(0, height / 2))
#	for i in num_sides_for_ends:
#		polygon.append(-polar2cartesian(radius, (float(i) / i_divisor) * PI) + Vector2(0, -height / 2))
#
#	return polygon
#
#
## https://stackoverflow.com/questions/76698768/how-to-use-polygon2d-node-in-godot-to-create-a-regular-polygon
## https://www.mathsisfun.com/polar-cartesian-coordinates.html
#func polar2cartesian(r, theta):
#	var x = r * cos(theta)
#	var y = r * sin(theta)
#	return Vector2(x, y)
#


###################### assertion code
# node name
#		var name = clickZone.get_name()
#
#		# add up the canvas clickzones
#		if assert_verify_matches.has(name):
#			assert_verify_matches[name] += 1
#		else:
#			assert_verify_matches[name] = 1
#
#		# TODO: add assertion to ensures there's a matching pair for each one... (same shape and size)?
#		# we can create a dictionary and count that each one has 2
#
#		print("i", i)
#		print('nodeNUm', clickZone.get_instance_id())

#
#RIFY: there should be exactly one of each currently in the clickzones
#	for zone in assert_verify_matches:
#		assert(assert_verify_matches[zone] == 1, "ClickZones: %s has %s" % [zone, assert_verify_matches[zone]])

#	# count the right_rail button node names,
#	var legendButtons = $HBoxContainer/right_rail/legend_for_hidden_objects.get_children()
#	for btn in legendButtons:
#		var btn_name = btn.get_name()
#		## TODO: Reuse this? in fn?
#		if assert_verify_matches.has(btn_name):
#			assert_verify_matches[btn_name] += 1
#		else:
#			assert_verify_matches[btn_name] = 1
#

# Verify that each collision shape has position of 0,0
		# we need to use parent for positioining so clickzones line up with visual part
#		assert( int(shape.position.x) == 0 && int(shape.position.y) == 0, "ERROR: Each child CollisionShape MUST be 0,0 to avoid clickZone drift: %s, shape name:%s" % [shape.position, clickZone.name]);

		# 2) verify each shape has a name
		# throw when shape_names aren't assigned for each click zone
		# https://ask.godotengine.org/54948/throw-exception-or-error
		# confusing because eval is opposite for err
#		var name = clickZone.shape_name
#		assert( name != "", "ERROR: You must give each clickZone a shape_name value.");
		
		
#		clickZone.shape_uid = i
		
		# listen to click for each click shape
#		clickZone.connect('click_shape_clicked', on_shape_clicked)
		
		# hide all the click zones so they are invisble

		# set alpha to 0 so click zones are invisible to user but still active
#		clickZone.set_modulate(Color(1, 1, 1, 0))
		




# UTILS ---------------


