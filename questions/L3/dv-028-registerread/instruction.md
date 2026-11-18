# dv-028-registerread: Build a Complete UVM Verification Environment

Read `public/spec.md`, `public/ports.md`, `public/submission_format.md`, and `submission_contract.json`, together with `public/debug_feedback.md`. The native DUT top is `RegisterRead`. There are no top-level parameters. The RTL implementation is hidden.

Submit `flow/features.md`, `flow/features.json`, `flow/testplan.md`, `flow/testplan.json`, `model/model.sv`, all complete UVM sources, and `sources.f` at the submission root. Features explain what the public specification requires; the test plan explains how legal stimulus reaches those behaviors, how expected results are predicted independently, when observations are valid, and how failures are detected. Implement the plan in the submitted HDL.

Use the fields, types, and references in `public/submission_format.md`. `features.json` contains the complete feature facts in the root object’s nonempty `features` array, including `feature_id`, `requirement_ids`, `module`, `definition`, `interface`, `timing`, and `boundary`. `testplan.json` contains the complete plan in the root object’s nonempty `tests` array, including `test_id`, `feature_ids`, `requirement_ids`, `stimulus`, `expected`, `checker`, `implementation_id`, and `source`. References must resolve to the public requirements, your own features, and actual submitted checks. Each Markdown file must present the same IDs, references, and complete meaning as its JSON counterpart. JSON carries all facts; Markdown cannot supply missing JSON facts. Reasonable grouping, splitting, and wording are allowed. Consult the unrelated paired examples for format.

Use UVM 1.2 with simulation top `dvbench_top` and test `dvbench_test`. Provide the sequence, driver, monitor, agent/environment, predictor, scoreboard, checker, and functional coverage required by the public contract. Connect predictions from your independent model to a scoreboard that compares separate expected and DUT actual observations. Use `UVM_ERROR`/`UVM_FATAL` for failures. After stimulus and checking finish, in-flight work drains, objections are released, and ERROR/FATAL counts are zero, print `DVBench_COMPLETED` once in the report phase. Completion and coverage do not replace valid checking.

Interact with the DUT through its native ports only. Preserve the names, directions, widths, packed/unpacked dimensions, and index directions in `public/ports.md`, and use only the contracted parameter profile. The clock port is named clock and state advances on its rising edge; reset is synchronous active-high. There are no inouts. Keep every packed index descending to zero, including the 65-bit RF and execution operands and the full lane-specific metadata widths. Internal hierarchical access, force/release/bind, DPI/VPI, file/system/network probing, DUT implementation copies, and empty DUT stubs are prohibited by the public contract. Keep feedback artifacts outside the submission.

`sources.f` must list one relative `.sv` or `.v` source path per line in dependency order, including `model/model.sv` and the actual UVM sources. Do not put compiler options, absolute paths, parent traversal, wildcards, or DUT copies in the filelist. Except for tool-provided `uvm_macros.svh`, includes must use safe relative paths within the submission; follow the submission-root path rules in the public format.

Instantiate RegisterRead directly exactly once in dvbench_top. Submit only ordinary files, at most 256 files and 16 MiB total. The public debugging contract also prohibits arbitrary dumps, escaped identifiers, macro token concatenation, and file/OS/network system tasks; standard UVM macros and ordinary empty header guards are permitted.

## Mandatory Independent Model Entry Point

`model/model.sv` must define a self-contained SystemVerilog module named `dvbench_model` with the DUT's native port names, directions, widths, index directions, and parameter declarations for the public profile. Preserve the complete two-lane native interface rather than introducing a transaction-only adapter. Use the identical file for independent model evaluation and for prediction in the UVM scoreboard. Derive expected outputs only from reset, native input stimulus, and its history; never read DUT actual outputs to predict themselves, instantiate the DUT, copy its implementation, or replay reference outputs. Do not depend on UVM, includes, or other submission files in this model. Classes, packages, or functions alone do not satisfy the module entry point.

## Debugging

Read `public/debug_feedback.md`. Submit a snapshot with `bash /public/environment/run.sh simulate --submission /submission --output /tmp/feedback-01.json`. Keep feedback outside the submission directory. The service uses the golden design and seed 1; mutation results are available only after the submission is frozen.

## Execution budget and completion

You have at most **300 cumulative agent decision turns**, with a delivery reminder at turn **250**. The budget persists across compaction and recovery of the same run. There is no whole-task wall-time or cumulative token limit. Compilation, simulation, and individual model requests have separate limits; read `public/deployment_budget.json`.

Read failed feedback and its listed compiler logs, simulation logs, and public-interface waveforms. Repair the submission and rerun while budget remains. A golden PASS is a debugging milestone: complete every required document, the independent model, and the UVM environment, and address known failures before finishing. Save the complete submission and report its actual verification status. Do not use subagents.

Use the framework's native file-editing tools. In Codex and OpenCode, `apply_patch` is a tool call, not a shell command; Claude Code uses `Write` and `Edit`. Use the framework's shell tool for commands. If required tools are unavailable, report an execution-environment failure instead of pretending that a tool call succeeded.

Run `bash /public/environment/run.sh simulate --submission /submission --output /tmp/feedback-01.json`, choosing a new output filename for each attempt. Read `public/debug_feedback.md` for artifact retrieval. Keep feedback outside `/submission`. Use the same self-contained `model/model.sv` for independent model evaluation and scoreboard predictions.
