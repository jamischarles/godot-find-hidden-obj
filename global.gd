extends Node

#https://ask.godotengine.org/1883/transfering-a-variable-over-to-another-scene

# used for truly GLOBAL state.
# We autoload this (see project settings) so we can ref this from any script

## TODO: We should make a LevelSwitcher class that's global and keep track of this routing type logic

# not set
var next_level: String
# TODO: Calc max levels automagically?
var highest_level = "02"

func set_next_level_str(currentLevelStr: String):
	var newLevelInt = int(currentLevelStr) + 1
	next_level = "0" + str(newLevelInt)
	return next_level
	
func change_scene(destination: String):	
	var target: String
	match destination:
		"home":
			target = "main.tscn"
		_:
			# default fallthrough
			# assume "01" numbers are being passed
			target = "%s/stage.tscn" % destination
			
			# update the new "next_level"
			# Q: How do we max out at the top end?
			# TODO: Test that ^
			# If there are levels left to go, then let's set that as next
			if destination != highest_level:
				set_next_level_str(destination)
			
	
	get_tree().change_scene_to_file("res://" + target)
	
func send_to_next_level():
	change_scene(next_level)
	

## FIXME: where should we distinguish between left padded string nums and not?
