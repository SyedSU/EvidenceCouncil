# Persistence provenance and limits

The Council persistence helper, platform adapter, GDExtension interface/configuration and build script were copied from the first-party EvidenceGenesis repository at commit `c6a172a8c458c3253dbe64e822500a25e2cec1c1`. Council domain/UI code is independent and its `config/custom_user_dir_name` is `EvidenceCouncil`; Genesis save locations are not used.

Verified identical source SHA-256 values at that commit:

- `native/scripts/save_files.gd`: `d758fdd67d4f6868abc976f00caeab5b1ae3dbec917760711ae672d0c97af11e`
- `native/durability/save_platform.c`: `81a361498725e3f0eae0ddcfd439871db92edd9fe329f76e9e239ab576e00bed`
- Pinned generated Godot ABI header: `640b48188708ba0016f8d7ace9e0e1d3279a41fa1226c59ff3193b15538bd254`

The adapter README and retained Godot MIT license describe its pinned upstream header and engine provenance. Native libraries are build outputs and ignored by Git. Build-time compiler/header checks do not prove device support.

The helper stages and checks JSON, preserves recovery state, checks expected active/backup revisions, refuses stale writes and blocks uncertain/corrupt state. The local domain test verifies save/reopen, a sequential stale writer, corrupt-original preservation and refusal to overwrite after a corrupt open. This is not a broad proof of physical power-loss behavior, hostile-directory safety, concurrent writer exclusion, all filesystem semantics, Windows, or Android. The adapter's platform-specific APIs require separate target acceptance. Markdown export checks write status but does not use the JSON recovery transaction.
