package main


import "core:fmt"
import "core:mem"
import rl "vendor:raylib"

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

	rl.InitWindow(1280, 720, "Simple Game")
	player_pos := rl.Vector2{300, 300}
	player_vel: rl.Vector2
  player_grounded: bool

	for !rl.WindowShouldClose() {
		if rl.IsKeyDown(.A) {
			player_vel.x = -400
		} else if rl.IsKeyDown(.D) {
			player_vel.x = 400
		} else {
			player_vel.x = 0
		}

		// gravity
		player_vel.y += 2000 * rl.GetFrameTime()

		if player_grounded && rl.IsKeyPressed(.SPACE) {
			player_vel.y = -800
      player_grounded = false
		}

		player_pos += player_vel * rl.GetFrameTime()

		if player_pos.y > f32(rl.GetScreenHeight()) - 64 {
			player_pos.y = f32(rl.GetScreenHeight()) - 64
      player_grounded = true
		}

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLUE)

		rl.DrawRectangleV(player_pos, {64, 64}, rl.GREEN)

		rl.EndDrawing()
	}

	rl.CloseWindow()
}
