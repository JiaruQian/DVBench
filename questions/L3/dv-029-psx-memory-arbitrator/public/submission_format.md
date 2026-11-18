# Submission Format

All paths are relative to submission. JSON carries the facts in full; Markdown organizes the same content by the same IDs and may be generated from JSON. MD cannot supplement facts omitted from JSON. Mutually exclusive facts under the same conditions, history, and window are treated as one erroneous assertion and the obligations actually affected. Names, counts, and grouping do not determine the semantic score; correct splitting, combining, renaming, and expression across fields are allowed.

The root object of features.json is {"features":[...]}; each entry's feature_id/module/definition/timing/boundary must be nonempty strings; requirement_ids/interface must be nonempty arrays of strings without duplicates. feature_id must be unique; requirement_ids references public R-IDs; interface lists only actually relevant native ports. parent_id is optional and must reference an existing feature without cycles; interface_aliases is optional and must have a basis for the aliases. features.md gives the same references, definition, interface, timing, and boundaries by feature_id.

The root object of testplan.json is {"tests":[...]}; test_id/stimulus/expected/checker must be nonempty strings; feature_ids/requirement_ids must be nonempty arrays without duplicates, referencing current features and public R-IDs. Full A also requires implementation_id/source, pointing to actual submitted code locations. Pure C may omit these two fields. stimulus specifies the legal preparation history, drive times, actual ranges, and boundaries; expected specifies concrete output relationships and latency/valid windows; checker specifies the independent expected-value source, actual/expected, sampling, failure reporting, and non-vacuity conditions. testplan.md gives a semantically consistent plan by test_id. Inferring unapplied stimuli from expected is prohibited.

The following example is a fictitious 3-bit combinational odd-parity module odd_tag, not the answer to this task.

features.md example:
### F-demo
References R-demo-01, module odd_tag; input payload[2:0], output tag. tag makes the overall XOR of the four bits of payload and tag equal to 1; it takes effect combinationally after the input stabilizes; cover 000 and 111 and all other inputs.

features.json example:
```json
{"features":[{"feature_id":"F-demo","requirement_ids":["R-demo-01"],"module":"odd_tag","definition":"tag makes the overall four-bit XOR of payload and tag equal to 1","interface":["payload","tag"],"timing":"Takes effect combinationally after the input stabilizes","boundary":"All 3-bit inputs, including 000 and 111"}]}
```

testplan.md example:
### T-demo
Reference F-demo and R-demo-01; starting with payload=000 stable, iterate through 0..7 at times spaced 2ns apart; sample tag 1ns after each input stabilizes. Expect tag=1 XOR the mathematical parity of the three input bits; compute parity bit by bit using a local integer, perform a four-state comparison of tag, report UVM_ERROR on any mismatch, and require all 8 comparisons to complete.

testplan.json example:
```json
{"tests":[{"test_id":"T-demo","feature_ids":["F-demo"],"requirement_ids":["R-demo-01"],"stimulus":"Starting with payload=000 stable, iterate through 0..7 at 2ns intervals","expected":"1ns after the input stabilizes, tag equals 1 XOR the mathematical parity of the three input bits","checker":"Compute parity bit by bit using a local integer, perform a four-state comparison of tag, report UVM_ERROR on a mismatch, and require all 8 comparisons to complete","implementation_id":"V-demo","source":"tag_pkg.sv:tag_scoreboard.write"}]}
```

model/model.sv must be a self-contained dvbench_model module, consistent with the public native ports, indices, and fixed parameters; predict using only inputs and history. The complete TB must connect the model in that same file, with independently wired expected and actual signals for comparison. sources.f must contain one relative .sv/.v path per line, in compilation order, including model/model.sv; it must not contain the DUT, compilation options, absolute paths, .., or wildcards. UVM1.2; top level dvbench_top; test dvbench_test. Actual transaction/sequence/driver/monitor/env/predictor/scoreboard/checker/coverage must be implemented in the source code.

Access only the DUT's native ports; internal hierarchy, force/release, defparam acceleration, DPI, and file/OS/network probing are prohibited. Finish after completing stimulus and checks and draining in-flight transactions; output DVBench_COMPLETED exactly once only after confirming in the report phase that ERROR/FATAL counts are zero. See debug_contract.json for the feedback contract.
