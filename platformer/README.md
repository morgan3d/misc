This is code demonstrating how to simulate player-character movement in a 2D platformer
with the following features:

* variable ground friction (e.g., ice)
* gravity
* terminal velocity
* jumping
* variable-height jumping
* hazards (e.g., spikes)
* wall-sliding (w/ variable friction)
* wall-jumping
* early jump grace period (http://kpulv.com/106/Jump_Input_Buffering/)
* late jump grace period (http://kpulv.com/123/Platforming_Ledge_Forgiveness/)

It is programmed in the style of pico-8 lua with the assumption of 8x8 pixel sprites. 
See [`platformer.lua`](platformer.lua) for the fully-commented version and
[`platformer-min.lua`](platformer-min.lua) for a more minimalist version.
