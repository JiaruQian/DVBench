# dv-052-aes128-decrypt-pipeline: Build a Complete UVM Verification Environment

Read `public/spec.md`, `public/ports.md`, `public/submission_format.md`, and `submission_contract.json`. The native DUT top is `TOPpipelined`. This is a fixed native configuration with no adjustable parameters. The RTL implementation is hidden.

Submit `flow/features.md`, `flow/features.json`, `flow/testplan.md`, `flow/testplan.json`, a self-contained `model/model.sv`, complete UVM sources, and `sources.f` at the submission root. Features describe what must be verified; the test plan explains the legal preparation and stimulus, independent expectations, valid sampling, and checks that detect failure. JSON must carry all facts; Markdown must describe the same IDs, references, interfaces, behavior, and methods and cannot supply facts omitted from JSON. The two formats need semantic agreement, not identical wording. Use the fields, types, and reference rules in `public/submission_format.md`. Reasonable splitting and merging are permitted; names and item counts do not substitute for correct content.

`flow/features.json` contains a nonempty `features` array with `feature_id`, `requirement_ids`, `module`, `definition`, `interface`, `timing`, and `boundary`; optional `parent_id` may be null or reference a defined feature without cycles. `flow/testplan.json` contains a nonempty `tests` array with `test_id`, `feature_ids`, `requirement_ids`, `stimulus`, `expected`, `checker`. Required text fields are nonempty strings; reference and interface arrays are nonempty and contain unique strings. Use unique IDs, the public specification's R-IDs, the candidate's own feature references. State preparation history, the actual stimulus domain, the expected relationship and timing, and the independent comparison and failure condition in the existing fields. Keep complete facts in both JSON documents and preserve agreement with their Markdown counterparts.

Use UVM with top `dvbench_top` and test `dvbench_test`. Provide real sequences, driver, monitor, agent/environment, predictor, scoreboard, checker, and functional coverage. Connect independent predictions from the submitted model to actual/expected scoreboard comparisons; protocol checks and coverage do not replace those comparisons. After legal completion, all transactions have drained, ERROR/FATAL counts are zero, and the comparison count is nonzero, emit `DVBench_COMPLETED` exactly once. Keep the complete UVM implementation under `tb/`. The optional `source` field may identify actual implementation locations.

The feedback contract in `public/submission_format.md` permits compilation diagnostics, simulation logs, and public-port waveforms from the submitted verification environment. Run `bash /public/environment/run.sh simulate --submission /submission --output /tmp/feedback-01.json` and use a new output filename for each attempt. Keep observations within that public interface.

Interact only through the native ports described in `public/ports.md`. Use rising-edge scalar `clk` and asynchronous active-low scalar `rst`. Native vectors are `ciphertext[127:0]`, `key10[127:0]`, and `plaintext[127:0]`; there are no inouts or handshake signals. Preserve all port names, directions, widths, packed and unpacked index directions, and the contracted parameter profile. Access to hidden implementation is prohibited. `sources.f` must list submission-relative `.sv`/`.v` paths in dependency order and include `model/model.sv` and every real UVM source. It must contain no compiler options, absolute paths, parent traversal, or wildcards.

## Mandatory Independent Model Entry Point

Define a self-contained SystemVerilog module named `dvbench_model` in `model/model.sv`, matching the native interface's port names, directions, widths, indexing, and parameters. The file must work independently without UVM, includes, or other submission files. Use this same file for independent model evaluation and in the testbench to produce expected values for the scoreboard; keep DUT actual outputs separate and compare actual against expected. Derive predictions only from reset, input stimulus, and their history. Do not instantiate the DUT, copy its implementation, read DUT actual to generate expectations, or replay golden outputs. A class, package, or function alone does not satisfy this module entry point.

## Debugging

Read `public/debug_feedback.md`. Submit a snapshot with `bash /public/environment/run.sh simulate --submission /submission --output /tmp/feedback-01.json`. Keep feedback outside the submission directory. The service uses the golden design and seed 1; mutation results are available only after the submission is frozen.

## Execution budget and completion

You have at most **300 cumulative agent decision turns**, with a delivery reminder at turn **250**. The budget persists across compaction and recovery of the same run. There is no whole-task wall-time or cumulative token limit. Compilation, simulation, and individual model requests have separate limits; read `public/deployment_budget.json`.

Read failed feedback and its listed compiler logs, simulation logs, and public-interface waveforms. Repair the submission and rerun while budget remains. A golden PASS is a debugging milestone: complete every required document, the independent model, and the UVM environment, and address known failures before finishing. Save the complete submission and report its actual verification status. Do not use subagents.

Use the framework's native file-editing tools. In Codex and OpenCode, `apply_patch` is a tool call, not a shell command; Claude Code uses `Write` and `Edit`. Use the framework's shell tool for commands. If required tools are unavailable, report an execution-environment failure instead of pretending that a tool call succeeded.

Run `bash /public/environment/run.sh simulate --submission /submission --output /tmp/feedback-01.json`, choosing a new output filename for each attempt. Read `public/debug_feedback.md` for artifact retrieval. Keep feedback outside `/submission`. Use the same self-contained `model/model.sv` for independent model evaluation and scoreboard predictions.
