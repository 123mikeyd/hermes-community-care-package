[🏠 Home](../README.md) · [Characters](../characters/README.md) · [Toy Box](../toy-box/README.md) · [Playable Starter](README.md)

---

# Small Godot and Blender lessons

Work in a copy, change one thing, run, then keep or undo. These are human-facing learning notes, not agent configuration. The checkpoint, collectible and E interaction already work; there is no need to build another game around them.

## 1. Follow one interaction

Open `interactions.gd`. `nearest()` chooses the closest target within `REACH`, using three-dimensional distance from the player's feet. `_unhandled_input()` accepts a fresh E press, not keyboard echo. A `collected` flag prevents duplicate rewards. Hidden art alone would not be enough to prevent a second pickup.

Try E outside range, walk closer, then tap and hold E. The token should disappear once. R preserves it; F clears the flag and shows it again. This is an in-memory example, not an inventory/save system. Targets are non-solid teaching markers; no line-of-sight rule is implemented. Keep them in the open meadow.

**Experiment:** in a copy change REACH from 1.6 to 1.3. Re-run the checks and review the visible prompt. Restore 1.6 before returning to the baseline.

## 2. Understand checkpoint versus restart

The amber beacon turns green after E. Its grounded position becomes the respawn location. `main.gd` uses that position for R and fall safety; F forgets it and resets collectible progress too. Switching actors does not throw away session state. Closing/reopening clears everything.

Try both characters. Check actual floor contact after R, not just the stored Vector3. Do not place the beacon inside a collider or outside the safe meadow. The automated test injects a fall because the perimeter deliberately prevents ordinary accidental falls.

## 3. One visual change in Godot

Find `LateAfternoonSun` in `main.gd`. Try changing energy from 0.65 to 0.5 in your experiment copy. Compare costume and face visibility, then restore it. This is runtime setup: changing a different editor light will not change that value.

Alternatively add one small MeshInstance3D prop in Main.tscn. A visible mesh is not a collider. Add a matching StaticBody3D/CollisionShape3D only if you want solid scenery; keep it away from spawn and checkpoint. Test both characters, camera and R. Do not widen the meadow or replace its terrain.

## 4. Blender to Godot, without damaging the source

Blender is optional and no Blender master is bundled. For a model you own or may edit:

1. Save a **separate working .blend** outside the Godot project. Keep the source and any live unsaved Blender session untouched.
2. Inspect dimensions, transforms, material image links and packed textures. For a character, also inspect its skeleton and named Actions. Do not apply transforms to an animated rig blindly.
3. For a simple practice prop, create a new mesh/material in your working file. Export only the selected prop as glTF Binary (`.glb`) to the experiment project's assets folder. Do not export cameras, lights or unrelated scene objects.
4. Let Godot import it, drag the GLB into the scene, and check scale, forward direction, ground placement and textures in the running game. Add collision separately if desired.
5. For a rigged character, preserve the original skeleton and in-place gait. Put gameplay travel on a parent/controller, not over the bone animation. This package uses only Idle/Walk/Run; exporting a full action library is not necessary.
6. Reopen the GLB in a fresh project/copy and confirm its textures do not depend on your original folders. Keep animation duration and loaded bone-track targets as separate checks from how it looks.

The gun illustrates why a hand-attachment transform differs from a display transform: its actual mesh is reused, while the runtime display placement changes. No firing or combat script was imported.

## A useful stopping point

Keep one screenshot, the exact test output and one sentence describing your change. Test a freshly extracted ZIP before handing it to someone else; caches can hide missing dependencies. Visual approval, runtime correctness and permission to share editable art are separate questions.

---

[🏠 Home](../README.md) · [Characters](../characters/README.md) · [Toy Box](../toy-box/README.md) · [Playable Starter](README.md)
