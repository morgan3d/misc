-- pico8/lua platformer player character code
-- by Morgan McGuire. See README.md.


run_speed, air_control, wall_jump_x_impulse, terminal_velocity, gravity, jump_impulse, jump_late_grace, jump_early_grace = 0.5, 0.015625, 0.5, 1.5, 0.03125, -1.03125, 8, 8

-- runs at 120 hz to allow better physics stepping. i.e.,
-- call twice per _update60 frame
function update_player(player)
 local friction_factor   = friction(player.x + 4, player.y + 8)
 local ground_friction, run_acceleration, num, on_ground = friction_factor * 0.005, player.num, player.since_ground == 0

 -------------------------------
 -- running
 local x_acceleration = on_ground and run_acceleration or air_control

 -- directions
 if btn(btn_lt, num) then
  player.face_lt = true
  if (player.dx > -run_speed) player.dx -= x_acceleration
 elseif btn(btn_rt, num) then
  player.face_lt = false
  if (player.dx < run_speed) player.dx += x_acceleration
 elseif on_ground then
  -- no buttons and on ground: apply friction to slow down
  player.dx = (player.dx > 0) and max(0, player.dx - ground_friction) or min(0, player.dx + ground_friction)
 end

 if player.since_jump < 20 and not on_ground and not btn(btn_o, num) and player.dy < 0 then
  -- short jump; artificially increase gravity
  gravity *= 8
 end

 -- accelerate down (+y)
 player.dy = min(terminal_velocity, player.dy + gravity)

 -------------------------------
 -- jumping

 local can_ground_jump, can_wall_jump = player.since_ground < jump_late_grace, player.dy >= 0 and player.touching_wall

 -- count frames since the "o" (jump) button was pressed
 player.since_btn_o = (btn(btn_o, num) and not player.prev_btn_o) and 0 or min(1000, player.since_btn_o + 1)

 if (can_ground_jump or can_wall_jump) and player.since_btn_o < jump_early_grace then
   -- immediately erase early jump grace period
   player.since_jump, player.dy, player.since_ground = 0, jump_impulse, 1000

   -- wall jump
   if (not can_ground_jump) player.dx, player.face_lt = (player.face_lt and wall_jump_x_impulse or -wall_jump_x_impulse), not player.face_lt
 else
  player.since_jump = min(player.since_jump + 1, 1000)
 end -- if jump

 -- was button o pressed in the previous frame?
 player.prev_btn_o, player.touching_wall, player.since_ground = btn(btn_o, num), false, min(player.since_ground + 1, 100) 

 -------------------------------
 -- physics integrator

 local face_x, hit_x, hit_y = player.x + (player.face_lt and 0 or 7), player.x + 3.5 + 1.5 * sgn(player.dx) + player.dx, player.y + 5 + 2 * sgn(player.dy) + player.dy

 player.touching_wall = hsolid(face_x, player.y + 3, player.y + 7)

 if player.touching_wall and player.dx != 0 and player.dy > 0.1 then
  -- wall-slide; apply friction
  player.dy = max(0, player.dy - friction(face_x, player.y + 4) * 0.0035)
 end

 -- horizontal collision
 if (hsolid(hit_x, player.y + 2, player.y + 7)) player.dx = 0
 player.x += player.dx
 
 -- vertical collision
 if vsolid(player.x + 2, hit_y, player.x + 5) then
  -- hit floor or ceiling
  if (player.dy > 0) player.since_ground = 0
  player.dy = 0
 end
 
 player.y += player.dy
end
