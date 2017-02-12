-- pico8/lua platformer player character code
-- by Morgan McGuire. See README.md.


run_speed         = 0.5
air_control       = 0.015625 -- just low enough to mostly prevent repeated wall-jump from making vertical progress
wall_jump_x_impulse = 0.5
terminal_velocity = 1.5
gravity           = 0.03125
jump_impulse      = -1.03125 -- exactly 2 blocks

-- # of 120 hz frames that a player can have
-- run off a ledge and still be allowed
-- to jump, or can jump before hitting a valid
-- surface
jump_late_grace  = 8
jump_early_grace = 8

-- runs at 120 hz to allow better physics stepping. i.e.,
-- call twice per _update60 frame
function update_player(player)
 local friction_factor   = friction(player.x + 4, player.y + 8)
 local ground_friction   = friction_factor * 0.005
 local run_acceleration  = friction_factor * 0.0078125

 -------------------------------
 -- running
  
 -- rename these as locals to save tokens
 -- and make code more readable
 local num, on_ground = player.num, player.since_ground == 0

 local x_acceleration = on_ground and run_acceleration or air_control

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
  
   player.since_jump = 0
   player.dy = jump_impulse
   -- immediately erase early jump grace period
   player.since_ground = 1000
 
   if not can_ground_jump then
    -- wall jump: apply horizontal impulse 
    -- based on prev facing direction
    player.dx = (player.face_lt and wall_jump_x_impulse or -wall_jump_x_impulse)

    -- change facing direction after wall jump
    player.face_lt = not player.face_lt
  end -- if wall jump
 else
  player.since_jump = min(player.since_jump + 1, 1000)
 end -- if jump

 -- was button o pressed in the previous frame?
 -- unlike btnp, explicit tracking
 -- avoids repetition of jump while held
 player.prev_btn_o = btn(btn_o, num)

 -------------------------------
 -- physics integrator. step in
 -- each axis independently. assume
 -- max(abs(dx), abs(dy)) <= 1.5
 -- near max velocity, players will
 -- hit 1px *above* the ground and then
 -- fall to it the next frame.
 --
 -- assume characters are only 5 pix high
 -- (even though the graphics are 8 pix) so
 -- that they bump their heads less when
 -- jumping into 1-sprite high passages
 
 player.touching_wall = false
 player.since_ground = min(player.since_ground + 1, 100) 

 -- locations to test on the map. the
 -- insets on x and y must match what
 -- the other axis tests
 local face_x, hit_x, hit_y =
  player.x + (player.face_lt and 0 or 7),
  player.x + 3.5 + 1.5 * sgn(player.dx) + player.dx,
  player.y + 5 + 2 * sgn(player.dy) + player.dy

 -- for wall jump/slide purposes
 -- at least the hand must be touching
 player.touching_wall = hsolid(face_x, player.y + 3, player.y + 7)

 if player.touching_wall and player.dx != 0 and player.dy > 0.1 then
  local x, y = face_x, player.y + 4
  -- wall-slide; apply friction
  player.dy = max(0, player.dy - friction(x, y) * 0.0035)
 end

 -- horizontal collision
 if hsolid(hit_x, player.y + 2, player.y + 7) then
  -- any part of body below hair
  -- hit a wall    
  player.dx = 0
 end
 
 player.x += player.dx

 
 -- vertical collision
 if vsolid(player.x + 2, hit_y, player.x + 5) then
  -- hit floor or ceiling
  if (player.dy > 0) player.since_ground = 0
  player.dy = 0
 end
 
 player.y += player.dy

end
