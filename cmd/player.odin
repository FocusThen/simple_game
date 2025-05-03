package main

import types "../types"
import rl "vendor:raylib"

player_pos: rl.Vector2
player_vel: rl.Vector2
player_grounded: bool
player_current_anim: types.Animation
player_anims: [2]types.Animation
player_flip: bool

player_init :: proc() {
	player_run := types.Animation {
		texture      = rl.LoadTexture("./assets/sprites/knight.png"),
		num_frames   = 4,
		frame_length = 0.1,
		name         = .Run,
	}

	player_idle := types.Animation {
		texture      = rl.LoadTexture("./assets/sprites/knight.png"),
		num_frames   = 4,
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

	//player_feet_collider := rl.Rectangle{player_pos.x - 4, player_pos.y - 4, 8, 4}

	player_grounded = false

	update_animation(&player_current_anim)
}
