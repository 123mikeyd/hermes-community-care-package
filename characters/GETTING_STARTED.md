# Open an individual character

1. Choose a model in [the visual catalog](README.md) and download its **.blend** attachment. GitHub's automatic source-code ZIP does not contain the large model files.
2. Open it in Blender 5.2 or a compatible newer Blender. Textures are packed; no account, external texture folder or animation service is required. Embedded Python Text blocks have been removed; enabling scripts is not required to view the model.
3. Select the character mesh in the Outliner and press **Numpad .** to frame it. Switch to Material Preview to see textures. Native source positions and scales are retained, so models do not all begin at the same origin or size.
4. To bring it into another Blender scene: **File → Append**, select the .blend, open **Object**, select the model mesh, armature and placement parent (if present), and Append. Preserve the parent hierarchy and Armature modifier targets. For a control rig, append its existing widget objects as well. Opening the complete individual file is the simplest way to retain all dependencies.
5. Save your own working copy. Do not apply modifiers, merge separate head/glasses, regenerate rigs or decimate the source just to import it.

## What the rig label means

- **Bound native rig:** the mesh has an existing Armature modifier and weights, and small bone perturbations changed centered skin shape in a fresh reopen. This is a limited technical check, not full control-rig, deformation-quality or animation approval. Rough source weights remain.
- **Unbound metarig:** bones are present, but the mesh is not bound to them. It is not an animation-ready rig. Do not assume changing a metarig bone will move the skin.
- **Unrigged static mesh:** no armature is supplied.

Files open with armatures in **Rest Position** for neutral model inspection. To pose a bound copy, select its armature, change Armature Data → Skeleton → **Pose Position**, then enter Pose Mode. Existing control setups and pose state vary; reset/prepare the pose in your working copy before animating. Rigify widget/control data is retained where present, but generated UI scripts are not bundled. Not every bone in a control rig is intended for direct manipulation.

**There are no animation Actions or NLA strips.** This is not the parade dance library. You can author new motion in a personal copy; no imported dance or mocap clip is included. GLB exports are not provided or certified in this release. Export your own working copy if needed and verify it in the target application; Blender-native fidelity is the verified format here.

## Picking a variant

The same skin can have rigged, unrigged, metarig, high-density or low-density alternatives. These are not different characters. Pokemon Teknium's bound-rig file and older unbound-metarig file share the same native mesh/UV/packed-image data. Cyber Boxer has high-density, fast and low-poly alternatives. MMO Head, Glasses and Anime Shades are separate components; they have not been merged, rigged or automatically fitted into a new assembly.

Some models are very dense; check the per-file vertex/triangle counts and sizes. No collision shapes, LOD system, gameplay moves, game compatibility or optimized engine budget is promised.

## Check the download

Compare the SHA-256 checksum with [SHA256SUMS](SHA256SUMS) or the entry in [catalog.json](catalog.json). On Windows PowerShell:

```powershell
Get-FileHash .\doge-man.blend -Algorithm SHA256
```

The hash must match exactly. The catalog and release notes include no private machine paths or source-library histories. Read [NOTICE.md](NOTICE.md) before redistribution; these mixed fan/community designs do not carry a blanket commercial artwork license.
