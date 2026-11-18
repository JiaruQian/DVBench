# Benchmark and evaluation overview

For environment preparation and the running steps, start with [the README](../README.md). This page describes the task collection, submission requirements, scoring rules and repository contents.

DVBench evaluates agents that build complete UVM verification environments from behavioral specifications and native interfaces. It contains **95 black-box hardware verification tasks** across five difficulty levels.

| Difficulty | Task IDs | Tasks |
|---|---|---:|
| L1 | dv-001–dv-006 | 6 |
| L2 | dv-007–dv-013 | 7 |
| L3 | dv-014–dv-045 | 32 |
| L4 | dv-046–dv-074 | 29 |
| L5 | dv-075–dv-095 | 21 |

## What the agent submits

Each task lives under `questions/L1` through `questions/L5`. Read its `instruction.md`, public specification, native ports and submission contract. The agent produces:

- `flow/features.md` and `flow/features.json`;
- `flow/testplan.md` and `flow/testplan.json`;
- a self-contained `model/model.sv`, defining `dvbench_model`;
- complete UVM sources and a dependency-ordered `sources.f`.

The same independent model must be used for model replay and scoreboard predictions. Agents receive only the selected public task and may debug against the golden design. Hidden RTL, references, rubrics and mutants belong exclusively to the evaluation service. The correct implementation is called the **golden design**; a version with a deliberately introduced fault is called a **mutant**.

## What the evaluation service checks

| Component | Meaning |
|---|---|
| B: features | How well the submitted feature descriptions match the required behaviors. |
| C: test plan | How well the submitted plan covers the required verification cases. |
| D: independent model | Whether the model produces the expected results for the supplied reference histories. |
| E: verification environment | Whether the submitted environment accepts the correct design and detects faults in ten fixed faulty designs. |
| Coverage | Which lines, conditions, branches and signal changes the tests exercise, measured as LINE, COND, BRANCH and TOGGLE. |

The answering agent has finished its work before final evaluation. The service uses the same frozen answer for every scoring stage; the operator should not edit it between checks. Feature and testplan semantic F1 scores are separate from overall success.

## Budgets and success

The standard profile allows **300 cumulative agent decision turns**, with a closing reminder at **250**. A run has no whole-task wall-time or cumulative token limit. Golden debugging uses seed 1 and at most 50 feedback calls. Compilation has a 900-second limit; golden and candidate-model simulation have a 600-second limit per seed; mutant simulation has an 1800-second limit per seed. The feedback client timeout is 3660 seconds. Model-request limits and framework integration details are in [RUNTIME.md](RUNTIME.md).

Final evaluation uses seeds **1, 7, 42** and the same **ten fixed mutants** per task. Overall success requires successful compilation, golden acceptance on all seeds, detection of all ten mutants on every required seed, exact reference-model replay, and at least **90% in each** of LINE, COND, BRANCH and TOGGLE coverage. Feature and testplan semantic F1 are reported separately. Timeout, missing measurement and infrastructure failure must not be counted as mutation detection or full coverage.

A seed selects a random test sequence. The final evaluation uses all required seeds and parameter profiles; missing required profiles remain part of the requirements. The JSON profile and task budget files describe the requested settings, while the execution service must enforce them.

## Repository layout

```text
DVBench/
├── README.md
├── catalog.json
├── dvbench.py
├── agent_runner.py
├── service.py
├── runtime_contract.py
├── docs/
├── examples/
├── containers/
├── tools/
├── questions/L1…L5/dv-NNN-<design>/
└── maintainer/
    ├── README.md
    ├── runtime_policy.py
    └── tasks/dv-NNN/
```

The full installation includes maintainer task assets. Do not mount them into candidate containers. Preserve the upstream license notices included with the designs; simulator binaries, licenses, model keys and deployment credentials are supplied by each operator.

For service setup, see [server setup and evaluation connection](GITHUB.md). For implementation requirements, see [the evaluation implementation guide](../maintainer/README.md).
