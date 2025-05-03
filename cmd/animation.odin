package main

import types "../types"
import rl "vendor:raylib"


update_animation :: proc(anim: ^types.Animation) {
	anim.frame_timer += rl.GetFrameTime()
	if anim.frame_timer > anim.frame_length {
		anim.current_frame += 1
		anim.frame_timer = 0

		if anim.current_frame == anim.num_frames {
			anim.current_frame = 0
		}
	}
}

draw_animation :: proc(anim: types.Animation, pos: rl.Vector2, flip: bool) {
	anim_width := f32(anim.texture.width)
	anim_height := f32(anim.texture.height)

	source := rl.Rectangle {
		x      = f32(anim.current_frame) * anim_width / f32(anim.num_frames),
		y      = 0,
		width  = anim_width / f32(anim.num_frames),
		height = anim_height,
	}

	if flip {
		source.width = -source.width
	}

	dest := rl.Rectangle {
		x      = pos.x,
		y      = pos.y,
		width  = anim_width / f32(anim.num_frames),
		height = anim_height,
	}

	rl.DrawTexturePro(anim.texture, source, dest, {dest.width / 2, dest.height}, 0, rl.WHITE)
}


draw_player_animation :: proc(anim: types.Animation, pos: rl.Vector2, flip: bool) {
	anim_width := f32(32 * anim.num_frames)
	anim_height := f32(32)

	source := rl.Rectangle {
		x      = f32(anim.current_frame) * anim_width / f32(anim.num_frames),
		y      = 0,
		width  = anim_width / f32(anim.num_frames),
		height = anim_height,
	}

	if flip {
		source.width = -source.width
	}

	dest := rl.Rectangle {
		x      = pos.x,
		y      = pos.y,
		width  = anim_width / f32(anim.num_frames),
		height = anim_height,
	}

	rl.DrawTexturePro(anim.texture, source, dest, {dest.width / 2, dest.height}, 0, rl.WHITE)
}
