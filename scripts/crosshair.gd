extends TextureRect

func fade_out():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	
func fade_in():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
