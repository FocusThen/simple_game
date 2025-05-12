package main


import "core:fmt"
import "core:mem"
import rl "vendor:raylib"

PixelWindowHeight :: 180


PLAYER_WIDTH :: 32
PLAYER_HEIGHT :: 32

player_pos: rl.Vector2
player_vel: rl.Vector2
player_grounded: bool
player_flip: bool
player_sprite: rl.Texture2D
player_moving: bool

player_frames :: struct {
	idle:  [4]rl.Vector2,
	run:   [6]rl.Vector2,
	roll:  [8]rl.Vector2,
	hit:   [4]rl.Vector2,
	death: [4]rl.Vector2,
}


platform_collider :: proc(pos: rl.Vector2) -> rl.Rectangle {
	return {pos.x, pos.y, 96, 16}
}

main :: proc() {
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	context.allocator = mem.tracking_allocator(&track)

	// memory check
	defer {
		for _, entry in track.allocation_map {
			fmt.eprintf("%v leaked %v bytes\n", entry.location, entry.size)
		}

		for entry in track.bad_free_array {
			fmt.eprintf("%v bad free\n", entry.location)
		}
		mem.tracking_allocator_destroy(&track)
	}
	// end memory

	// GAME
	rl.InitWindow(1280, 720, "Simple Game")
	rl.SetTargetFPS(500)

	player_sprite = rl.LoadTexture("./assets/sprites/knight.png")

	player_frames := player_frames {
		idle = [4]rl.Vector2 {
			rl.Vector2{0, 0},
			rl.Vector2{PLAYER_WIDTH, 0},
			rl.Vector2{PLAYER_WIDTH * 2, 0},
			rl.Vector2{PLAYER_WIDTH * 3, 0},
		},
		run  = [6]rl.Vector2 {
			rl.Vector2{0, PLAYER_HEIGHT * 2},
			rl.Vector2{PLAYER_WIDTH, PLAYER_HEIGHT * 2},
			rl.Vector2{PLAYER_WIDTH * 2, PLAYER_HEIGHT * 2},
			rl.Vector2{PLAYER_WIDTH * 3, PLAYER_HEIGHT * 2},
			rl.Vector2{PLAYER_WIDTH * 4, PLAYER_HEIGHT * 2},
			rl.Vector2{PLAYER_WIDTH * 5, PLAYER_HEIGHT * 2},
		},
	}


	platform := rl.Vector2{-50, 80}

	player_source := rl.Rectangle {
		x      = player_frames.idle[0].x,
		y      = player_frames.idle[0].y,
		width  = PLAYER_WIDTH,
		height = PLAYER_HEIGHT,
	}

	frame_timer: f32
	player_current_frame: int
	for !rl.WindowShouldClose() {
		// player update
		frame_timer += rl.GetFrameTime() * 30


		if rl.IsKeyDown(.A) {
			player_vel.x = -100
			player_moving = true
			player_source.x = player_frames.run[player_current_frame].x
			player_source.y = player_frames.run[player_current_frame].y
      player_source.width = -player_source.width
		} else if rl.IsKeyDown(.D) {
			player_vel.x = 100
			player_moving = true
			player_source.x = player_frames.run[player_current_frame].x
			player_source.y = player_frames.run[player_current_frame].y
		} else {
			player_source.x = player_frames.idle[player_current_frame].x
			player_source.y = player_frames.idle[player_current_frame].y
			player_vel.x = 0
			player_moving = false
		}


		if (player_moving) {
			if (frame_timer > len(player_frames.run)) {
				player_current_frame += 1
				frame_timer = 0

				if (player_current_frame == len(player_frames.idle)) {
					player_current_frame = 0
				}
			}
		} else {
			if (frame_timer > len(player_frames.idle)) {
				player_current_frame += 1
				frame_timer = 0

				if (player_current_frame == len(player_frames.idle)) {
					player_current_frame = 0
				}
			}
		}


		player_dest := rl.Rectangle {
			x      = player_pos.x,
			y      = player_pos.y,
			width  = PLAYER_WIDTH,
			height = PLAYER_HEIGHT,
		}

		// gravity
		player_vel.y += 1000 * rl.GetFrameTime()

		if player_grounded && rl.IsKeyPressed(.SPACE) {
			player_vel.y = -300
		}

		player_pos += player_vel * rl.GetFrameTime()

		player_grounded = false

		player_feet_collider := rl.Rectangle{player_pos.x - 4, player_pos.y - 4, 8, 4}

		// player stand
		if rl.CheckCollisionRecs(player_feet_collider, platform_collider(platform)) &&
		   player_vel.y > 0 {
			player_vel.y = 0
			player_pos.y = platform.y
			player_grounded = true
		}

		screen_height := f32(rl.GetScreenHeight())
		screen_width := f32(rl.GetScreenWidth())

		camera := rl.Camera2D {
			zoom   = screen_height / PixelWindowHeight,
			offset = {screen_width / 2, screen_height / 2},
			//target = player_pos,
		}


		rl.BeginDrawing()
		rl.ClearBackground(rl.BLUE)

		rl.BeginMode2D(camera)
		// Draw Player
		rl.DrawTexturePro(
			player_sprite,
			player_source,
			player_dest,
			{player_dest.width / 2, player_dest.height - 4},
			0,
			rl.WHITE,
		)

		// rl.DrawRectangleRec(player_feet_collider, rl.RED)
		rl.DrawRectangleRec(platform_collider(platform), rl.WHITE)
		rl.EndMode2D()
		rl.EndDrawing()

		free_all(context.temp_allocator)
	}

	defer rl.CloseWindow()
	defer free_all(context.temp_allocator)
}
