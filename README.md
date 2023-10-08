# Godot - Hidden Objects iOS App project...

## Current UI
![Screenshot of app](./screenshot.png?raw=true "Title")


## Adding Level (with new canvas image)
1. Add new image to 00_canvas_images
2. Name it with 2 digit number for level it's for
3. Open 00_tools/create_shape_data.tscn
4. For TextureRect node, create atlas texture for new image, loaded from 00_canvas_images/ folder
	- set region to exclude the legend & solution
5. For TextureRect with legend mode do same as 4 (or clone and make texture UNIQUE (parent only))
	- set region to entire image
6. Select root node in tree for create_shape_data.tscn
	- delete all the children of `click_zone_container` node
	
For each shape... ------------------>	
7. In right rail props click "Add Clickzone" (this will add a new node and switch focus to it)
8. Zoom into a shape, and click to add all the polygons for it. Then close it at the end.
9. Delete children of button_image_container node
10. Add a new reference_rect node as child of "button_image_container"
	- Size and move the new rect node to cover the corresponding legend image the clickzone shape was just added for
11. Name the clickZone and button_image	node to match (and describes object)
------------

12. When done, enter "selected folder" (2 digit format) like "02" in right rail
13. Click "Save Shapes" in right rail
This will create "02/src/img.png" and "02/src/shape_data.dat"

14. Open `create_level.gd`. Enter in code the folder to process (02 here)
15. File RUN from that file.
This generates the tscn file which we can use to run the level.
16. Open that new scene
17. Try it out (cmd+r) run current scene.
Verify it all works



## Modify existing shapes on a pre-existing level

## Re-generate level with new styles

## After adding new image to a numbered folder...
* Scene -> Create inherited scene
* Right click -> editable children  
Now you can make just the changes you need and those are saved locally.
Godot is AMAZING!

## Process for adding a new image...
1. duplicate the numbered folder. Increment number
2. Replace img.png with the new image. Ensure you are using an atlasImage if you don't want to use the whole image. Then select the region you want.
in Godot->stage.tscn...
3. On `hidden_objects_image` node replace texture with new image
4. On `Canvas_with_clickzones` node set `layout->custom_min_size` to dimensions of new image (see 3. ^) 


Add button images by...
On `right_rail->legend_for_hidden_objects`...
5. Change the region / texture image for each button ("make unique")
 

Add click zones on canvas by...
6. name the shape (needs to match shape name in right rail)
7. move it
8. Resize it properly


TODO: add assertions 

TODO: next: fill in the right rail legend (and document the steps...)
