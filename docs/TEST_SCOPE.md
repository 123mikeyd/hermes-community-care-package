# Verification scope

## Existing accepted baseline

The earlier accepted gameplay recorded 67 assertions / 0 failures, supplemental 8 / 0 and separate ordinary-walk interaction checks 4 / 0. These are historical results, not newly repeated tests. Windows 11 and Godot 4.7.2 Compatibility rendering were used.

## Original replacement motion

The prior motion pass verified preserved mesh/skin/material/texture data and removal of old animation-only buffers. All six original clips were imported and sampled at nine times each, with finite bones and a sampled loop seam below 0.001 mm. Explicit 60 Hz import and disabled optimizer held sampled ankle discrepancy within 5.7 mm. Actual Blender preview frames and installed Godot poses were inspected. Run is a brisk stepping variant; no terrain-adaptive foot IK or polished sprint is claimed.

## Publication derivative

All runtime assets, motion, import settings, gameplay logic and tests are preserved. Only the application display name, HUD/help labels and an introductory comment are relabeled from review wording to community prototype. The existing internal user-data directory identifier is retained to avoid behavioral changes. Documentation and supply-drop banner are updated; the historical gameplay screenshot is omitted rather than presented as a new capture.

Publication checks cover exact allowlists, file hashes, unchanged runtime content except the named labels, asset manifests, private-path/secret scanning, GitHub file sizes, ZIP paths/member hashes, staged and remote Git trees, README bytes, release asset metadata, and an actual downloaded release ZIP/checksum comparison. No gameplay rerun, animation change, new feature or additional platform validation is part of this publication pass.
