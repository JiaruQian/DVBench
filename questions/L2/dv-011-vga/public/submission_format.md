# Submission format

Place all candidate deliverables below `submission/`:

```text
submission/
├── flow/features.md
├── flow/features.json
├── flow/testplan.md
├── flow/testplan.json
├── model/model.sv
├── sources.f
└── <UVM .sv/.svh/.v/.vh sources>
```

## Feature list: Two Deliverables for the Same Content

Extract the functionality that needs to be verified for this task from the public spec and RTL, and write it into `flow/features.md` and
`flow/features.json`. Each feature should describe its behavior, related requirements, owning module, involved ports,
timing/observation conditions, and applicable boundaries. Do not merely list feature names or test steps; test stimulus and checker
design belong in the testplan. You determine the number, names, and grouping of features; one R-ID is not required to correspond to
one feature, nor are you required to use the reference answer's numbering.

### `flow/features.md`: Human-Readable Functional Description

Use Markdown with sections organized by feature, with headings containing the same `feature_id` as in the JSON, optionally accompanied by a Chinese or
English feature name. Each section should describe the corresponding R-ID, module, ports, behavioral definition, timing, and boundaries. You may use
paragraphs, lists, or tables, with no restriction on organization; readers should be able to understand the complete feature list without relying on the JSON.

### `flow/features.json`: Structured Representation for Programmatic Parsing and Referencing

Submit valid JSON whose root object contains a nonempty `features` array. The required fields for each entry are as follows:

| Field | Type | Content Requirements |
|---|---|---|
| `feature_id` | Nonempty string | A custom unique ID for reference by Markdown and the testplan; not a grading answer number |
| `requirement_ids` | Nonempty array of strings | The public R-ID involved in this feature, without duplicates and without IDs that do not exist in the spec |
| `module` | Nonempty string | The owning DUT module or a logical functional module supported by evidence |
| `definition` | Nonempty string | A natural-language description of the feature's input conditions, behavior, and output relationships |
| `interface` | Nonempty array of strings | The actual native port names involved, without duplicates or invented ports |
| `timing` | Nonempty string | Relevant clocks/edges, update or sampling times, and latency/settling conditions; explicitly state when there are no additional timing requirements |
| `boundary` | Nonempty string | Legal ranges, boundary conditions, state preparation, and undefined ranges or ranges not required to be covered |

The optional `parent_id` is the parent feature's ID or `null`; omission indicates no parent node. References must exist,
and the hierarchy must not contain cycles. The text fields above are still natural language; formulas, executable assertions, or RTL code are not required.

The following is a format example for a **fictional register module**, not the answer to this task. The actual IDs, ports, and behavior must be derived from
this task's public spec/RTL; do not copy the example values:

```json
{
  "features": [
    {
      "feature_id": "F-reset",
      "requirement_ids": ["R-EXAMPLE-001"],
      "module": "example_register",
      "definition": "When reset is sampled, clear data_out to zero; reset takes priority over update requests.",
      "interface": ["clk", "rst", "data_out"],
      "timing": "Sample active-high rst on the rising edge of clk, and observe outputs after the state update and combinational settling.",
      "boundary": "Inputs use stable 0/1 levels; power-up values without reset are not guaranteed."
    }
  ]
}
```

The corresponding Markdown may be written as:

```markdown
## F-reset — Reset Function
- Requirements: R-EXAMPLE-001
- Module: example_register
- Ports: clk, rst, data_out
- Behavior: When reset is sampled, clear data_out to zero; reset takes priority over update requests.
- Timing: Sample active-high rst on the rising edge of clk, and observe outputs after the state update and combinational settling.
- Boundaries: Inputs use stable 0/1 levels; power-up values without reset are not guaranteed.
```

### Consistency Between the Two Files and Their Use in Evaluation

The two files express the same set of features, use the same IDs, requirement associations, modules, and ports, and maintain consistency in behavior,
timing, and boundaries; identical wording is not required. Generating Markdown from JSON is allowed, but the MD must not
add behavioral claims that appear only in the MD, or retain necessary facts only in the MD while omitting them from the JSON.

JSON is the primary vehicle for field checks, evidence references, and semantic scoring; MD is for human reading and serves as material for semantic cross-checking,
and both files will be submitted for semantic review. Write the complete facts into the corresponding text fields in the JSON; do not
rely on Markdown to complete an incomplete JSON. Content correctness is judged by the complete semantics; reasonable splitting,
merging, or different naming does not affect semantic evaluation; do not replace key behaviors with placeholder descriptions lacking concrete content.

## Testplan: Two Deliverables for the Same Natural-Language Plan

The feature description explains “what to verify”; the testplan explains “how to trigger and distinguish these behaviors,” and the subsequent HDL implementation
is responsible for realizing the plan as stimulus, prediction, and comparison. The plan should tell implementers how to repeat the tests, when to observe, and what
results constitute failure; merely listing feature names or repeating the specification is insufficient to express the test method.

### File Responsibilities and Fields

`flow/testplan.md` is for human reading, with sections organized by the same `test_id` as in the JSON, presenting requirements and feature
references, preparation and stimulus, expectations, checks, and where the complete A is implemented. Paragraphs, tables, or lists may be used for organization.
`flow/testplan.json` is for programmatic reference validation, locating original textual evidence, and review; the root object's `tests` must be
a nonempty array of objects. Each entry contains:

| Field | Type | Content and Depth |
|---|---|---|
| `test_id` | Nonempty string | Custom and globally unique within this plan; a locator identifier, not a reference-answer number |
| `feature_ids` | Nonempty array of strings | References delivered feature IDs, without duplicates; atomic C references the features given in the problem |
| `requirement_ids` | Nonempty array of strings | References R-ID present in the public spec, without duplicates |
| `stimulus` | Nonempty natural-language string | Legal setup history/prior state, actual inputs, drive times, operation order, domain under test, and boundaries; provide ranges and constraints when repetition or randomization is needed |
| `expected` | Nonempty natural-language string | Specific output relationships, state changes, latencies or validity windows corresponding to the above stimulus, and behaviors that must not occur |
| `checker` | Nonempty natural-language string | Independent source of expectations, which actual outputs to compare, when to sample, how to report mismatches, and how to confirm that the checks actually trigger |
| `implementation_id` | Required for complete A, nonempty string | Custom V identifier locating an actually implemented checkpoint; not required for purely atomic C |
| `source` | Required for complete A, nonempty string | Actual HDL file and class/method/assertion location within the submission, e.g. `register_tb.sv:check_reset`; not required for purely atomic C |

Setup, drive, and sampling information may be written in the existing three natural-language fields; no separate mandatory `setup`,
`sampling` fields are imposed, and formulas, formal IR, or `assertions.json` are not required.

### Write in enough detail to implement and detect failures

First explain how to reach the required prior state through legal inputs, then explain the input sequence actually executed; “cover everything”
cannot replace actual ranges, boundaries, or operations. “Random testing” should specify the random variables, constraints, repetition range, and events that must
be observed. A local test may test only a subset, and multiple tests may jointly complete the same requirement;
names, counts, splitting/merging, and test organization are up to you; each test need not cover all behavior.

Expectations must correspond to the actual stimulus and observation windows. Without specific relationships and
comparison methods, “conforms to the specification” or “check according to the formula” does not reveal what was checked. A full-domain expected also cannot prove that the full domain was actually traversed.
Expectations may come from an independent model driven by input history, independent constants, or discriminating relational properties; the DUT's
actual output for the same behavior must not be used directly as expected without independent validation. The checker should also explain how its triggering conditions
are satisfied by actual stimulus, avoiding conditions that never trigger, coverage-only collection, or checks that always pass.

### R → F → T → V and consistency between the two files

R is a public requirement, F is a feature distilled by the candidate, T is a test in this plan, and V is the location implementing the check in complete A.
References provide traceability, and many-to-many associations are allowed; merely entering paths or numbers cannot replace test content. The existence of `source`
also does not indicate that code has been executed or reviewed; actual HDL and execution evidence are checked separately.

MD/JSON use the same set of test IDs and the same requirement/feature references, fully expressing the same plan; they need not
match word for word, and MD may be generated from JSON. JSON must carry all facts completely; key setup,
stimulus, expectations, or checks must not be completed only in MD. JSON is the primary carrier of fields and evidence, and both files will undergo semantic review; cross-file
contradictions will affect the review. Passing format and reference validation does not imply semantic correctness, and a written plan does not imply completed HDL.

### Corresponding example: a fictional register

The following reuses `F-reset`/`R-EXAMPLE-001` from the fictional module above and is **not an answer to this problem or a recommended grouping**.
Assume that this example register supports synchronous reset and writes, with inputs clk/rst/write_en/data_in and output data_out.
It demonstrates only one local reset test and does not claim to verify the entire fictional module:

```json
{
  "tests": [
    {
      "test_id": "T-reset",
      "feature_ids": ["F-reset"],
      "requirement_ids": ["R-EXAMPLE-001"],
      "stimulus": "Inputs are stable 0/1. First hold rst=1 across one clk rising edge to establish the state, then hold rst=0, write_en=1, and data_in=8'h35 across one rising edge, then stop writing and check that the write has completed. At the next falling edge, establish rst=1 and write_en=0, and hold them across two rising edges; keep inputs stable before each sampling edge.",
      "expected": "After the setup write completes, data_out=8'h35; at the subsequent two rising edges that sample reset, data_out is 0 after the state update and combinational settling.",
      "checker": "Compare the setup write and reset results against independent constants 8'h35 and 0, respectively; expectations must not be generated from data_out. Wait 1ns after each target rising edge before sampling (the example clock period is 10ns), and compare data_out using four-state inequality; report UVM_ERROR on any mismatch. Record one write check and two reset checks separately; if the counts are insufficient, report an error and then terminate; this local test does not claim to cover priority when reset and write are asserted simultaneously.",
      "implementation_id": "V-reset",
      "source": "register_tb.sv:check_reset"
    }
  ]
}
```

The corresponding Markdown expresses the same facts:

```markdown
## T-reset — Synchronous reset after a nonzero prior state
- Feature: F-reset; requirement: R-EXAMPLE-001
- Stimulus: Inputs are stable 0/1; first hold rst=1 across one clk rising edge, then rst=0, write_en=1,
  data_in=8'h35 across one rising edge, then stop writing and check that the write has completed. At the next falling edge, establish
  rst=1 and write_en=0, and hold them across two rising edges; keep inputs stable before each sampling edge.
- Expected: After the setup write completes, data_out=8'h35; after the updates and combinational settling at both reset sampling edges, it is 0.
- Check: Expectations are independent constants 8'h35 and 0, not generated from data_out; the example clock period is 10ns,
  wait 1ns after the target rising edge, compare using four-state inequality, and report UVM_ERROR on a mismatch. One write
  check and two reset checks must be completed; if the counts are insufficient, report an error and then terminate. This local test does not cover priority when reset/write are asserted simultaneously.
- Implementation: V-reset; register_tb.sv:check_reset
```

## HDL and simulation deliverables

`sources.f` contains one relative HDL path per line, in compile order. It has
no options, comments, wildcards, absolute paths, `..`, DUT copies, scripts or
generated file names. The fixed RTL is supplied by the evaluator. The required
top is `dvbench_top`, and the required UVM test is `dvbench_test`.

The model must define a self-contained `dvbench_model` and must not instantiate
the DUT, read DUT outputs, access hierarchy, use `force/release`, or inspect
files, processes, networks, seeds or evaluation assets. The UVM environment must
drive and monitor DUT ports, compare independent predictions, report errors with
`UVM_ERROR`/`UVM_FATAL`, and emit one `DVBench_COMPLETED` only after checks and
objections are complete. The evaluator chooses seeds and the RTL variant.


model/model.sv must define a self-contained SystemVerilog module `dvbench_model`; its port names, directions, bit widths, index directions, and fixed parameters must match the public native interface for this task. The same file is used for independent D evaluation and must also actually be connected to the candidate TB scoreboard to generate predictions. Providing only a class/package/function does not meet the requirement; expected must be generated only from reset, inputs, and their history, and must not be generated by reading DUT actual.


# Submission format

Place all candidate deliverables below `submission/` using the paths listed in the task.

`flow/features.json` is the complete machine-readable feature document. Its root is an object with a non-empty `features` array. Each feature object must contain non-empty strings `feature_id`, `module`, `definition`, `timing`, and `boundary`, plus non-empty arrays `requirement_ids` and `interface` of unique strings. Requirement IDs must be public R-IDs and interface names must be the native DUT ports. `features.md` is the readable rendering of the same facts; it must use the same feature IDs and cannot contradict JSON. A feature may cover multiple requirements and a requirement may be covered jointly by multiple features.

`flow/testplan.json` is the complete machine-readable plan. Its root is an object with a non-empty `tests` array. Each test object must contain a unique `test_id`, non-empty unique arrays `feature_ids` and `requirement_ids`, and non-empty strings `stimulus`, `expected`, and `checker`. `feature_ids` must reference your own feature IDs and `requirement_ids` must reference public R-IDs. `stimulus` must state reachable preparation history, driven inputs and boundaries; `expected` must state concrete output/state relationships and valid sampling windows; `checker` must compare an independent expected relation and report failures. `testplan.md` is the readable rendering of the same tests and cannot contradict JSON.

For this complete A submission, each test also needs non-empty `implementation_id` and `source` strings locating its actual HDL implementation. `features.md` uses the same feature IDs and explains requirement, module, ports, definition, timing and boundary. `testplan.md` uses the same test IDs and explains the same references, stimulus, expected, checker and implementation locations. JSON must contain the full facts; Markdown may be generated from it. Field/reference validation and semantic review are separate; no exact grouping or number of features/tests is prescribed.

The following paired examples describe a fictional acknowledgment unit, not this task. Do not copy the example requirements, ports or test strategy into your answer.

```json
{"features":[{"feature_id":"F-ack","requirement_ids":["R-EXAMPLE-001"],"module":"ack_unit","definition":"With reset low, ack registers the request sampled at the rising edge.","interface":["clk","reset","request","ack"],"timing":"Compare after the rising-edge update settles.","boundary":"Active-high synchronous reset overrides request and clears ack."}]}
```

Corresponding `features.md`:

### F-ack

Requirement: R-EXAMPLE-001. Module: ack_unit. Ports: clk, reset, request, ack.
With reset low, ack registers request at a rising edge and is compared after the update settles. Active-high synchronous reset overrides request and clears ack.

```json
{"tests":[{"test_id":"T-ack","feature_ids":["F-ack"],"requirement_ids":["R-EXAMPLE-001"],"stimulus":"Hold reset high across two rising edges with request=1. Deassert reset on a falling edge, then drive request=0,1,0 on successive falling edges.","expected":"ack is zero on the reset edges, then equals each request sampled at the following rising edge after settling.","checker":"An independent predictor uses only reset and request history. A monitor compares ack after each rising-edge update, increments a comparison count and issues UVM_ERROR on mismatch; require all five comparisons.","implementation_id":"ack_scoreboard.check_sample","source":"tb/ack_scoreboard.sv"}]}
```

Corresponding `testplan.md`:

### T-ack

References: F-ack, R-EXAMPLE-001. Hold reset high for two rising edges with request=1; deassert on a falling edge and drive 0,1,0 at successive falling edges. Expect ack=0 on reset edges, then the request sampled at each following rising edge. After settling, an independent predictor based on input history compares ack, counts five required checks, and raises UVM_ERROR on mismatch. Implementation: ack_scoreboard.check_sample in tb/ack_scoreboard.sv.

The evaluator scores meaning and accepts reasonable names, splitting, merging, and ordering.

`model/model.sv` must define the self-contained SystemVerilog module `dvbench_model` with the native DUT port names, directions, widths, index directions and fixed parameter values. The same file is evaluated independently in D and must actually provide predictions to the candidate TB scoreboard. A class, package or function alone is insufficient. Expected values must depend only on reset, inputs and their history, never DUT actual outputs.

`sources.f` must include `model/model.sv` and candidate HDL in compile order, one canonical relative path per line, without options, wildcards, absolute paths, `..` or DUT copies. Define `dvbench_top` and register UVM 1.2 test `dvbench_test`. Compare actual and independent expected values, use `UVM_ERROR`/`UVM_FATAL` on failures, and emit `DVBench_COMPLETED` once only after checks, draining and objections finish without errors. Interact through DUT ports only; hierarchy access, force/release, DPI, filesystem, OS and network probes are forbidden.

