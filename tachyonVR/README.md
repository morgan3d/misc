VR Starter program 
Morgan McGuire
Updated 2014-08-14 12:00pm

Uses SteamVR and VRTK plugins and open source and free assets
from G3D and the Unity Asset Store.

This project may be updated frequently in the future. I'll release an official version with the Graphics Codex and full discussion of how to use Unity at some point.

Unity remembers the starting Scene for the game, but not for the editor. So, double-click on the “Game” scene in the Assets window to see the game properly in the editor. Otherwise you’ll be looking at the default “Untitled” scene and very confused.

The main room is the G3D Holodeck model. I imported this into Unity by dropping the OBJ file in the Asset window. Unity creates materials for OBJ files but loses the actual textures and properties, so I remapped them by hand.

The green and red balls are Prefabs. I built them in the scene, dragged them onto new Prefabs, and then deleted the versions in the scene. Once created, you can also modify a Prefab in the Asset window. There’s one unnecessary level of indirection in the balls. I could have attached the Mesh Components directly to the ball GameObjects, but I put them inside of child objects. That was in case I later wanted to add more geometry on those parent objects.

The movement of the balls is handled by the physics system. I disabled gravity and set them to a constant velocity at spawn. Defined this way, if two balls hit each other, they’d actually collide, bounce off, and break the game. So, I used Layers to mask out collisions of balls against each other (see https://docs.unity3d.com/Manual/LayerBasedCollision.html.)

The actual core game code is in the GameState script, which I added to the HUD for lack of another good place to put it. That spawns the balls at random times and manages the score display.

The paddle has a Collider but no Rigidbody, and it has the isTrigger flag. This allows me to use the physics system to detect when a ball hits. The paddle’s Update method also sets the color of the paddle every frame to help line up the balls and paddle in 3D.

The explosion particle system is also a Prefab that is instantiated on collision. It has a script to destroy itself when the animation completes so that I don’t have to keep track of them.

The paddle reads from Input.GetAxis, which automatically handles gamepads as well as keys. It then explicitly modifies its position once per frame instead of setting a velocity and letting the physics system handle it.

To make the floor reflective, I added a baked reflection probe in the center of the room. Its proxy box needs to extend slightly outside of the room so that the inset door frame will use it. This makes the reflection slightly wrong, but Unity seems to require that the box proxy matches the blending volume for probes. I also had to mark the room as static so that it would appear in the probe.

Put [CameraRig] where you want the center of the real-world tracking volume to be in the virtual world. If you teleport, you’ll want to warp this object. Make sure that it is not rotated in pitch, and that it is placed on the ground.

The Camera (head) is a tracked point midway between the eyes. Camera (eye) is the actual eye rendering camera. Do not modify its transformation from the identity unless you intentionally want to move the eye away from the real head (which is rarely a good idea).

The Controller GameObjects are, of course, the Vive controllers (be warned: the word “controller” is also used to indicate manager and animation classes elsewhere in Unity, not input devices). In order to keep the VR starter project compatible with the Rift and DK2, I did not make the starter project use the controllers for actual input...I made them visible in the game, but used gamepad and keyboard input for moving the in-game paddle.
 
The [SteamVR] GameObject allows you to switch between seated and standing configurations. It also allows you to specify a separate “External Camera” to use for the monitor view if you don’t want to mirror the player’s first-person view.

I’ve attached the VRTK Teleport, Controller Events, and Bezier Pointer scripts to the controllers to allow you to teleport as in the Valve Labs demo if you have a Vive.