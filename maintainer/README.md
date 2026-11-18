# Trusted evaluation integration

`tasks/dv-NNN/` contains the golden RTL, ten fixed mutants, feature/testplan rubrics, interfaces, replay material and maintainer references. Candidate containers must never receive this directory. All task paths are relative to the corresponding task root.

## Execution adapter

`service.py` supplies HTTP/SSH transport. Install a trusted persistent execution adapter and configure its absolute argument array in `examples/service.json`. It must return quickly for scheduling operations and retain job state independently of a client connection. The repository does not include a complete scheduler, licensed HDL toolchain or universal B/C/D/E execution engine.

The adapter reads one JSON object from stdin and writes one response to stdout. Logs belong on stderr or in a private file. Return the exact request ID:

```json
{"protocol":"dvbench-rpc-1","request_id":"request-001","operation":"status","payload":{"run":"experiment-01"}}
```

```json
{"request_id":"request-001","result":{"run":"experiment-01","status":"RUNNING"}}
```

Failures use `{"request_id":"request-001","error":"description"}`. The service request limit is 96 MiB; the CLI response limit is 16 MiB. Use artifact retrieval for large outputs.

| Operation | Payload | Required behavior |
|---|---|---|
| `doctor` | `model_requests=false` | Check configuration, tools and licenses without paid model calls. |
| `rollout` | `run, task_ids, agent, jobs, purpose, profile` | Atomically reserve a run and launch isolated agents with enforced budgets. |
| `status` | `run` | Return task states, usage and cleanup state. |
| `resume` | `run` | Continue the same candidate, files and cumulative budget. |
| `cancel` | `run` | Stop the owned process/container tree and retain evidence. |
| `verify` | `run, jobs` | Freeze once, evaluate B/C/D/E and coverage, and return a nonempty `tasks` array. |
| `feedback` | `run, task_id, files` | Validate ordinary-file snapshots; expose only golden debugging. |
| `artifact` | `run, task_id, artifact_id` | Return authorized artifacts as `data_base64`. |

Management RPC is distinct from the task feedback API. The latter uses a run/task-scoped `x-api-key`: `POST /simulate` receives `{"files":{"relative/path":"base64 content"}}`; `POST /artifact` receives `attempt,name,offset` and returns `offset,base64,bytes,eof`. Do not pass an archive to an endpoint expecting a file map.

## Repairs the execution adapter must consume

The updated task assets and `runtime_policy.py` are portable. Historical experiment orchestrators are not bundled: they depend on a particular server's paths and license infrastructure. Integrate the following behaviors before using this release for scored runs; copying a helper without calling it does not update an external evaluator.

1. **Source order.** Use `rtl_compile_files` (also mirrored in `rtl_sources`) for golden and mutant compilation. `ordered_sources(task, config)` provides the package-first ordering used by the repaired feedback path. Never sort files alphabetically. In dv-094, `backfill/apb_ntt_pkg.sv` must precede its consumers.
2. **Native interfaces and parameters.** Use SystemVerilog elaboration to discover actual DUT instances and parameter values. Accept legal generate-index paths, such as `dvbench_top.gen[0].dut`; `validate_scopes` validates this syntax but is not itself an elaborator. Preserve packed/unpacked index directions, public parameter matrices and allowed software input files. Do not infer bindings from regex alone or reject legal native array ports. Coverage and feedback must use the same resolved DUT scopes.
3. **Shared frozen model.** Every parameter profile uses byte-identical root `model/model.sv`. `copy_shared_model` creates writable destination directories before restoring frozen metadata. Missing required profile files are candidate failures; do not create substitute candidate content. dv-046 includes the repaired profile assets and shared-model mapping.
4. **Reference capture.** Capture histories using the conforming reference, with a separate trusted reference-capture budget when needed (the repaired long reference capture uses 3600 seconds). Candidate execution retains its own limit. dv-045's former diagnostic reference is retained under `solution/diagnostic-reference-v1`; use `solution/reference` for the conforming reference. Regenerate histories from that reference rather than reusing stale cached vectors from the diagnostic implementation.
5. **Coverage.** Bind instrumentation to the actual native DUT subtree, including legal indexed scopes. `bind_coverage_scope` rejects a mismatched existing scope; use it after elaboration. Mapped dv-045 measurement must preserve the frozen design and stimulus, check gate-bitmaps and scope, and reconcile mapped measurements with the native report. Do not treat an absent report, zero denominator, failed URG generation or a report from another run as 100%. `coverage_percent` returns `None` for zero denominator. Tool crashes and missing metrics require a technical recovery on the same frozen candidate, with before/after evidence.
6. **Large logs and failures.** Parse UVM summary counts without loading an entire multi-gigabyte log. `uvm_summary` streams lines and records the final ERROR/FATAL counts and license failures. A completion marker alone does not establish a pass. License failures, timeout, cancellation and process/container failures are not successful mutant detection.
7. **Budget and tools.** Use [RUNTIME.md](../docs/RUNTIME.md). Verify actual request tools before launching the full task set. Preserve decision counters across compaction/recovery; count auxiliary token-count requests separately from answering generations.
8. **dv-008 one-bit interface compatibility.** Apply the narrow scalar/packed `[0:0]` equivalence described in [Task revisions](../docs/TASK_REVISIONS.md#dv-008-interface-compatibility) to both online feedback and frozen evaluation. Preserve name, direction, unsigned four-state type and width checks. This repository's transport does not automatically update an external adapter. Bind the qualified adapter version to each run and retain any historical incorrect-feedback evidence.

## Evaluation semantics

Use the candidate's own documents, model and UVM environment. B assesses feature semantics; C assesses the testplan; D replays independently supplied histories against the candidate model; E checks golden behavior and ten fixed mutants at seeds 1, 7 and 42. Missing required profiles remain in the denominator. Record provisional semantic assessment status explicitly; a technical execution check does not establish independent judge calibration.

The `overall_success(result)` helper implements the 90% criterion for a normalized result:

```json
{
  "compile_pass": true,
  "reference_model_percent": 100,
  "golden": {"1":"PASS","7":"PASS","42":"PASS"},
  "mutants": [{"id":"m1","seeds":{"1":"DETECTED","7":"DETECTED","42":"DETECTED"}}],
  "coverage": {"LINE":95,"COND":92,"BRANCH":94,"TOGGLE":93}
}
```

This illustrative object has only one mutant, so it deliberately does **not** pass; supply all ten task-selected distinct mutant IDs. Validate those IDs against `runtime-evaluation.json` before normalization. Compilation errors, timeouts and infrastructure failures use distinct statuses, never `DETECTED`. B/C F1 do not enter overall success. Missing or unmeasured coverage is not a pass. The old 85% staging profile is superseded and is not used in this release.

## Deployment qualification

Validate source dependencies, all profile assets, frozen-input hashes, model request tools, repeated-run budget accounting, feedback permissions and cleanup. Run real compiler-failure/repair controls and representative tasks (including dv-094 package order, indexed parameter instances and dv-045 coverage) on the intended deployment before a formal benchmark. A local catalog check or Python regression check is not a simulator/model integration qualification. Record CLI versions, container digests, provider protocols, profile and source hashes with every run.

Model/judge keys belong only in the processes that need them. Candidate HDL executes non-root without network access to hidden services; mount only the current attempt's inputs. Cancel and timeout handling must clean the entire owned execution tree. Revoke feedback and drain in-flight requests before freezing. Preserve upstream license notices and comply with the licenses of VCS, URG, UVM and the agent CLIs.
