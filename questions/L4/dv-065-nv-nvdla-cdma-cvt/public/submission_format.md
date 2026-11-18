# Submission format

Submit `flow/features.md`, `flow/features.json`, `flow/testplan.md`, `flow/testplan.json`, `model/model.sv`, `sources.f`, and the UVM HDL needed to run your verification. All paths are relative to the submission directory.

## Features

Features explain what behavior must be verified. Markdown is a complete human-readable description, organized with the same feature IDs used in JSON. JSON is the structured representation used for validation, references, evidence, and semantic review. Both contain the complete same facts; neither is a supplement for omissions in the other. You may generate Markdown from JSON. Feature names, counts, and reasonable splitting or merging are your choice.

The JSON root contains a nonempty `features` array. Each object has these fields:

| Field | Type and meaning |
| --- | --- |
| feature_id | Unique nonempty string |
| requirement_ids | Nonempty array of distinct public specification R-IDs |
| module | Nonempty module or supported logical function name |
| definition | Nonempty natural language describing conditions and observable behavior |
| interface | Nonempty array of distinct native port names |
| timing | Nonempty natural language describing edges, latency, sampling and stability |
| boundary | Nonempty natural language describing legal ranges, preparation and undefined behavior |

Optional `parent_id` is an existing feature ID or null; parent relations must not form a cycle. No executable assertion, formula language, or extra intermediate representation is required.

The following paired example concerns an unrelated fictional register and is not an answer for this task.

```json
{"features":[{"feature_id":"F-example","requirement_ids":["R-EXAMPLE-001"],"module":"example_register","definition":"A sampled active-high reset clears data_out and takes priority over writes.","interface":["clk","rst","data_out"],"timing":"Reset is sampled on the rising clock edge; observe after state updates settle.","boundary":"Drive stable binary inputs. No initial power-up value is promised."}]}
```

```markdown
## F-example
Requirement: R-EXAMPLE-001. Module: example_register. Ports: clk, rst, data_out.
A sampled active-high reset clears data_out and takes priority over writes.
Reset is sampled on the rising clock edge; observe after state updates settle.
Drive stable binary inputs. No initial power-up value is promised.
```

## Testplan

The plan explains how to reach a legal state, drive an actual test domain, and decide whether observations are correct. HDL then implements those checks. Markdown presents each test with the same test ID, feature and requirement references, and complete plan as JSON. The JSON root contains a nonempty `tests` array:

| Field | Type and meaning |
| --- | --- |
| test_id | Unique nonempty string |
| feature_ids | Nonempty array of distinct existing feature IDs |
| requirement_ids | Nonempty array of distinct public R-IDs |
| stimulus | Nonempty natural language giving legal preparation, input values, driving times, order and tested range or boundaries |
| expected | Nonempty natural language giving concrete corresponding output relations, latency and validity windows |
| checker | Nonempty natural language giving independent expected-value source, actual/expected comparisons, sampling, mismatch reporting and evidence of activation |
| implementation_id | Nonempty locator for a real implemented check |
| source | Nonempty submission-relative locator for the HDL implementing that check |

Preparation and sampling may be described in any of the existing text fields. A broad expected statement does not prove a broad stimulus domain was actually exercised. Random tests describe variables, constraints, range and required events. A file path alone is not an implementation or execution receipt. Multiple tests may jointly cover a requirement; references may be many-to-many. Do not derive an unchecked expected value by copying the same DUT output being checked.

Here is a paired local test example for the same fictional register, which also has write_en and data_in. It illustrates format and is not a complete testplan for that fictional module.

```json
{"tests":[{"test_id":"T-example","feature_ids":["F-example"],"requirement_ids":["R-EXAMPLE-001"],"stimulus":"With a 10ns clock and stable binary inputs, first assert rst across a rising edge. At a falling edge deassert rst and set write_en=1 and data_in=8'h35 for one rising edge. Stop writing and check preparation. At the next falling edge assert rst and clear write_en for two rising edges.","expected":"After the preparation write, data_out is 8'h35. After each of the two subsequent reset-sampling edges, data_out is zero.","checker":"Compare against independent constants 8'h35 and zero using four-state inequality 1ns after each target rising edge. Any mismatch raises UVM_ERROR. Count one preparation comparison and two reset comparisons; missing comparisons raise an error. This local scenario makes no claim about simultaneous reset/write priority.","implementation_id":"V-example","source":"example_tb.sv:check_reset"}]}
```

```markdown
## T-example
Feature: F-example. Requirement: R-EXAMPLE-001. Implementation: V-example, example_tb.sv:check_reset.
Use a 10ns clock and stable binary inputs. First assert rst across a rising edge.
At a falling edge deassert rst, set write_en=1 and data_in=8'h35 for one rising edge.
Stop writing and check data_out is 8'h35. At the next falling edge assert rst and clear write_en for two rising edges; data_out must then be zero after each edge.
Compare against the independent constants 1ns after each target rising edge using four-state inequality. Mismatches raise UVM_ERROR. Require one preparation check and two reset checks, otherwise raise an error. This local scenario does not claim simultaneous reset/write priority coverage.
```

## Consistency and executable HDL

Both document formats are reviewed. JSON carries the complete primary field evidence and denominator; Markdown cannot repair missing JSON facts. A contradictory claim under the same condition and observation window is a local candidate error, affecting the relevant obligation and deduplicated claim rather than automatically zeroing all content. Format/reference validation and semantic correctness are separate. No deterministic cross-format semantic checker is promised.

Use `dvbench_top` as UVM top and `dvbench_test` as the UVM 1.2 test. Use `dvbench_model` as a self-contained behavioral model with exactly the native ports in ports.md. It must compile without UVM or other submission sources. Wire DUT and predicted outputs separately. `sources.f` contains one relative .sv/.v path per line in compilation order, including model/model.sv; no compiler options, absolute paths, parent traversal, wildcards or DUT copies. Includes resolve relative to the submission root.

Drive and inspect only native ports. Do not access DUT internals, force/release, DPI, files, network, OS state or hidden evaluation assets. Finite stimulus must end, intended transactions must drain, objections must release, and errors must use UVM_ERROR/UVM_FATAL. Print `DVBench_COMPLETED` once in report phase only if both severity counts are zero. Completion markers alone do not establish meaningful checking.
