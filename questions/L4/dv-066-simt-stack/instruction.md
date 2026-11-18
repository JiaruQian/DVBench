# dv-066-simt-stack: Build a Complete UVM Verification Environment

Read `public/spec.md`, `public/ports.md`, `public/submission_format.md`, and `submission_contract.json`, together with `public/debug_feedback.md`. The DUT top is `simt_stack`. Use the fixed complete simt_stack with 8 warps, 4 lanes, 32-bit addresses, 3-bit warp IDs, and 24 physical records per warp. There are no top-level parameters or external macro files. The RTL implementation is hidden.

Submit `flow/features.md`, `flow/features.json`, `flow/testplan.md`, `flow/testplan.json`, a self-contained `model/model.sv`, complete UVM source code, and `sources.f` at the submission root. Features explain what to verify; the test plan explains legal preparation and stimulus, independent expected behavior, valid sampling, and how checks detect failure. Each Markdown/JSON pair must use matching IDs, references, and semantics. JSON must contain the complete facts; Markdown cannot supply facts omitted from JSON. Follow the field types, reference rules, and unrelated paired examples in `public/submission_format.md`. Feature and test grouping may be chosen by the candidate. Test-plan `implementation_id` and `source` must locate real checks in the submitted HDL.

Use UVM 1.2 with top `dvbench_top` and test `dvbench_test`. Supply executable stimulus, native-port driving and monitoring, independent prediction, scoreboard comparison, checks, and functional coverage. Connect the submitted model to the scoreboard and compare its expected values with observed DUT actual values. Report failures with `UVM_ERROR` or `UVM_FATAL`. After stimulus and checking finish, confirm zero ERROR/FATAL before printing `DVBench_COMPLETED` once. Completion and coverage do not replace valid checking.

Interact with the DUT through its native ports. Preserve the published names, directions, widths, packed/unpacked index directions, and parameter profiles. Retain the sole rising-edge clock clk and asynchronous active-low rst_n. branch_ctl_mask_init_i, if_mask_mask_i, and out_mask_o are [3:0]; branch_ctl_pc_branch_i, branch_ctl_pc_execute_i, fetch_ctl_new_pc_o, and pc_reconv_i are [31:0]; branch_ctl_wid_i, complete_wid_o, fetch_ctl_wid_o, if_mask_wid_i, and input_wid_i are [2:0]. All other published ports are scalar. Packed indices descend to 0, and there are no inout ports. List one relative `.sv` or `.v` path per line in `sources.f`, in dependency order, including `model/model.sv` and the complete UVM sources. Do not use absolute paths, `..`, wildcards, compilation options, or a DUT copy in the filelist. Includes other than tool-provided `uvm_macros.svh` must resolve within the submission using safe relative paths. Do not access DUT internal hierarchy, use force/release/bind or DPI, probe files/systems/networks for hidden assets, bypass the feedback interface, change parameters outside the published profiles, or submit a DUT implementation.

Instantiate the native DUT directly exactly once in `dvbench_top`, connect its public ports, and use the same self-contained model file in the scoreboard as required by `public/debug_feedback.md` and `submission_contract.json`.

## Mandatory Independent Model Entry Point

`model/model.sv` must define the SystemVerilog module `dvbench_model` with the native DUT port names, directions, bit widths, index directions, and the published parameter profile. It must compile by itself without UVM, includes, or other submitted files. Use this identical file for independent model evaluation and for the predictor connected to the UVM scoreboard. A class, package, or function alone does not satisfy the module contract. Generate expected outputs only from reset, inputs, and their history; do not instantiate the DUT, copy its implementation, or derive predictions from DUT actual outputs. Keep actual and expected signals separate for comparison.

## Debugging

Read `public/debug_feedback.md`. Submit a snapshot with `bash /public/environment/run.sh simulate --submission /submission --output /tmp/feedback-01.json`. Keep feedback outside the submission directory. The service uses the golden design and seed 1; mutation results are available only after the submission is frozen.

## Execution budget and completion

You have at most **300 cumulative agent decision turns**, with a delivery reminder at turn **250**. The budget persists across compaction and recovery of the same run. There is no whole-task wall-time or cumulative token limit. Compilation, simulation, and individual model requests have separate limits; read `public/deployment_budget.json`.

Read failed feedback and its listed compiler logs, simulation logs, and public-interface waveforms. Repair the submission and rerun while budget remains. A golden PASS is a debugging milestone: complete every required document, the independent model, and the UVM environment, and address known failures before finishing. Save the complete submission and report its actual verification status. Do not use subagents.

Use the framework's native file-editing tools. In Codex and OpenCode, `apply_patch` is a tool call, not a shell command; Claude Code uses `Write` and `Edit`. Use the framework's shell tool for commands. If required tools are unavailable, report an execution-environment failure instead of pretending that a tool call succeeded.

Run `bash /public/environment/run.sh simulate --submission /submission --output /tmp/feedback-01.json`, choosing a new output filename for each attempt. Read `public/debug_feedback.md` for artifact retrieval. Keep feedback outside `/submission`. Use the same self-contained `model/model.sv` for independent model evaluation and scoreboard predictions.
