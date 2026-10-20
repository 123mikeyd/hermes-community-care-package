[🏠 Home](../README.md) · [Characters](../characters/README.md) · [Toy Box](../toy-box/README.md) · [Playable Starter](../starter/README.md)

---

# Original locomotion source

This prototype replaces all six Teknium/Doge locomotion clips with original procedural poses. It does not reuse or retarget existing motion. The source first strips previous animation channels/accessors and physically rebuilds the binary from retained art views, then derives poses from the native rest anatomy.

## Clips and editing

| Runtime name, both characters | Length | Motion |
|---|---:|---|
| `Idle` | 2.4 seconds | Relaxed arms, very small breathing/pelvis motion; both feet held |
| `Walk` | 0.72 seconds | Alternating straight-line stance and lifted swing, forward knee poles, arm counter-swing |
| `Run` | 0.42 seconds | Original brisk stepping variant with higher knees and bent elbows, preserving Shift |

Edit `author_original_motion.py`. The clip tuple defines period, existing controller speed, pelvis lowering and swing lift. The leg solver derives native lengths from rest joints; anatomical forward comes from `Head` to `headfront`. Stance speed matches the unchanged controller after character scale. Presentation offset compensation preserves the existing calibration file without editing it. Exact first/last values close each loop.

Run in a **copy** of the package with Blender 5.2 available:

```text
blender --background --threads 2 --python animation-source/author_original_motion.py
```

The script locates `starter/` relative to itself. Blender provides `mathutils`; no pip modules, online service or old motion library are required. It replaces only the two GLBs and writes a numeric authoring report. For a separate output, pass `-- INPUT_STARTER OUTPUT_STARTER` after the script filename. The input can be these replacement GLBs: only their retained rest/art data is used, so rebuilding is deterministic.

Keep `starter/assets/tek.glb.import` and `doge.glb.import`: animation import is 60 Hz with optimizer disabled. Default optimized import rounded the fast ankle motion too aggressively. Do not delete these settings when packaging; `.godot/` cache is disposable and not included. The preserved starter `.gitignore` ignores `*.import`, so a later Git publisher must explicitly force-add these two pinned import files (`git add -f starter/assets/tek.glb.import starter/assets/doge.glb.import`).

## Actual preview

[Original motion MP4](original-locomotion.mp4): 160 rendered frames, 24 fps, 640x480, 6.666667 seconds. Teknium is left, Doge right. Idle occupies frames 0–57, Walk 58–109, Run 110–159. These are real CPU Blender renders from the replacement GLBs, not generated concept footage. Characters are shown in-place so the whole loop remains visible. No Blender master scene is bundled.

This is intentionally minimal prototype locomotion, not polished motion capture. Stable torso, bent knees, arm counter-swing and alternating foot support are visible. There is no new terrain-adaptive IK, sprint flight phase, cloth simulation or facial animation. Character mesh/skin/material/texture rights remain independent of original motion authorship. No other gameplay or art was redesigned.

---

[🏠 Home](../README.md) · [Characters](../characters/README.md) · [Toy Box](../toy-box/README.md) · [Playable Starter](../starter/README.md)
