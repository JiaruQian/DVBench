# Submission Format

The features.json root object contains a nonempty features array. Each item's feature_id/module/definition/timing/boundary must be nonempty strings; requirement_ids/interface must be nonempty arrays of nonduplicate strings. feature_id must be unique, R-ID must come from this problem's spec, and interfaces must use native ports. Optional parent_id references an existing feature or is null, without cycles. Reasonable splitting, merging, renaming, reordering, and expression across fields based on content are allowed; names or counts do not determine correctness.

The testplan.json root object contains a nonempty tests array. Each test_id must be a unique nonempty string; feature_ids/requirement_ids must be nonempty arrays of nonduplicate strings with valid references. stimulus/expected/checker must be nonempty strings: they must describe legal preparation, the actual input domain and driving, independent expectations, valid sampling, comparison failures, and non-vacuous checks. Complete A additionally requires nonempty implementation_id/source strings pointing to actual implementation checkpoints; pure C may omit them. JSON carries all facts in full; MD cannot fill omissions. MD must be sectioned by the same IDs and be semantically consistent; mutually exclusive facts under the same condition window are treated as one error affecting local obligations, without zeroing unrelated content.

model/model.sv defines a self-contained dvbench_model, with the same file used for D and TB prediction; sources.f lists all HDL relative paths one per line in compilation order and must include model/model.sv. The UVM top level is dvbench_top, and the test is dvbench_test.

The following is only a format example for another fictional module, invert_demo, not an answer to this problem.

```json
{"features":[{"feature_id":"F-demo","requirement_ids":["R-demo-001"],"module":"invert_demo","definition":"Output y is the bitwise inversion of input x","interface":["x","y"],"timing":"Takes effect after combinational propagation","boundary":"x is a 1-bit two-state input"}]}
```

### F-demo

R-demo-001; invert_demo; ports x/y. Output y is the inversion of x, valid after combinational settling, with a domain of 1-bit two-state inputs.

```json
{"tests":[{"test_id":"T-demo","feature_ids":["F-demo"],"requirement_ids":["R-demo-001"],"stimulus":"No prior state; drive x=0 and 1 in sequence, holding each for 10ns","expected":"y is 1 and 0 respectively, valid after combinational settling","checker":"Sample from public ports 2ns after driving, independently compute the expectation by inverting the input, perform a four-state comparison, and report UVM_ERROR on mismatch; verify that the comparison count is 2","implementation_id":"V-demo","source":"demo.sv:demo_scoreboard.write"}]}
```

### T-demo

Associated with F-demo/R-demo-001; no prior state; drive x=0 and 1 in sequence, holding each for 10ns. Sample y 2ns after driving, obtain 1 and 0 by inverting the input, perform a four-state comparison against actual, report UVM_ERROR on mismatch, and confirm 2 checks. Implementation V-demo is located at demo.sv:demo_scoreboard.write.

## HDL Input Restrictions

Each line of sources.f lists only a .v/.sv compilation unit; submit .vh/.svh headers as owned include files, without listing them in the filelist. Includes must use literal relative paths; only uvm_macros.svh is permitted externally; model/model.sv must not use include. See validation_policy.json for other system task/function, macro, and path restrictions, which are identical to those of the actual submission validator. A/E must submit all referenced source files; DUT internal hierarchy, bind/force/release, DPI, OS/file access, and fixed RTL copies are prohibited.
