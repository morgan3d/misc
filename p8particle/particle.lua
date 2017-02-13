-- pico8 lua particle system with fast direct-memory rendering and O(1) particle insertion and
-- removal by Morgan McGuire, @CasualEffects. Released as BSD-license open source February 2017.

particle_array, particle_array_length = {}, 0


function insert_particle(x, y, dx, dy, life, color)
 add(particle_array, {x = x, y = y, dx = dx, dy = dy, life = life or 8, color = color or 6})
 particle_array_length += 1
end


function process_particles()
 -- @casualeffects particle system

 -- simulate particles during rendering for efficiency
 local p = 1
 while p <= particle_array_length do
  local particle = particle_array[p]

  -- gravity
  particle.dy += 0.0625
  
  -- advance state
  particle.x += particle.dx
  particle.y += particle.dy
  particle.life -= 1
  
  -- the bitwise expression will be negative if either coordinate is negative or greater than 127
  if particle.life < 0 or band(bor(particle.x, particle.y), 0xff80) != 0 then

   -- delete dead particles efficiently. pico8 doesn't support
   -- table.setn, so we have to maintain an explicit length variable
   particle_array[p] = particle_array[particle_array_length]
   particle_array[particle_array_length] = nil
   particle_array_length -= 1

  else

   -- draw the particle by directly manipulating the
   -- correct nibble on the screen
   local addr = bor(0x6000, bor(shr(particle.x, 1), shl(band(particle.y, 0xffff), 6)))
   local pixel_pair = peek(addr)
   if band(particle.x, 1) == 1 then
    -- even x; we're writing to the high bits
    pixel_pair = bor(band(pixel_pair, 0x0f), shl(particle.color, 4))
   else
    -- odd x; we're writing to the low bits
    pixel_pair = bor(band(pixel_pair, 0xf0), particle.color)
   end
   poke(addr, pixel_pair)
   
   p += 1
  end -- if alive
 end -- while
end
