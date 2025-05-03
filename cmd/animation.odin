package main

import types "../types"
import "core:fmt"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"


update_animation :: proc(anim: ^types.Animation) {
	anim.frame_timer += rl.GetFrameTime()
	if anim.frame_timer > anim.frame_length {
		anim.current_frame += 1
		anim.frame_timer = 0

		if anim.current_frame == len(anim.frames) {
			anim.current_frame = 0
		}
	}
}

draw_animation :: proc(anim: types.Animation, pos: rl.Vector2, flip: bool) {
	for frame, i in anim.frames {
		source := rl.Rectangle {
			x      = f32(anim.current_frame) * frame.width,
			y      = 0,
			width  = frame.width,
			height = frame.height,
		}

		if flip {
			source.width = -source.width
		}

		dest := rl.Rectangle {
			x      = pos.x,
			y      = pos.y,
			width  = frame.width,
			height = frame.height,
		}

		rl.DrawTexturePro(anim.texture, source, dest, {dest.width / 2, dest.height}, 0, rl.WHITE)
	}
}

get_tile_row_range :: proc(
	sprite: rl.Texture2D,
	index_str: string,
	grid_size: rl.Vector2,
) -> [dynamic]rl.Rectangle {
	tile_w := grid_size.x
	tile_h := grid_size.y

	columns := sprite.width / i32(tile_w)
	rows := sprite.height / i32(tile_h)

	parts := strings.split(index_str, "-")
	if len(parts) != 2 {
		fmt.println("Invalid format: expected \"row-endcol\"")
		return nil
	}

	row := strconv.atoi(parts[0]) - 1
	end_col := strconv.atoi(parts[1]) - 1

	if row < 0 || end_col < 0 || i32(row) >= rows || i32(end_col) >= columns {
		fmt.println("Tile index out of bounds")
		return nil
	}

	rects := make([dynamic]rl.Rectangle, 0, end_col + 1)

	for x in 0 ..= row {
		for y in 0 ..= end_col {
			rect := rl.Rectangle {
				x      = tile_w * f32(x),
				y      = tile_h * f32(y),
				width  = tile_w,
				height = tile_h,
			}
			append(&rects, rect)
		}
	}

	return rects
}
