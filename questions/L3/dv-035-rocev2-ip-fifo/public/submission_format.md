# Submission Format

A submits flow/features.md, flow/features.json, flow/testplan.md, flow/testplan.json, model/model.sv, sources.f, and complete UVM source code. Top level dvbench_top, test dvbench_test, UVM1.2.
B submits only the two feature documents; C submits only the two testplan documents and uses the fixed given feature; D submits only a self-contained model/model.sv; E uses the fixed given feature, plan, and model to construct complete UVM and sources.f.

The features.json root object contains a nonempty features array. Each feature_id/module/definition/timing/boundary is a nonempty string, and requirement_ids/interface are nonempty arrays of nonduplicate strings; R-ID references this task's specification, and interface uses native port names. feature_id is unique. The optional parent_id references an existing feature or null and must not form cycles.
The actual filename for tests.json is testplan.json, whose root object contains a nonempty tests array. Each test_id/stimulus/expected/checker is a nonempty string; feature_ids/requirement_ids are nonempty arrays of nonduplicate strings. IDs are unique and reference given or submitted features and public R-IDs. A additionally requires nonempty implementation_id and source strings locating actual checking code; C does not require implementation locations.
stimulus describes legal setup history, actual driving domains/boundaries, and ordering; expected describes independent expectations, timing relationships, and valid domains; checker describes independent sources, valid sampling, non-vacuous comparisons, and error determination. Facts may be expressed jointly across fields. Names, counts, splitting, and merging do not determine correctness.
Organize Markdown into sections by the same IDs, fully expressing the same facts as the JSON in natural language; JSON is the complete carrier of facts, and MD cannot supplement omissions in JSON. Mutually exclusive facts under the same conditions, history, and window are treated as one error and the obligations actually affected, without automatically assigning zero to the entire submission.
model/model.sv must define a self-contained dvbench_model module, with port names/directions/widths/indices consistent with this task's contract; parameters must follow the publicly specified fixed values. It must not depend on other files, UVM, or DUT source code, and must not read actual DUT outputs as expectations. The same model must be connected into the complete TB for independent prediction and the scoreboard.
sources.f contains one submission-relative .v/.sv path per line in dependency order, including model/model.sv; compilation options, absolute paths, .., wildcards, or DUT copies are not allowed. Interact only through native DUT ports; internal hierarchy, force/release, DPI, file probing, or OS probing are prohibited.
At completion, drain in-flight transactions and drop objections; in report_phase, confirm that UVM_ERROR/UVM_FATAL are both zero before outputting DVBench_COMPLETED once. Use UVM_ERROR/UVM_FATAL for errors; it must not always pass.

## Fictional Example (a Different Design; Do Not Copy for This Task)

features.json:
{"features":[{"feature_id":"F-demo","requirement_ids":["R-demo"],"module":"toy_mux","definition":"Select a when sel is 0; otherwise select b.","interface":["sel","a","b","y"],"timing":"Valid after combinational settling.","boundary":"a/b are both 4-bit, and sel is two-state."}]}

features.md:
### F-demo
Associated with R-demo, logical module toy_mux, ports sel/a/b/y. When sel is 0, y=a; otherwise y=b; valid after combinational settling, with a/b being 4-bit and sel two-state.

testplan.json:
{"tests":[{"test_id":"T-demo","feature_ids":["F-demo"],"requirement_ids":["R-demo"],"stimulus":"The combinational module has no prior state; iterate over sel=0/1 and a/b=0 through 15, waiting 1ns after each change.","expected":"When sel0, y=a; when sel1, y=b.","checker":"Independently select the expectation using input values, perform a four-state comparison of y 1ns after driving, and report an error on inequality; require completion of 512 comparisons."}]}

testplan.md:
### T-demo
References F-demo/R-demo. With no prior state, iterate over both sel values and all combinations of a/b from 0 through 15, wait 1ns, and perform a four-state comparison of y against the value independently selected from the inputs; report an error on a mismatch, and require completion of 512 points.
