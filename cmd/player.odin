package main

import types "../types"
import "core:fmt"
import rl "vendor:raylib"

player_pos: rl.Vector2
player_vel: rl.Vector2
player_grounded: bool
player_current_anim: types.Animation
player_anims: [2]types.Animation
player_flip: bool
player_sprite: rl.Texture2D

player_init :: proc() {
	player_sprite = rl.LoadTexture("./assets/sprites/knight.png")

	run := get_tile_row_range(player_sprite, "3-8", rl.Vector2{32, 32})

	fmt.println(run)


	player_run := types.Animation {
		texture      = player_sprite,
		frames       = run,
		frame_length = 0.1,
		name         = .Run,
	}

	player_idle := types.Animation {
		texture      = player_sprite,
		frames       = get_tile_row_range(player_sprite, "1-4", rl.Vector2{32, 32}),
		frame_length = 0.5,
		name         = .Idle,
	}
	player_anims = {player_idle, player_run}

	player_current_anim = player_idle
}

player_update :: proc() {
	if rl.IsKeyDown(.A) {
		player_vel.x = -100
		player_flip = true
		if player_current_anim.name != .Run {
			player_current_anim = player_anims[1]
		}
	} else if rl.IsKeyDown(.D) {
		player_vel.x = 100
		player_flip = false
		if player_current_anim.name != .Run {
			player_current_anim = player_anims[1]
		}
	} else {
		player_vel.x = 0
		if player_current_anim.name != .Idle {
			player_current_anim = player_anims[0]
		}
	}

	// gravity
	player_vel.y += 1000 * rl.GetFrameTime()

	if player_grounded && rl.IsKeyPressed(.SPACE) {
		player_vel.y = -300
	}

	player_pos += player_vel * rl.GetFrameTime()

	player_grounded = false

	update_animation(&player_current_anim)
}
