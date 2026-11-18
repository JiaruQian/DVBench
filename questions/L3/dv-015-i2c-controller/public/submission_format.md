# A Submission Format

# Submission Format

A complete A submission includes flow/features.md, flow/features.json, flow/testplan.md, flow/testplan.json, model/model.sv, sources.f, and UVM source code. The model must be a self-contained dvbench_model module, with native ports/fixed parameters matching ports.md; the same file is used for D and TB prediction, and expected comes only from inputs and history. The A top level is dvbench_top, the UVM test is dvbench_test, and the UVM version is UVM1.2. sources.f contains one relative .sv/.v path per line in compilation order, includes model/model.sv, and contains no options, wildcards, DUT copies, absolute paths, or ...

The root of features.json is an object, and features is a nonempty array. In each entry, feature_id/module/definition/timing/boundary are nonempty strings, and requirement_ids/interface are nonempty arrays of nonduplicate strings. feature_id is unique, requirement_ids references this spec, and interface references native ports; the optional parent_id is an existing ID or null, and cycles are not allowed. Reasonable splitting and merging, partial port sets, and different groupings are allowed; scoring is not based on names or entry counts.

The root of testplan.json is an object, and tests is a nonempty array. In each entry, test_id/stimulus/expected/checker are nonempty strings, and feature_ids/requirement_ids are nonempty arrays of nonduplicate references. A additionally provides nonempty implementation_id/source, with source pointing to an actual submitted file/class/method. Pure C does not require an HDL location. stimulus must state the legal preparatory history, actual drive domain, and operations; expected must state concrete independent relationships; checker must state valid sampling, actual/expected comparison, triggering, and error reporting, and must not generate expectations from DUT outputs. Sampling information may be placed in any semantic field.

MD is divided into sections using the same IDs, fully expresses the same facts and references, and may be generated from JSON. JSON is the primary carrier for field validation/semantic evidence and must fully contain the facts; MD cannot supplement facts omitted from JSON. Mutually exclusive statements in the two formats under the same conditions/window are treated as one local error, with evidence from both retained, without automatically zeroing unrelated obligations. Correct formatting does not prove correct content.

The following paired examples come from the fictional module lamp_latch and must not be copied as the answer to this task.

```json
{"features":[{"feature_id":"F-L","requirement_ids":["R-example-1"],"module":"lamp_latch","definition":"When enable is 1, capture the lamp input d on the rising edge of clk; otherwise retain q.","interface":["clk","enable","d","q"],"timing":"Sample on the rising edge; q is valid after the edge.","boundary":"Hold when enable=0; inputs are two-state."}]}
```

## F-L
Requirement R-example-1; module lamp_latch; interface clk, enable, d, q. When enable is 1, capture d on the rising edge; otherwise retain q. q is valid after the edge, and inputs are two-state.

```json
{"tests":[{"test_id":"T-L","feature_ids":["F-L"],"requirement_ids":["R-example-1"],"stimulus":"First set enable=1,d=0 on a falling edge and pass through a rising edge to establish q=0; then set d=1 on a falling edge and pass through a rising edge; finally set enable=0,d=0 and pass through another rising edge.","expected":"q after the three edges is 0, 1, and 1, respectively.","checker":"Build an independent capture/hold model from the drive history. After each edge, when stable, compare actual q with the prediction using case equality; report UVM_ERROR on a mismatch. Confirm that all three comparisons are triggered.","implementation_id":"V-L","source":"lamp_pkg.sv:lamp_scoreboard.write"}]}
```

## T-L
Associated with F-L and R-example-1. First legally capture 0, then capture 1, then disable updates and supply 0; the expected values after the edges are 0, 1, and 1. Predict independently from input history and perform four-state comparisons, report errors on mismatches, and check that all three checks are non-vacuous; A implementation location lamp_pkg.sv:lamp_scoreboard.write, V-L.

For completion, output DVBench_COMPLETED once after legal stimulus has completed, in-flight observations have drained, and UVM_ERROR/FATAL are both 0; the checker uses UVM_ERROR/FATAL. Interaction is limited to public native ports; internal hierarchy, force/release, DPI, and file/network/OS probing are prohibited. The maintenance service provides, when configured, compilation logs, simulation logs, and waveforms of only public ports/candidate signals under fixed seeds/budgets; interface failures must include reasons, and access to DUT internals and hidden evaluation is prohibited. Read `debug_feedback.md` for the fixed golden feedback interface and budgets.
