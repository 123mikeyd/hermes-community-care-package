[🏠 Home](../README.md) · [Characters](../characters/README.md) · [Toy Box](../toy-box/README.md) · [Playable Starter](README.md)

---

# Quick start

## Open and run — Windows, macOS or Linux

1. Get the **standard Godot editor**, not a source build or export template, from https://godotengine.org/download/ . The exact tested version is **4.7.2.stable.official.ed1daf0bf**; a different version needs its own test.
2. Extract the complete ZIP. Keep `project.godot`, `Main.tscn`, scripts and `assets/` together. A folder with spaces is fine.
3. Open Godot's Project Manager → **Import** → browse to `project.godot` → **Import & Edit**. Wait for asset import to finish.
4. Press **F5 / Run Project**. On keyboards that reserve function keys, use the toolbar Run button or Fn+F5.
5. Click the game window, walk a few steps, press **2**, and walk again. Press **Esc** to quit. Editor Stop (F8) also works.

The editor workflow is platform-portable; **Windows 11 was actually tested**. macOS and Linux were not executed in this review. The engine is not included. Blender, Meshy, Hermes and an internet connection after installation are not needed.

## Controls

| Input | Action |
|---|---|
| WASD | Camera-relative walking |
| Hold Shift while moving | Run |
| 1 / 2 | Teknium / Doge Man; retains position |
| Hold Q / C | Orbit camera (E is reserved for interaction) |
| Mouse wheel | Zoom |
| E | Collect token, set checkpoint or inspect gun within 1.6 metres |
| R | Respawn at checkpoint, or safe spawn if none; retain token |
| F | Full restart: clear checkpoint and restore token |
| H | Toggle notes |
| Esc | Quit |

The car is solid scenery, not drivable. Stay inside the timber markers. No jump is implemented.

## Optional Windows helpers

Double-click `PLAY.cmd` to import and play; `EDIT.cmd` imports and opens the editor. The helper searches `GODOT_EXE`, then `godot.exe` on PATH, then a Godot installation beneath your home folder's `Godot` directory. Use the editor route above if detection fails. To choose the exact engine in PowerShell:

```powershell
$env:GODOT_EXE = 'D:\Tools\Godot\Godot_v4.7.2-stable_win64.exe'
.\PLAY.cmd
```

That path is an **example**, not a required install location. `PLAY.cmd -Verify` runs the graphical checks and exits; it is not normal free play. The helper puts local logs and verification screenshots in `.local/`. Do not redistribute that folder.

## Optional command-line check (all desktop platforms)

With your Godot executable available as `godot`, run from the extracted project folder:

```sh
godot --headless --path . --editor --import
godot --headless --path . --script res://verify.gd
```

Substitute your executable path (`godot.exe` on Windows, or the app bundle executable on macOS) if needed. Import must finish successfully before the second command. Expected ending: `STARTER_VERIFY 67 assertions failures=0`. The checks exercise real Godot input events, physics, rigs and camera; they do not substitute for human playtesting.

## Troubleshooting

- **Missing meshes / dependencies:** extract the entire ZIP, not just `project.godot`. Re-import in the tested engine. Never move the engine binary into `assets/`.
- **Editor view looks unlit or has no player:** this project creates lighting, players and camera at runtime. Press F5, not only the editor viewport preview.
- **First import takes time:** wait for completion. Imported cache/texture sidecars are generated locally; no Blender conversion is required.
- **Helper cannot find Godot / PowerShell blocked:** use the normal Project Manager route; do not disable system-wide security policies.
- **Black window / graphics failure:** confirm Compatibility renderer, update graphics drivers, and inspect Godot's Output/Debugger. Report the exact error, engine version and OS; do not randomly delete model files.
- **Keys do nothing:** click the game window. Movement uses physical WASD positions. On non-QWERTY layouts those positions may have different labels.
- **Stuck / wrong place:** press R. The outer mountain is decoration outside a bounded tested meadow.
- **After an experiment fails:** stop, restore your backup or undo only the edit, then rerun. Keep the original ZIP unchanged.

For sharing scope and third-party rights, read [NOTICE](../NOTICE.md). A successful test does not transfer third-party rights.

---

[🏠 Home](../README.md) · [Characters](../characters/README.md) · [Toy Box](../toy-box/README.md) · [Playable Starter](README.md)
