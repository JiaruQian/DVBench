# dv-056-decoder: Build a Complete UVM Verification Environment

Read `public/spec.md`, `public/ports.md`, `public/submission_format.md`, and `submission_contract.json`, together with `public/debug_feedback.md`. The DUT top is `decoder_top`. Use the complete fixed decoder_top with no top-level parameters. The RTL implementation is hidden.

Submit `flow/features.md`, `flow/features.json`, `flow/testplan.md`, `flow/testplan.json`, a self-contained `model/model.sv`, complete UVM source code, and `sources.f` at the submission root. Features explain what to verify; the test plan explains legal preparation and stimulus, independent expected behavior, valid sampling, and how checks detect failure. Each Markdown/JSON pair must use matching IDs, references, and semantics. JSON must contain the complete facts; Markdown cannot supply facts omitted from JSON. Follow the field types, reference rules, and unrelated paired examples in `public/submission_format.md`. Feature and test grouping may be chosen by the candidate. Test-plan `implementation_id` and `source` must locate real checks in the submitted HDL.

Use UVM 1.2 with top `dvbench_top` and test `dvbench_test`. Supply executable stimulus, native-port driving and monitoring, independent prediction, scoreboard comparison, checks, and functional coverage. Connect the submitted model to the scoreboard and compare its expected values with observed DUT actual values. Report failures with `UVM_ERROR` or `UVM_FATAL`. After stimulus and checking finish, drain in-flight work, release objections, and confirm zero ERROR/FATAL before printing `DVBench_COMPLETED` once in the report phase. Completion and coverage do not replace valid checking.

Interact with the DUT through its native ports. Preserve the published names, directions, widths, packed/unpacked index directions, and parameter profiles. Retain rising-edge clock clk and active-low asynchronous rst_n. All vectors descend: bs_Y/bs_Cb/bs_Cr [1023:0], bs_len_Y/bs_len_Cb/bs_len_Cr and total_bits_consumed [10:0], block_num [12:0], and R_out/G_out/B_out [511:0]. dec_start, dec_done, and trigger_dec are scalar. Bitstreams begin at bit [0] and the low output byte is raster0, as specified. There are no inout ports. List one relative `.sv` or `.v` path per line in `sources.f`, in dependency order, including `model/model.sv` and the complete UVM sources. Do not use absolute paths, `..`, wildcards, compilation options, or a DUT copy in the filelist. Includes other than tool-provided `uvm_macros.svh` must resolve within the submission using safe relative paths. Do not access DUT internal hierarchy, use force/release/bind or DPI/VPI, probe files/systems/networks for hidden assets, bypass the feedback interface, change parameters outside the published profiles, or submit a DUT implementation or empty stub.

## Mandatory Independent Model Entry Point

`model/model.sv` must define the SystemVerilog module `dvbench_model` with the native DUT port names, directions, bit widths, index directions, and the published parameter profile. It must compile by itself without UVM, includes, or other submitted files. Use this identical file for independent model evaluation and for the predictor connected to the UVM scoreboard. A class, package, or function alone does not satisfy the module contract. Generate expected outputs only from reset, inputs, and their history; do not instantiate the DUT, copy its implementation, or derive predictions from DUT actual outputs. Keep actual and expected signals separate for comparison.

## Debugging

Read `public/debug_feedback.md`. Submit a snapshot with `bash /public/environment/run.sh simulate --submission /submission --output /tmp/feedback-01.json`. Keep feedback outside the submission directory. The service uses the golden design and seed 1; mutation results are available only after the submission is frozen.

## Execution budget and completion

You have at most **300 cumulative agent decision turns**, with a delivery reminder at turn **250**. The budget persists across compaction and recovery of the same run. There is no whole-task wall-time or cumulative token limit. Compilation, simulation, and individual model requests have separate limits; read `public/deployment_budget.json`.

Read failed feedback and its listed compiler logs, simulation logs, and public-interface waveforms. Repair the submission and rerun while budget remains. A golden PASS is a debugging milestone: complete every required document, the independent model, and the UVM environment, and address known failures before finishing. Save the complete submission and report its actual verification status. Do not use subagents.

Use the framework's native file-editing tools. In Codex and OpenCode, `apply_patch` is a tool call, not a shell command; Claude Code uses `Write` and `Edit`. Use the framework's shell tool for commands. If required tools are unavailable, report an execution-environment failure instead of pretending that a tool call succeeded.

Run `bash /public/environment/run.sh simulate --submission /submission --output /tmp/feedback-01.json`, choosing a new output filename for each attempt. Read `public/debug_feedback.md` for artifact retrieval. Keep feedback outside `/submission`. Use the same self-contained `model/model.sv` for independent model evaluation and scoreboard predictions.
