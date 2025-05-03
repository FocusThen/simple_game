package main


import "core:fmt"
import "core:mem"
import rl "vendor:raylib"

PixelWindowHeight :: 500


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


	knight_sprite := rl.LoadTexture("./assets/sprites/knight.png")

	player_init() // Player Init

	platform := rl.Vector2{-50, 80}

	for !rl.WindowShouldClose() {
		// player update
		player_update()

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
		//draw_animation(player_current_anim, player_pos, player_flip)


		rl.DrawTexture(knight_sprite, 0, 0, rl.WHITE)
		knight_sprite_x_calc := knight_sprite.width / 32
		knight_sprite_y_calc := knight_sprite.height / 32

		for i in 0 ..< knight_sprite_x_calc {
			for j in 0 ..< knight_sprite_y_calc {
				rl.DrawRectangle(i32(i * 32), i32(j * 32), 30, 30,rl.WHITE)
			}
		}


		rl.DrawRectangleRec(platform_collider(platform), rl.WHITE)
		rl.EndMode2D()
		rl.EndDrawing()

		free_all(context.temp_allocator)
	}

	rl.CloseWindow()

	free_all(context.temp_allocator)
}
