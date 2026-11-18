# Complete A Submission Format

Submit flow/features.json and features.md, flow/testplan.json and testplan.md, model/model.sv, sources.f, and a complete set of self-built UVM components. features.md is for reading and expresses all functionality using the same IDs as the JSON; features.json carries the complete facts, references, and semantic evaluation, and Markdown cannot supplement omissions in the JSON. Mutually contradictory statements in the two documents under the same conditions/history/window are treated as one erroneous claim, deducting the actually related obligations without automatically zeroing out other content. Reasonable splitting, merging, renaming, parent-child hierarchies, and evidence-supported interface aliases are allowed.

The root object of features.json is {"features":[...]}, a nonempty array. Each feature_id/module/definition/timing/boundary is a nonempty string, and requirement_ids/interface are nonempty arrays of nonduplicate strings. IDs are unique; requirement_ids references public R-IDs in the spec; interface references actually relevant native ports, and complete facts may be expressed jointly by multiple local features. Optional parent_id is an existing ID or null and must not form a cycle; optional interface_aliases describes actual aliases and does not introduce nonexistent ports.

The root object of testplan.json is {"tests":[...]}, a nonempty array. Each test_id/stimulus/expected/checker/implementation_id/source is a nonempty string; feature_ids references feature IDs in this submission, and requirement_ids references public R-IDs, both as nonempty arrays of nonduplicate strings. stimulus must describe reachable prior states, inputs, and the actual coverage domain; expected gives independent, concrete relations; sampling times may be specified in any relevant field. checker describes independent prediction, comparison windows, X/Z error detection, and failure criteria. implementation_id and source locate the real UVM implementation; no additional assertions.json is required. testplan.md expresses the same content using the same test IDs, and the JSON carries complete stimulus and checking facts.

Generic example unrelated to this task: suppose another DUT has input enable and output count, and public obligation R-example-001 is to increment the count by 1 when enabled.

features.json example:
```json
{"features":[{"feature_id":"F-counter","requirement_ids":["R-example-001"],"module":"counter","definition":"On a rising edge with enable=1, count increases by 1; otherwise it holds.","interface":["clk","enable","count"],"timing":"The new value is visible when combinational logic is stable after the edge.","boundary":"Wraps around according to the output width."}]}
```
Corresponding features.md example:
```markdown
## F-counter
R-example-001; counter; interfaces clk/enable/count. On a rising edge with enable high, count increases by 1; otherwise it holds, wrapping around according to the bit width; visible once stable after the edge.
```
testplan.json example:
```json
{"tests":[{"test_id":"T-counter","feature_ids":["F-counter"],"requirement_ids":["R-example-001"],"stimulus":"After a legal reset, drive enable alternately and continue counting until wraparound; change inputs on falling edges.","expected":"Accumulate enable from the input history, modulo the output width.","checker":"At 1ns after each rising edge, perform a four-state comparison of count against an independent counter; issue UVM_ERROR on mismatch and check that the comparison count is nonzero.","implementation_id":"counter_sequence","source":"counter_tb.sv"}]}
```
Corresponding testplan.md example:
```markdown
## T-counter
Covers F-counter/R-example-001; after reset, alternate enable on falling edges and cover wraparound, independently accumulate the input history according to the bit width, perform four-state comparisons 1ns after rising edges, and issue UVM_ERROR on mismatch. Implementation counter_sequence, counter_tb.sv.
```

# HDL

model/model.sv must be self-contained and declare dvbench_model, with native parameter/port names, directions, widths, and indices matching ports.md. This file is used for both independent D and UVM prediction, depends only on inputs and history, and must not copy RTL, instantiate the DUT, read DUT outputs or internals, or replay golden data. It must not have include dependencies.

The TB top level is dvbench_top, directly instantiating the single fixed DUT and connecting the same model. The UVM1.2 test name is dvbench_test, and it must include real sequence/driver/monitor components, an independent predictor, an actual/expected scoreboard, a protocol checker, and coverage. sources.f lists one submission-relative .sv/.v path per line in compilation order and must include model/model.sv; it must not contain options, absolute paths, .., wildcards, or RTL. All files must be regular files, with at most 256 files and 16MiB total.

Output mismatches or valid X/Z must report UVM_ERROR/FATAL; when run_test ends normally without errors, output DVBench_COMPLETED exactly once during the report phase. A fixed completion marker must not replace verification; final measurement combines the golden baseline and fixed hidden mutations. Hierarchical snooping, bind, force/release, DPI, file/OS/network access, and submission-supplied compilation scripts or options are prohibited. Only literal includes within the submission and uvm_macros.svh are allowed; only empty header guards and standard UVM macros are allowed, and macro concatenation/custom macros with expansion content are prohibited. These words are legal in ordinary log strings.
