# Submission Format

flow and root model paths are relative to the submission root; HDL and filelists follow the profile conventions below. A complete A must submit `flow/features.md`, `flow/features.json`, `flow/testplan.md`, `flow/testplan.json`, `model/model.sv`, and each of the three profiles' filelists and complete UVM source code. JSON is the primary carrier of complete facts and references; Markdown and JSON use the same IDs, interfaces, and semantics and must not contradict each other.

The root object of `features.json` contains a nonempty `features` array. Each entry contains a unique nonempty `feature_id`, nonempty `module`, `definition`, `timing`, `boundary`, nonempty deduplicated string arrays `requirement_ids` and `interface`, and optional `parent_id`. `features.md` is a readable representation of the same entries.

The root object of `testplan.json` contains a nonempty `tests` array. Each entry contains a unique nonempty `test_id`, nonempty `feature_ids` and `requirement_ids`, `stimulus`, `expected`, and `checker`. A complete A submission must also provide nonempty `implementation_id` and `source`, and `source` must point to an actual implemented checkpoint. `testplan.md` presents the same references and complete facts for the same test.

`model/model.sv` must be self-contained and define module `dvbench_model`. Port names, directions, widths, index directions, and fixed parameters must match `ports.md`. The model generates expectations only from inputs, reset, and their history; it must not read DUT outputs. Each `profiles/<profile>/sources.f` lists one relative `.sv`/`.v` file per line in compilation order, must include `model/model.sv`, and must not contain RTL, absolute paths, `..`, options, or wildcards.

The UVM environment must include transaction, sequence, driver, monitor, env, an independent predictor, scoreboard, checker, coverage, interface, top, test, and filelist. Checks must compare independent expectations generated from input history against actual DUT port values; report errors using UVM_ERROR/UVM_FATAL. Output `DVBench_COMPLETED` only after legal completion, draining all in-flight transactions, and confirming zero ERROR/FATAL.

The format example for the fictitious module `PulseMeter` may be used as a reference; do not copy the example facts as the answer to this task.


## Directory contract for the three parameter profiles

A/E must provide sources.f and tb source code for each of profiles/p4to8, profiles/p8to4, and profiles/p8to8; paths in each filelist are relative to the corresponding profile working root. The assembler places the same root model/model.sv in each working root. The original submission need not copy the model three times; E uses the given model. The profile parameters are fixed by ports.md, and D submits only the same parameterized model. The sources for a complete A must allow the checker implementation for the actual profile to be located.

## Fictitious Example

The following demonstrates only the format. The hypothetical PulseMeter has the native interface clk, pulse, count[7:0], has no reset port, and its count is initially 0. The MD and JSON in the example files express the same facts entry by entry; none of the examples are part of the answer to this task.

### Features

```json
{
  "features": [
    {
      "feature_id": "F-PM-01",
      "requirement_ids": [
        "R-PM-01"
      ],
      "module": "PulseMeter",
      "definition": "The fictitious PulseMeter's 8-bit count is initially 0; on each rising edge of clk, it increments by 1 if pulse=1, and otherwise holds.",
      "interface": [
        "clk",
        "pulse",
        "count"
      ],
      "timing": "pulse is driven on the falling edge of clk and sampled on the rising edge; count stabilizes after the registered update on that rising edge.",
      "boundary": "There is no reset port; the 8-bit unsigned count wraps from 255 to 0."
    }
  ]
}
```

```markdown
### F-PM-01

requirement_ids: ["R-PM-01"]

module: PulseMeter

definition: The fictional PulseMeter's 8-bit count is initially 0; on each clk rising edge, increment by 1 if pulse=1, otherwise hold.

interface: ["clk", "pulse", "count"]

timing: pulse is driven on the clk falling edge and sampled on the rising edge; count is stable after the register update on that rising edge.

boundary: No reset port; the 8-bit unsigned count wraps around from 255 to 0.
```

### Testplan

```json
{
  "tests": [
    {
      "test_id": "T-PM-01",
      "feature_ids": [
        "F-PM-01"
      ],
      "requirement_ids": [
        "R-PM-01"
      ],
      "stimulus": "Start from the initial count=0 specified by the specification; first hold pulse=0 across two rising edges, then set pulse=1 on a falling edge for only one rising edge, set it to 0 on the next falling edge, and hold for two rising edges.",
      "expected": "count=0 on the first two edges, count=1 after the single edge with pulse active, and it remains 1 on the following two edges.",
      "checker": "An independent 8-bit variable expected is initially 0; on each rising edge, compute (expected+pulse) modulo 256 using only the input pulse history; after the registered update stabilizes on each edge, read DUT count and compare using four-state inequality; report UVM_ERROR for an unknown value or a mismatch, and assert that the comparison count is 5.",
      "implementation_id": "CHK-PM-01",
      "source": "tb/checker.sv:check_pulse"
    }
  ]
}
```

```markdown
### T-PM-01

feature_ids: ["F-PM-01"]

requirement_ids: ["R-PM-01"]

stimulus: Start from the initial count=0 specified by the specification; first hold pulse=0 across two rising edges, then set pulse=1 on a falling edge, spanning only one rising edge, and set it to 0 on the next falling edge and hold for two rising edges.

expected: For the first two edges, count=0; after the single pulse-active edge, count=1; it then remains 1 for the following two edges.

checker: An independent 8-bit variable expected is initially 0, and (expected+pulse) modulo 256 is computed on each rising edge using only the input pulse history; read DUT count after the register update has stabilized on each edge and compare using four-state inequality; any unknown or mismatch produces UVM_ERROR, and assert that the number of comparisons is 5.

implementation_id: CHK-PM-01

source: tb/checker.sv:check_pulse
```

