extends Node2D

# Draws the virtual sticks of the controls autoload.

const color_base = Color(1, 1, 1, 0.15)
const color_knob = Color(1, 1, 1, 0.4)

func _draw():
	var pads = get_parent()
	for pad in range(pads.PAD_COUNT):
		if pads.pad_active[pad]:
			var start = pads.pad_start[pad]
			var offset = pads.pad_pos[pad] - start
			if offset.length() > pads.STICK_RADIUS:
				offset = offset.normalized() * pads.STICK_RADIUS
			draw_circle(start, pads.STICK_RADIUS, color_base)
			draw_circle(start + offset, pads.STICK_RADIUS / 2, color_knob)
