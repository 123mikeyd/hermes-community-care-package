# Pick one toy and start small

This collection is for experiments, not a promise of finished game-ready assets. Start with one prop before importing everything.

## Choose a download

- **Individual Blender file:** editable object, its materials, and packed textures. Character dependencies are included where stated on the catalog card.
- **GLB, where offered:** an exchange-format copy. Read the card's verification notes; an export is not a completed mod integration.
- **Original full collections:** available in the [first Toy Box release](https://github.com/123mikeyd/hermes-community-care-package/releases/tag/toy-box-v0.1.0). These remain available for people who prefer the whole set.

Download the actual named asset under the release's **Assets** section. GitHub's automatic **Source code** archives contain repository files, not the large Blender release attachments.

## Explore in Blender

1. Keep your download unchanged and work from a copy.
2. Open its `.blend` file. These assets were prepared using Blender 5.2.
3. Select the asset in the Outliner and use **View > Frame Selected** in the 3D Viewport.
4. Switch to **Material Preview** to inspect textures. Images are packed in the Blender file.
5. To bring an asset into another Blender scene, use **File > Append** and browse the downloaded file's **Object** entries. Include the armature and related objects when the catalog says they are required.

The modular Teknium head and glasses are independent meshes. Separate objects do not mean automatically fitted attachments or an animation rig.

## First experiments

Choose one small goal:

- **Speedboat:** place it in a simple water scene. Add movement only after you can see it correctly.
- **Blast door:** place it in a wall opening, then build your own open/close motion and interaction.
- **Supplies:** make a small storage corner and add a simple collision proxy.
- **Teknium head and glasses:** practice positioning the separate parts on a copy of your character.

These are ideas, not features already implemented in the downloads. Door movement, buoyancy, collision, controllers, rigging, and gameplay scripts are not automatically supplied with a mesh.

## Before using an asset in a game

- Check the catalog's geometry counts against your project's budget. This drop does not promise low-poly or mobile-ready assets.
- Confirm facing, scale, material appearance, and any rig dependencies in your own engine.
- Build simple collision shapes separately where needed.
- Test a single asset in a small scene before copying it into a larger project.
- Keep changes in a separate project or branch so experimentation is easy to undo.

For an existing playable learning example, see the separate [Misty Mountain Godot starter](../starter/QUICKSTART.md). This Toy Box does not alter that starter's gameplay.

## Reuse and fan-art scope

Read each catalog entry's notes and the [repository notice](../NOTICE.md). Recognizable fan art is not a blanket grant of third-party character, trademark, or likeness rights. No blanket commercial-use or CC0 artwork license is asserted for this mixed collection.

## Tell us what helped

When reporting a problem, include the asset name, your Blender/engine version, what you tried, and a screenshot if useful. Distinguish import failures from feature requests such as collision, animation, or a new format.
