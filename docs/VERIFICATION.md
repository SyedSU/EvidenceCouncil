# Council verification — 2026-10-23

Linux x64 development verification used `/workspace/work/save-safety/engine/Godot_v4.7.2-stable_linux.x86_64` (Godot 4.7.2, `ed1daf0bf`) and Debian cc 14.2.0. Commands below ran from the repository root, with exit status zero for the final runs:

```sh
python scripts/build_save_adapter.py
$GODOT --headless --editor --path native --import
$GODOT --headless --path native --script tests/council_test.gd
$GODOT --headless --path native --script tests/ui_test.gd
python scripts/test_transport.py "$GODOT"
$GODOT --headless --path native --quit-after 3
DISPLAY=:94 $GODOT --audio-driver Dummy --path native --script tests/ui_test.gd -- --capture=/workspace/EvidenceCouncil/docs/evidence/native-ui.png
git diff --check
```

`GODOT` in this reproducibility example denotes the absolute engine path above. Generated native libraries and `.godot` caches are ignored; rebuild the adapter before running tests in a clean checkout.

## Evidence

- `evidence/build.log`, `import.log`, `startup.log`: adapter build, import and startup.
- `evidence/green.log`: `COUNCIL_FAILURES=0`; four role contributions, explicit approval/export gate, approval revocation, native save/reopen, sequential stale writer refusal and corrupt original preservation.
- `evidence/ui-red.log`: assignment edit retained approval before the fix (`UI_FAILURES=1`). `evidence/ui-green.log` and `ui-rendered.log`: `UI_FAILURES=0` after the fix; actual instantiated native controls exercise editor/domain synchronization, approval button, save/reopen, export and failed-open recovery. Programmatic editor changes explicitly emit `text_changed` to simulate the signal produced by user edits.
- `evidence/transport.log`: `TRANSPORT_FAILURES=0`; loopback fixture verifies bounded valid response, malformed JSON, empty response, HTTP error, redirects, oversized response, overlapping request rejection and cancellation without a late contribution. The malformed JSON case intentionally produces Godot's JSON parser error log while the client rejects it; it is an expected negative case.
- `evidence/native-ui.png` and `native-ui-approval.png`: actual Godot viewport captures under Xorg dummy display `:94`, OpenGL compatibility/Mesa llvmpipe. Text is explicitly marked manual demonstration. The second image scrolls to the final editor and retained approval status. `ui-rendered.log` includes an expected unsupported V-Sync warning from the dummy display.

The initial domain red log is retained as historical implementation evidence. Captures and fixture responses do not demonstrate model quality or actual AI inference.

## Remaining acceptance

No real model inference was exercised: no locally available model was supplied, and earlier model download attempts were blocked. No synthetic response is shown as real model output in the app. The fixture is solely a test server.

Windows build/runtime acceptance, Android runtime bridge/model/device checks, packaging, code signing, public release, OS native picker automation, keyboard/screen-reader acceptance and adversarial/power-loss persistence testing remain open. These Linux checks support a development implementation only. No other repository was edited or pushed by this work.
