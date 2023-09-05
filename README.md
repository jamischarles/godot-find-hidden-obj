# Godot - Hidden Objects iOS App project...

## Current UI
![Screenshot of app](./screenshot.png?raw=true "Title")

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
