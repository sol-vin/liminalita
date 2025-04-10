extends StaticBody3D

var is_on_screen = false
var is_nearby = false
var next_state = false

func on_screen():
	is_on_screen = true

func off_screen():
	is_on_screen = false

func nearby():
	is_nearby = true

func far_away():
	is_nearby = false

func _process(delta: float) -> void:
	if is_on_screen and is_nearby:
		next_state = true
	
	if $State and next_state and !is_on_screen and !is_nearby:
		next_state = false
		next()

func next():
	$State["parameters/playback"].next()

func change_to_one():
	$"1".show()
	$"2".hide()
	$"3".hide()
	$"4".hide()
	
func change_to_two():
	$"2".show()
	$"1".hide()
	$"3".hide()
	$"4".hide()

func change_to_three():
	$"3".show()
	$"2".hide()
	$"1".hide()
	$"4".hide()

func change_to_four():
	$State.queue_free()
	$"4".show()
	$"2".hide()
	$"3".hide()
	$"1".hide()
