# Integration validation — 2026-10-23

Root integration preserved the product-specific native implementation and ran its complete documented Linux source checks using the reviewed Godot4.7.2 engine and first-party persistence adapter. Synthetic loopback fixtures test HTTP behavior; they do not establish model inference. The new source-check workflow repeats those gates from a clean Linux checkout using a checksum-verified developer engine. It emits no player binary or signing/publication claim.

Rendered native captures and their limits are retained in the existing verification/evidence documents.

Original first-party material remains proprietary; copied Godot ABI material retains its MIT notice. Compiler/engine binaries, weights, local saves and caches are excluded from Git. Windows/Android packaging, real product-local inference, model/runtime delivery, signing and device acceptance remain separately required before publication. The README's full product scope has not been removed.

Review corrections: export now refuses existing/managed paths and symlink components, stages/syncs checked bytes and coordinates exporters with a lease. Manual contribution edits cancel pending generation; late completion without an active request is ignored. Both defects were reproduced before fixes; RED/GREEN logs are retained under evidence/. The command `python scripts/verify.py /absolute/path/to/Godot4.7.2` passes import, domain, export safety, UI, startup and the synthetic HTTP suite. Noncooperating hostile filesystem races remain outside the guarantees.
