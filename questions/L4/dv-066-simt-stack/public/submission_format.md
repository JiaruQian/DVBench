# Submission format

Place all deliverables under `/submission`:

```text
flow/features.md
flow/features.json
flow/testplan.md
flow/testplan.json
model/model.sv
sources.f
<your UVM HDL sources>
```

## Feature documents

`features.md` is a readable description of what the design does. Organize it using the same feature IDs as `features.json`, with requirement references, module, native interfaces, behavior, timing and boundaries. `features.json` is the structured representation of the complete same facts. Its root is an object with a nonempty `features` array.

Every feature requires nonempty string fields `feature_id`, `module`, `definition`, `timing`, `boundary`, and nonempty arrays of distinct nonempty strings `requirement_ids` and `interface`. Feature IDs are unique. Requirement IDs come from the published specification; interfaces are native port names. Optional `parent_id` is an existing feature ID or null, without cycles. Facts remain natural language. You choose names, grouping and entry count; reasonable splitting or merging is accepted.

The following pair describes a fictional register, solely to demonstrate format. It is unrelated to this task.

```json
{"features":[{"feature_id":"F-reset","requirement_ids":["R-EXAMPLE-001"],"module":"example_register","definition":"A sampled reset clears data_out and takes priority over update.","interface":["clk","rst","data_out"],"timing":"Active-high rst is sampled on rising clk; observe after the state update settles.","boundary":"Known binary inputs; no promised power-up value before reset."}]}
```

```markdown
## F-reset — Reset
Requirements: R-EXAMPLE-001. Module: example_register.
Interface: clk, rst, data_out.
A sampled reset clears data_out and takes priority over update.
Active-high rst is sampled on rising clk; observe after the state update settles.
Known binary inputs; no promised power-up value before reset.
```

## Testplan documents

`testplan.md` explains how your tests establish the required history, drive inputs and detect incorrect behavior. Use the same test IDs, references and complete facts as `testplan.json`, whose root has a nonempty `tests` array.

Every test requires nonempty strings `test_id`, `stimulus`, `expected`, `checker`, `implementation_id`, `source`, and nonempty arrays of distinct strings `feature_ids` and `requirement_ids`. IDs are unique; references point to your feature IDs and published requirements. `source` and `implementation_id` locate real checks in your submitted HDL. A source path alone does not establish that the described test exists or works.

`stimulus` describes legal preparation, driven values, sequence, timing, variable domains and necessary events. `expected` describes concrete observable relationships and valid timing windows for that stimulus. `checker` states the independent expectation source, actual/expected comparison, sampling and explicit failure condition. Merely claiming full coverage or compliance is insufficient. Put preparation and sampling details in any of these existing fields; no assertion JSON or formal intermediate representation is required.

Here is a corresponding fictional test example, unrelated to this task:

```json
{"tests":[{"test_id":"T-reset","feature_ids":["F-reset"],"requirement_ids":["R-EXAMPLE-001"],"stimulus":"First load data_out with a nonzero value using a legal update. Assert rst before a rising clk and simultaneously request an update with a distinct nonzero input.","expected":"After the rising edge, data_out is zero because reset takes priority.","checker":"Predict zero independently from reset history; after the state update settles compare actual data_out with zero using four-state inequality, and emit UVM_ERROR on mismatch.","implementation_id":"register_scoreboard.check_reset","source":"register_pkg.sv:register_scoreboard.check_reset"}]}
```

```markdown
## T-reset
Features: F-reset. Requirements: R-EXAMPLE-001.
First load data_out with a nonzero value using a legal update. Assert rst before a
rising clk and simultaneously request an update with a distinct nonzero input.
After the rising edge, data_out is zero because reset takes priority.
Predict zero independently from reset history; after the state update settles
compare actual data_out with zero using four-state inequality and emit UVM_ERROR
on mismatch.
Implementation: register_scoreboard.check_reset.
Source: register_pkg.sv:register_scoreboard.check_reset.
```

JSON must carry every critical fact; Markdown may be generated from JSON. The two documents must be semantically consistent, but need not be word-for-word identical. Markdown cannot fill missing JSON facts. Mutually exclusive claims under the same condition and observation window count as an error for the affected obligation; unrelated obligations remain independently assessable. Repeated or renamed facts do not multiply credit.

## Independent model and complete UVM

For this task `model/model.sv` is a self-contained SystemVerilog `dvbench_model` module with the exact complete native simt_stack interface in `ports.md`, no parameters, no UVM dependency, no DUT instance, no actual-output input and no file dependency. Predict from reset, inputs and input history only. Use the identical model file in independent model evaluation and as the UVM scoreboard predictor. Keep actual DUT outputs and model predictions separately connected.

Use top `dvbench_top`, UVM 1.2 and test `dvbench_test`. Implement native-pin stimulus, monitoring, an independent scoreboard, protocol checks, meaningful coverage and normal termination. Mismatches produce UVM_ERROR or UVM_FATAL. Emit `DVBench_COMPLETED` once, after stimulus and checks finish and no UVM_ERROR/UVM_FATAL remains. Coverage alone or a comparison derived from actual output is not an independent checker.

`sources.f` has one submission-relative `.sv` or `.v` path per line, in compilation order, and includes `model/model.sv`. It contains no DUT copy, flags, absolute paths, traversal, wildcard or shell commands. Include files resolve relative to the submission root. The evaluator supplies the hidden RTL and fixed compiler options.

Interact with the DUT through declared native ports only. Do not access DUT internals, force/release, bind hidden hierarchy, use DPI, or probe hidden files, OS or networks. Reading this run's approved debug artifacts through the public client is allowed. See `debug_feedback.md` for the golden-only feedback contract.


## Native model and complete A requirements

For this task the model is a self-contained `dvbench_model` module with the complete simt_stack native interface in ports.md, no parameters, no UVM dependency and no DUT instance or actual-output input. It predicts from input history only. Include `model/model.sv` in `sources.f` and instantiate the identical module in the testbench for separate actual/expected comparison.

Use `dvbench_top`, UVM 1.2 and `dvbench_test`. Drive native inputs, monitor real native outputs, independently compare actual and expected, use UVM_ERROR for mismatches, implement meaningful coverage, and finish normally. Emit `DVBench_COMPLETED` once only after checks and stimulus finish with no UVM_ERROR/UVM_FATAL. No hierarchical DUT access, force/release, DPI, file/OS/network probing or additional DUT sources are allowed. sources.f contains one submission-relative .sv/.v path per line, no flags, absolute paths, traversal or globs.

Feature JSON root is `{"features":[...]}`. Every entry has nonempty string fields `feature_id`, `module`, `definition`, `timing`, `boundary`; nonempty unique string arrays `requirement_ids` and `interface`; optional parent_id must not introduce cycles. Plan JSON root is `{"tests":[...]}`. Every entry has nonempty strings `test_id`, `stimulus`, `expected`, `checker`, `implementation_id`, `source`, and nonempty unique arrays `feature_ids`, `requirement_ids`. IDs are unique. Requirement references use the published R-IDs; feature references point to your features; source points to real submitted implementation. All critical facts must appear in JSON, with semantically consistent Markdown using the same IDs. A contradictory fact in Markdown is an error for the affected obligation; Markdown cannot fill omitted JSON facts. Reasonable semantic splitting/merging/renaming is accepted.
