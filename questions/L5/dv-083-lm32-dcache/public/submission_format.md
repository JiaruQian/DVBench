# Complete A Submission Format

## Files and Runtime Entry Point

Submit the following files at the submission root, together with all self-built UVM HDL referenced by `sources.f`. Relative paths are based at the submission root.

|File|Contents|
|---|---|
|`flow/features.json`|Complete functional facts, native interface, and requirement references|
|`flow/features.md`|Readable description of the same feature IDs, references, and facts|
|`flow/testplan.json`|Preparation, actual stimulus, independent expected values, valid sampling, and potentially failing checks|
|`flow/testplan.md`|Readable description of the same test IDs, references, and methods|
|`model/model.sv`|Single-file self-contained native-interface module `dvbench_model`|
|`sources.f`|List relative .sv/.v paths line by line in dependency order, including the model and real UVM source|

UVM 1.2, top level `dvbench_top`, and test `dvbench_test`. The model shall not depend on UVM, includes, or other submission files, and shall use only reset, inputs, and historical prediction; the scoreboard shall connect to the same model and independently compare actual/expected. The driver drives native ports, the monitor records actually accepted transactions, the checker has actual error-detection conditions, and coverage is recorded separately. After legal completion, transaction draining, objection release, and zero ERROR/FATAL, output `DVBench_COMPLETED` once in the report phase. A completion marker and high coverage cannot substitute for valid checking.

The filelist shall not contain compilation options, absolute paths, parent paths, wildcards, or a DUT copy. Except for `uvm_macros.svh` provided by the tool, includes shall use safe relative paths within the submission. Internal hierarchy, force/release/bind, DPI/VPI, and file/system/network probing are prohibited; debugging artifacts shall be obtained through the public feedback entry point and shall not be added to the submission.

## features.json

The root is an object, and `features` is a nonempty array of objects.

|Field|Type and constraints|
|---|---|
|`feature_id`|Nonempty string, unique throughout; the name is selected by the candidate|
|`requirement_ids`|Nonempty, nonduplicated string array, referencing R-ID in the public spec|
|`module`|Nonempty string describing the behavioral object|
|`definition`|Nonempty string fully expressing the conditions, input domain, and observable behavior|
|`interface`|Nonempty, nonduplicated string array listing only the native ports actually relevant to this item|
|`timing`|Nonempty string describing events, latency, and the valid sampling window|
|`boundary`|Nonempty string describing boundaries, retention, exceptions, and applicable domain|
|`parent_id`|Optional string or null; references defined feature_id and must not form cycles|

Reasonable splitting, merging, renaming, and local fact joining are allowed; correctness cannot be replaced by the number of items, naming, or formatting identical to the reference. R-ID is for traceability and cannot replace a behavioral description. Optional aliases must have a basis in the public contract.

## testplan.json

The root is an object, and `tests` is a nonempty array of objects.

|Field|Type and constraints|
|---|---|
|`test_id`|Nonempty string, unique throughout|
|`feature_ids`|Nonempty, nonduplicated string array, referencing the candidate's own features|
|`requirement_ids`|Nonempty, nonduplicated string array, referencing public R-ID|
|`stimulus`|Nonempty string describing the legal prior state, preparation history, drive timing, input sequence, and actual test domain|
|`expected`|Nonempty string giving the independent expected relationship, latency, and valid window|
|`checker`|Nonempty string describing the source, sampling, actual/expected comparison, mismatch error, and anti-vacuity condition for the independent expectation|
|`implementation_id`|Nonempty string locating the check point in the real implementation|
|`source`|Nonempty string locating the actual HDL file and class/method/check point within the submission|

Preparation and sampling may be written into stimulus, expected, or checker; do not add fixed fields or assertions.json. Randomized or repeated tests shall specify variables, ranges, constraints, and required events; “randomly cover everything” and “conform to the specification” cannot replace a concrete method. R→F→T→implementation may be many-to-many; the existence of a path does not prove that checking has been implemented. Expected values must not be generated from the DUT's current actual output and then compared with itself.

## Markdown and JSON

Markdown shall present the same requirements, interfaces, facts, and methods under the same IDs, and may use paragraphs, lists, or tables, or be generated from JSON. JSON is the complete fact carrier; Markdown cannot supplement omissions in JSON; the two do not have to be verbatim identical. Under the same conditions, history, and window, mutually exclusive facts shall be handled as deduplicated erroneous claims and the actually affected obligations, rather than automatically zeroing unrelated items. Format, reference, and file checks do not prove semantic correctness; no deterministic, general cross-document semantic-consistency guarantee exists.

## Paired Examples Not for This Problem

The following demonstrates format only; the fictional module `ExampleGate`, ports, R-ID, and files are unrelated to this problem, must not be copied as an answer, and do not prescribe this problem's feature count, grouping, or test strategy. Assume it executes on the rising edge of clk with synchronous active-high reset, reset has priority over enable, and it outputs one stored bit; it is 0 during reset, samples data when enable is asserted, and otherwise holds its value.

features.json：

```json
{"features":[{"feature_id":"F-reset","requirement_ids":["R-example-reset"],"module":"ExampleGate","definition":"On the rising edge of clk when reset=1, q is cleared, with reset taking priority even when enable=1 and data=1.","interface":["clk","reset","enable","data","q"],"timing":"Sample reset on the rising edge and observe q in the stable window after the edge; a short reset between edges does not update q.","boundary":"Check the distinction between reset and enable being asserted simultaneously and a short pulse occurring only between edges.","parent_id":null}]}
```

features.md：

```markdown
# ExampleGate Functional Description
## F-reset
Requirement: R-example-reset; interface: clk, reset, enable, data, q.
On the rising edge of clk when reset=1, q is cleared, taking priority over simultaneously asserted enable and data=1.
Observe in the stable window after the edge; a short reset between edges does not update q, and these two histories must be distinguished.
```

testplan.json：

```json
{"tests":[{"test_id":"T-reset","feature_ids":["F-reset"],"requirement_ids":["R-example-reset"],"stimulus":"First, establish q=1 on one rising edge with reset=0, enable=1, and data=1; on the next falling edge, drive reset=1, enable=1, and data=1 and hold them until the next rising edge. Separately, starting from q=1, pulse reset only between two adjacent rising edges and deassert it before the next rising edge.","expected":"In the first segment, q=0 after the reset sampling edge; in the second segment, q remains 1 during the between-edge pulse and before the next edge.","checker":"The input-history predictor samples q in the stable window after the reset edge in the first segment and during the pulse/before the next edge in the second segment, using four-state comparison against the independent expectation; report UVM_ERROR on mismatch, and the check count in each segment must be nonzero.","implementation_id":"V-reset","source":"tb/example_pkg.sv:example_scoreboard.check_reset"}]}
```

testplan.md：

```markdown
# ExampleGate Test Plan
## T-reset
Feature: F-reset; requirement: R-example-reset.
First establish q=1 on a rising edge with reset=0, enable=1, and data=1, then drive reset=1, enable=1, and data=1 on the falling edge and hold them across the next rising edge; sampling after the edge in the stable window shall yield 0.
Separately, starting from q=1, generate and deassert a reset pulse only between two rising edges; q shall remain 1 during the pulse and before the next edge.
The input-history predictor independently provides the expected value, uses four-state comparison, reports UVM_ERROR on mismatch, and has a nonzero check count for each of the two segments.
Implementation: V-reset, tb/example_pkg.sv:example_scoreboard.check_reset.
```

## Evaluation of the Same A Submission

B reads the candidate feature; C reads the candidate's own feature and plan and uses the public obligations as the fixed denominator; D uses the candidate `model/model.sv`; E uses the same model, plan, and candidate UVM/filelist. The candidate does not receive the maintenance-side correct feature, plan, model, or hidden mutations. The debug entry point, actual feedback capability, and budget for this version are specified by `debug_feedback.md` and `../submission_contract.json`.
The complete TB must retain both native instances, sets=512 and sets=64, with independent input histories; all other parameters are fixed at their default values. The same parameterized model/model.sv is used in the scoreboard and D. Both configurations may be compiled in one sources.f; separate directories are not required.
