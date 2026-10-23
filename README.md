# EvidenceCouncil

A native Godot team workspace with researcher, writer, reviewer and planner roles. Assign a task, compare editable contributions, assemble a final result, explicitly approve it, and export approved Markdown. Contributions and assignment/final edits revoke approval. Workspaces use independent Council storage and guarded native persistence.

This is a development implementation, not a published or signed release. Manual work is usable without a model. Optional desktop generation calls a separately started local OpenAI-compatible server over explicit loopback HTTP; it never substitutes synthetic content for unavailable inference. No model or runtime package is bundled. Android generation deliberately reports its missing reviewed native runtime bridge.

## Run locally

Use Godot 4.7.2 standard x64 and a C compiler:

```sh
python scripts/build_save_adapter.py
/path/to/Godot_v4.7.2-stable_linux.x86_64 --editor --path native --import
/path/to/Godot_v4.7.2-stable_linux.x86_64 --path native
```

Create an assignment, enter contributions manually or configure your running loopback server and model identifier, then edit and approve the final text. Save as chooses a workspace JSON file; export chooses Markdown. The default save is `user://workspace.json` in Godot's distinct `EvidenceCouncil` user directory. Save before opening/creating another workspace or closing with unsaved changes. Failed/corrupt opens block writes until a valid workspace is opened or a new workspace is created. Saving over an existing unrelated file is refused.

See [verification and limits](docs/VERIFICATION.md) and [save adapter provenance](docs/SAVE-SAFETY.md). No device, signing, distribution or real model acceptance is claimed.
