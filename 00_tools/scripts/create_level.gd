@tool
extends EditorScript

## HOW to use this...
## CURRENTLY ACTIVE SCENE (we need a more intuitive way to select this)...
## whichever scene is selected in `scene` (via selection in the filesystem) 
## is the current scene (even local_scene) from resource loader...
## maybe we instantiate it otherwise...?


#@export_file var destination_folder 
@export_dir() var destination_folder: String = "test"


# constants to change before running the script

@export var test = "hi"

@export var resource: Resource
@export var node: Node
# needed to update the props

var INPUT_FOLDER = "02"

# Used to (re-)generate a level

## INPUT
## src/
## - Image
## - Array of regions for the buttons (legend of objects to find)
## - Array of polygons for the click targets

## Output
## Scene tree for that image with click zones and right rail buttons. 
## All based on the template stage.gd file



		
		
		

# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var srcDir = DirAccess.open("res://%s/src" % INPUT_FOLDER)
	var destDir = DirAccess.open("res://%s" % INPUT_FOLDER)
	print('srcdir', srcDir.get_files())
	
	
#	var file = FileAccess.open("res://shared/stage.gd", FileAccess.WRITE)
	var templateDir = DirAccess.open("res://shared")
	print(templateDir.get_files())
	
	# clean up dest folder
#	for file in destDir.get_files():
#		print("deleting file:", file)
#		destDir.remove(file)

	
	# just needs to be a dir handle. Doesn't matter which folder it's in really
	# todo: Can we read that tree and just copy those nodes over?
#	destDir.copy("res://shared/stage_global.tscn", "res://%s/stage.tscn" % INPUT_FOLDER)
	
	# load data file with shape data
	# Creates the helper class to interact with JSON
	var json = JSON.new()
# https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html
	var shape_raw_data = FileAccess.open("%s/src/shape_data" % INPUT_FOLDER, FileAccess.READ)
#	var json_string = shape_raw_data.get_file_as_string("%s/src/shape_data.json" % INPUT_FOLDER)
	# Check if there is any error while parsing the JSON string, skip in case of failure
#	var parse_result = json.parse(json_string)
#	if not parse_result == OK:
#		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
##		continue


	print("##raw", shape_raw_data)
	# does this modify the file data?!? Seems to... hm...
	var shape_data =  shape_raw_data.get_var(true)



	# Get the data from the JSON object
#	var shape_data = json.get_data()
#	print('##shape_data', shape_data)
	
	
	
#	var clickzoneShapes: PackedDataContainerRef = shape_data["clickZones"] 
	
#	for dict in clickzoneShapes:
#		print("dict", dict["position"])
#	print("##flatten", flattenArray(clickzoneShapes))

	
#	print('##shape_data', shape_data)
#	for key in shape_data:
#		prints(key, shape_data[key])

	
	# create a copy of the template scene tree so we can modify it
	var scene = ResourceLoader.load("res://shared/stage_global.tscn").instantiate()
	var imgNode: TextureRect = scene.get_node("HBoxContainer/ScrollContainer/HBoxContainer/CanvasContainer/hidden_objects_image")
	var canvasContainer: Control = imgNode.get_parent()
	var clickZoneContainer: Control = scene.get_node("HBoxContainer/ScrollContainer/HBoxContainer/CanvasContainer/click_zone_container")
	var rightRailButtonContainer: VBoxContainer = scene.get_node("HBoxContainer/right_rail/legend_for_hidden_objects")

	
	# change image
	var atlasTexture = AtlasTexture.new()
	atlasTexture.atlas = load("res://%s/src/img.png" % INPUT_FOLDER)
	# set atlas region to entire image (for now)
#	atlasTexture.region = Rect2(0, 0, atlasTexture.atlas.get_width(), atlasTexture.atlas.get_height())
	atlasTexture.region = shape_data["imageData"].region
	
	
#	imgNode.texture.atlas.resource_path = "%s/src/img.png" % INPUT_FOLDER
	imgNode.texture = atlasTexture
	
	# get the size of the imgNode container from the region
	canvasContainer.custom_minimum_size = atlasTexture.region.size
	imgNode.size = atlasTexture.region.size
	

	
	print("###size", atlasTexture.region.size)
	print("###imgNode.size", imgNode.size)
	
	
	
	## Create the clickzone shapes
	## Q: Create instance from scene type, or clone other clickzone?
	
	
	var clickZoneTemplate: Area2D = clickZoneContainer.get_child(0).duplicate()
	## Remove all existing clickzones
	for clickZone in clickZoneContainer.get_children():
		clickZoneContainer.remove_child(clickZone)
		clickZone.queue_free() # manually delete
		
		
	## Remove existing RR buttons
	for btn in rightRailButtonContainer.get_children():
		rightRailButtonContainer.remove_child(btn)	
		btn.queue_free() # manually delete
		
	
	print('###clickZoneTemplate', clickZoneTemplate)


	# Firstly, we need to create the object and add it to the tree and set its position.
#	var new_object = load(shape_data["filename"]).instantiate()
#	get_node(node_data["parent"]).add_child(new_object)
#	new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
	
	
		
		
	
	for clickZone in shape_data["clickZones"]:
		# maybe create area2d with polygon shape?
#		var poly = clickZoneTemplate.duplicate()
		var area = Area2D.new()
		var poly = Polygon2D.new()
		var collisionPoly = CollisionPolygon2D.new()
		
		
		area.name = clickZone.name
#		area.position = Vector2(clickZone["pos_x"],clickZone["pos_y"]) # this approach was buggy
		
		area.add_child(poly)
		area.add_child(collisionPoly)
		clickZoneContainer.add_child(area)
		
		area.position = Vector2i(clickZone["pos_x"],clickZone["pos_y"])
		
		
		
		
		print('##clickZone', clickZone)
		
		# TODO: Fix this up... todo: try the node SAVE method?
		print("##clickZoneFromFile", clickZone)
		
		# polygon coords are relative to the center position
		poly.polygon = clickZone.polygon
#		poly.position = Vector2(clickZone["pos_x"],clickZone["pos_y"])
		
		# create collisionshape with same polygon
		collisionPoly.polygon = poly.polygon
#		collisionPoly.position = poly.position
		
		
#		poly.set_position(load(clickZone["position"]))

#		poly.position = Vector2(json.parse_string(clickZone["position"]))

		# persist to tree
		poly.set_owner(scene)
		collisionPoly.set_owner(scene)
		area.set_owner(scene)

		print('##', poly)

#		poly.position = Vector2(clickZone.position)


#	var btnGroup = ButtonGroup.new()
	## 
	for buttonRegionRect in shape_data["buttonRegions"]:
		# button icon from legend on canvas image
		var btnAtlasTexture = AtlasTexture.new()
		btnAtlasTexture.atlas = load("res://%s/src/img.png" % INPUT_FOLDER)
		# set atlas region to entire image (for now)


#		print("##", buttonRegionRect)
#		btnAtlasTexture.region = Rect2(0, 0, btnAtlasTexture.atlas.get_width(), btnAtlasTexture.atlas.get_height())
		btnAtlasTexture.region = buttonRegionRect.rect
	#	imgNode.texture.atlas.resource_path = "%s/src/img.png" % INPUT_FOLDER
#		imgNode.texture = atlasTexture
		
#		print("###buttonRegionRect", buttonRegionRect)		
		var btn = Button.new()
		rightRailButtonContainer.add_child(btn)
		btn.set_owner(scene)
		
		# need to set these AFTER node is added to scene
		btn.set("expand_icon", true)
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
		btn.custom_minimum_size = Vector2(100, 200)
		
		# add all to same button because script needs it


		# not needed if we don't want to click them anymore
		btn.focus_mode = Control.FOCUS_NONE
#		btn.button_group = btnGroup
#		btn.toggle_mode = true
		
		btn.theme = load("res://shared/right_rail_button.tres")
		# shader to make white pixels transparent
#		var shaderMaterial = ShaderMaterial.new()
#		shaderMaterial.shader = load("res://shared/right_rail_buttons.gdshader")
#		btn.material = shaderMaterial

		
		

		
#		btn.set_icon(btnAtlasTexture)
		btn.icon = btnAtlasTexture
		btn.flat = true #makes bg white
		print('###buttonRegionRect: ', buttonRegionRect.name)
		btn.name = buttonRegionRect.name # bring over the node name (obj name)
#		btn.disabled = true

#		btn.text = "TEST UBTTON"
		


#	print("children:", clickZoneContainer.get_children())
		
		
		
#		print("###clickZoneShape", clickZoneShape)
#		for el in clickZoneShape:
#			print("###clickZoneShape-el", el)
#			for elsub in el:
#				print("###clickZoneShape-el-el", elsub)
			
			
	# todo: make flatten algo
	
	
	# SAVE new tree as scene
	var scene_new = PackedScene.new()
	scene_new.pack(scene)
	ResourceSaver.save(scene_new, "res://%s/stage.tscn" % INPUT_FOLDER)
	
	
	# FIXME: or we can just load that and INSTANTIATE it... 
	# That way we have a new tree we can modify then save...
	
#	var dir = Directory.new()
#	dir.copy("res://files/sprite_image.tex", "res://sprite_image.tex")
	
	
#	notify_property_list_changed()

	# this is DANGEROUS. As it's the scene that's currently selected in the editor

#	var scene = load("res://00/stage.tscn")
	
	
	# this broke the editor. Don't want to do that lol.
#	get_scene().get_tree().change_scene_to_file("res://%s/stage.tscn" % INPUT_FOLDER)
	
	
#	var frog1 = ResourceLoader.load("res://shared/stage_global.tscn");

	# gets the root node
	
	# seems to work better, but isn't saved back to file...
	# can we save this back to file?
	# creates a new instance. We then modify it and save it
	
#	var frog0 = ResourceLoader.load("res://00/stage.tscn").instantiate()
#
#	var frog1 = ResourceLoader.load("res://00/stage.tscn").get_local_scene();
#
#	print('frog0', frog0)
#
##	var scene = get_scene()		
##	print("scene: ", scene)
##	print("scene: ", scene.get_children())
#
#	print('frog1', frog1)
##	print('frog', frog1.get_local_scene())
#	var testNode = Node2D.new()
##	testNode.set_name('testNode')
#	frog0.add_child(testNode)
#	testNode.set_owner(frog0)
#
#	print('##', frog0.get_children())
#
	# save this new node tree as a scene. THIS WORKS!!!!!
	# This is us generating a new scene, then saving it to disk as a resource!!
#	var scene_new = PackedScene.new()

#	scene_new.pack(frog0)

	
#	ResourceSaver.save(scene_new, "res://00/stage_new.tscn")
	
	
	# delete all children (cleanup)
#	for child in scene.get_children():
#		child.get_parent().remove_child(child)
		

	# add new child node...
#	var testNode = Node2D.new()
#	testNode.set_name('testNode')
#
#	scene.add_child(testNode)
#	testNode.set_owner(scene)
#	print('WORKS!')
#	print_debug("funs", self.destination_folder)
	
