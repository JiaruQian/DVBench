# DVBench

DVBench evaluates whether an AI agent can build a complete UVM hardware verification environment from a design specification and its input/output interface. It contains **95 tasks across five difficulty levels**. The agent writes the verification files; a separate evaluation service checks them against the correct design and versions with deliberately introduced faults.

This guide takes you from preparing the environment to reading the results. It separates **what you prepare**, **what the agent does**, and **what the evaluation service does**. The worked example uses Claude Code on a Linux server. Codex and OpenCode require their own launch configuration; see [agent runtime configuration](docs/RUNTIME.md).

## Before you start

You can browse and export questions with Python 3.10 or later. To run and evaluate an agent, you also need a Linux server, Docker, model access, and working licensed installations of VCS, URG and UVM. VCS runs hardware simulations; URG produces coverage reports showing which parts of the design were exercised.

The repository includes the questions, hidden evaluation assets, container launch scripts, feedback clients and result export tools. **A complete simulation feedback and evaluation service is not included.** Someone responsible for your server must connect the supplied task assets to your simulator and scoring implementation before the agent can test its answer or receive a final score. If your group already has that service, obtain its connection details. If you are setting it up yourself, follow [server setup and evaluation connection](docs/GITHUB.md). Cloning the repository and building the agent image alone do not complete that setup.

## Who does what?

| Stage | You, or the person maintaining your server | Agent | Evaluation service |
|---|---|---|---|
| Prepare | Install the tools, configure model access, supply a skill and connect feedback/evaluation. | Nothing yet. | Keep the correct design and hidden evaluation assets available privately. |
| Start | Choose the task, model and a new run name; start the launch script. | Read the public question and submission requirements. | Make debugging feedback available for this task and run. |
| Solve and debug | Observe progress. For a scored run, do not edit the agent's answer. | Write all required files, request simulations and revise its own work. | Run the current files against the correct design and return permitted diagnostics. |
| Evaluate | Submit the final saved answer for evaluation. | Its answering phase has ended. | Check the same saved answer against references, the correct design, faulty designs and coverage requirements. |
| Read results | Check that evaluation finished, then export and inspect the scores. | No further changes to this answer. | Return the completed measurements and scores. |

A **run** is one named experiment. A **skill** is a folder of instructions and supporting tools that you choose to give the agent. A **frozen submission** is a saved, read-only copy of the final answer, so every evaluation uses the same files.

## 1. You prepare: install DVBench on the server

If you work from a laptop, connect to your Linux server first. SSH opens a terminal on that server; the agent does not need your SSH key. See [optional SSH setup](docs/GITHUB.md#optional-connect-from-your-workstation) if needed.

Download the ZIP from the anonymous repository page, extract it into `$HOME/DVBench`, and upload that directory to your Linux server if needed. If you already have an extracted copy, use it directly.

Run these commands in **Bash on the Linux server**:

```bash
export DVBENCH_ROOT="$HOME/DVBench"
export DVBENCH_RUN_ROOT="$HOME/dvbench-runs"
export DVBENCH_SKILLS_DIR="$HOME/dvbench-skills"
mkdir -p "$DVBENCH_RUN_ROOT" "$DVBENCH_SKILLS_DIR"
cd "$DVBENCH_ROOT"

python3 --version
docker info
python3 -B dvbench.py doctor --local-only
python3 -B dvbench.py tasks list
```

Python must be version 3.10 or later, and `docker info` must connect successfully to Docker. The task list should contain 95 entries. `doctor --local-only` checks the local task files; it does **not** check model access, simulator licenses or final evaluation.

To inspect a difficulty level or export a public question:

```bash
python3 -B dvbench.py tasks list --level L3
python3 -B dvbench.py prepare --task dv-001 --output ./prepared-dv001
```

`dv-001` is a task ID; its directory is `questions/L1/dv-001-four-bit-alu-display`. The task distribution and repository layout are described in [the benchmark overview](docs/BENCHMARK.md).

The following steps assume the same Bash session. If you reconnect later, set the environment variables again. Keep credentials out of committed files.

## 2. You prepare: build the agent environment

Choose a pinned Claude Code version and build (replace `YOUR_PINNED_VERSION` with that version):

```bash
docker build -t dvbench-claude-code:latest \
  --build-arg CLAUDE_CODE_VERSION=YOUR_PINNED_VERSION \
  -f containers/claude-code.Dockerfile .

docker run --rm --network none --entrypoint claude \
  dvbench-claude-code:latest --version
```

This image is the environment in which the agent writes its answer. It includes Claude Code, Python, Git and ripgrep. It does not install a licensed simulator or start the feedback service. Add packages needed by your skill to your own image, and keep API keys and task assets outside it. The supplied launcher limits each agent container to 4 CPUs and 8 GiB of memory; allow additional server capacity for simulation workers and simultaneous runs.

The network and simulation service are configured in step 5. First prepare the skill and model access below.

## 3. You prepare: provide the agent's skill

Choose the verification skill you want the agent to use. A skill contains a `SKILL.md` instruction file and may contain scripts or reference documents. `verification` below is an example name, **not a skill supplied by this repository**. This launcher requires you to provide one.

Copy your skill folder into `$DVBENCH_SKILLS_DIR` on the server. If it is on your workstation and you configured the example SSH alias, run this **on the workstation**, from the folder containing your skill:

```bash
scp -r ./verification my-dvbench:~/dvbench-skills/
```

The resulting server directory should contain:

```text
dvbench-skills/
└── verification/
    ├── SKILL.md
    ├── scripts/
    └── references/
```

On the server:

```bash
export DVBENCH_SKILL='verification'
test -f "$DVBENCH_SKILLS_DIR/$DVBENCH_SKILL/SKILL.md"
```

The launch script makes this folder available to Claude Code and asks the agent to use the selected skill. Keep skill discovery enabled. Only include material intended for the agent; do not put hidden answers or evaluation assets in the skills folder. Record which skill you used when comparing experiments.

## 4. You prepare: configure the answering model

The **answering model** is the model the agent uses to solve the task. The **judge model** helps the evaluation service assess the submitted documents. They have separate roles and configurations.

In Bash on the server, enter the answering-model key without displaying it:

```bash
read -rsp 'Answering model key: ' ANTHROPIC_API_KEY; echo
export ANTHROPIC_API_KEY
export DVBENCH_CLAUDE_MODEL='your-answering-model'
```

Replace `your-answering-model` with the identifier accepted by your provider. If you use a gateway or another provider that supports the API expected by Claude Code, also set its address:

```bash
export ANTHROPIC_BASE_URL='https://your-answering-gateway.example.org'
```

Omit that variable for Claude Code's default API endpoint. The example URL is a placeholder. Check that the chosen provider supports your model, tools and response limits. The launcher requests a maximum of 128000 output tokens per response by default; record any change needed for your provider. See [runtime configuration](docs/RUNTIME.md) for model-specific settings.

Configure the judge key in the **evaluation service**, using [the server guide](docs/GITHUB.md#configure-the-judge). The agent needs its answering-model and feedback credentials; it should not receive the judge key.

## 5. You prepare: connect feedback and final evaluation

The agent needs a way to test its work while solving a task. The **feedback service** receives its current files, runs them against the correct design and returns diagnostics. Later, the **evaluation service** checks the final answer using hidden reference material and faulty versions of the design. Both services run outside the answering agent's container.

Before launching a task, obtain or set up:

| Item | What you need |
|---|---|
| Simulation environment | Working VCS, URG and UVM installations with valid licenses, available to the simulation workers. |
| Agent network | A Docker network from which the agent can reach the model service and feedback service. The launcher does not accept host networking. |
| Feedback address and token | A working service address and a token restricted to the selected task and run. |
| Final evaluation | A service that can import the final answer, use the hidden task assets and return completed scores. |
| Judge configuration | The document-assessment model, service address and key, configured in the evaluation service. |

**If these are not ready, complete [server setup](docs/GITHUB.md) first.** Creating an empty Docker network or setting the variables below does not create a simulation service.

Set the connection details supplied by your server operator, in Bash on the server:

```bash
export DVBENCH_CLAUDE_IMAGE='dvbench-claude-code:latest'
export DVBENCH_DOCKER_NETWORK='your-agent-network'
export DVBENCH_FEEDBACK_URL='http://your-feedback-service:8080'
read -rsp 'Task feedback token: ' DVBENCH_FEEDBACK_TOKEN; echo
export DVBENCH_FEEDBACK_TOKEN
```

The feedback address must be reachable **from inside the agent container**. The token must match the task and run you are about to launch. Keep simulator license credentials, judge keys and `maintainer/tasks/` outside the agent environment.

For the standard experiment settings, the service allows up to 50 debugging simulations against the correct design using seed 1. A seed selects the random test sequence. Final evaluation uses seeds 1, 7 and 42. All execution limits and their enforcement responsibilities are listed in [runtime configuration](docs/RUNTIME.md#standard-profile).

## 6. You start the task; the agent writes and tests its answer

After completing steps 1–5, run this **on the server**:

```bash
cd "$DVBENCH_ROOT"
bash tools/run-claude.sh dv-001 experiment-001
```

`dv-001` selects the question. `experiment-001` is the name you choose for this run. Use a new name for each new run; the script refuses to overwrite an existing run directory.

**The launcher automatically** starts the Claude Code container with the public question and selected skill, records its output, and removes the container when it finishes. It tells the agent about the 300-turn budget and required deliverables. The CLI limits the run to 300 turns; a reminder is delivered at a tool boundary after 250 observed assistant decisions. There is no configured whole-task time limit or cumulative token limit. Individual model requests and simulations have their own limits, described in [runtime configuration](docs/RUNTIME.md).

**The agent's job** is to read `/public/instruction.md` and the referenced public files, then create all required deliverables under `/submission`:

- `flow/features.md` and `flow/features.json`: the behaviors the design should support.
- `flow/testplan.md` and `flow/testplan.json`: a plan for checking those behaviors.
- `model/model.sv`: an independent prediction model defining `dvbench_model`.
- Complete UVM verification sources and a dependency-ordered `sources.f` listing the files to compile.

The selected question describes additional files or parameter settings it requires. The independent model must predict expected results; the design's actual outputs must not be used to generate their own expected answers.

**These next commands are for the agent inside its container. They are not commands for you to run in the server shell.** They show how the agent requests a simulation and retrieves a diagnostic log:Within the container, the task feedback commands are:

```bash
bash /public/environment/run.sh simulate \
  --submission /submission --output /tmp/feedback-01.json
bash /public/environment/run.sh artifact \
  --attempt 1 --name compile-console.log --output /tmp/compile-01.log
```

The agent uses the returned feedback to revise its own files. Log names must come from the service's returned list. Reading an existing log does not start another simulation. A debugging PASS does not mean the task is complete: the agent must still finish all required documents and verification files.

You can observe progress from another server terminal by opening the run's `agent.jsonl` and `agent.stderr` files. The launcher writes live output there, so the terminal that started it may appear quiet. For a scored run, let the agent make its own corrections rather than editing its answer yourself.

## 7. You collect the answer; the evaluation service scores it

After the launcher completes its final save step, the run directory contains:

```text
dvbench-runs/experiment-001/
├── submission/     Files written by the agent
├── frozen/         Read-only copy for final evaluation
├── agent.jsonl     Recorded agent output
├── agent.stderr    Errors and other diagnostic messages
├── prompt.txt      Instructions given to the agent
├── settings.json   Claude Code settings for this run
├── runtime/        Turn-count information
└── result.json     Run details and the agent's exit code
```

`result.json` describes the agent run; **it is not the final evaluation report**. A zero exit code means the process exited successfully, not that the answer passed DVBench. If the run was interrupted or the launcher failed, check the diagnostics and confirm that the saved answer exists before proceeding. This direct launcher does not resume an interrupted session.

On the server, check the required submission structure and create an archive:

```bash
python3 -B dvbench.py check-submission \
  --submission "$DVBENCH_RUN_ROOT/experiment-001/frozen"
python3 -B dvbench.py pack \
  --submission "$DVBENCH_RUN_ROOT/experiment-001/frozen" \
  --output "$DVBENCH_RUN_ROOT/experiment-001/submission.tar.gz"
```

The structure check does not compile or score the answer. Give the frozen answer or its archive to your evaluation service with task ID `dv-001`, run name `experiment-001` and the judge configuration. The import command depends on your service and must be supplied by its operator. The launch script creates local files; it does not automatically register them with a remote service.

**The evaluation service then** assesses the documents, tests the independent model, runs the verification environment against the correct design and ten faulty designs, and measures coverage. The answering agent has finished its work at this point. Use the same frozen files for all scoring stages.

If your server provides the optional SSH management interface and has registered this run, use the following commands **on your workstation, from its DVBench checkout**. This requires [remote management setup](docs/GITHUB.md#optional-manage-runs-from-your-workstation); SSH access alone is insufficient:

```bash
export DVBENCH_SSH_ALIAS='my-dvbench'
python3 -B dvbench.py --config examples/ssh.json status --run experiment-001
python3 -B dvbench.py --config examples/ssh.json verify \
  --run experiment-001 --jobs 1 --output ./verified.json
```

## 8. You read and export the results

Before exporting, confirm that `verified.json` contains completed evaluation results and a nonempty `tasks` array. Some services initially return a job identifier while evaluation continues. Check status and obtain the completed result according to your service's instructions before using it as a report.

Run this wherever you saved the completed result:

```bash
python3 -B dvbench.py report --input ./verified.json --output ./report
```

This writes `report/metrics.json` and `report/metrics.csv` from existing results. Open the CSV to compare the reported measurements, and use the JSON for the complete returned result. This command does not run the agent, call the judge or perform simulations.

A task counts as an overall success only when the answer compiles, the independent model matches all required reference checks, the correct design passes at every required seed, all ten faulty designs are detected at every required seed, and **each of LINE, COND, BRANCH and TOGGLE coverage reaches at least 90%**. These coverage measurements describe which lines, conditions, branches and signal changes were exercised. Feature and testplan scores are reported separately.

A simulation timeout, license failure or missing coverage report is not a successful fault detection. Keep these outcomes distinguishable from an incorrect answer. See [the benchmark overview](docs/BENCHMARK.md) for the complete scoring conditions.

Start with one task to confirm that model access, feedback, saving the answer and final evaluation all work. Then use separate run names, workspaces and feedback tokens for additional tasks. Choose the number of simultaneous runs to fit your server, model service and simulator licenses. If you retry an experiment, retain that fact when reporting its results.

## Further reading

| Document | When to use it |
|---|---|
| [Server setup and evaluation connection](docs/GITHUB.md) | You are installing feedback/evaluation services or configuring remote management. |
| [Agent runtime configuration](docs/RUNTIME.md) | You need exact budgets, Codex/OpenCode settings or troubleshooting. |
| [Benchmark and evaluation overview](docs/BENCHMARK.md) | You want the task distribution, submission requirements, scoring rules and repository layout. |
| [Task revisions](docs/TASK_REVISIONS.md) | You need to check repaired task versions and whether results require new submissions or reevaluation. |
| [Evaluation implementation guide](maintainer/README.md) | You are implementing or maintaining the simulation and scoring service. |

Preserve the license notices included with the designs. Simulator software, licenses, model credentials and server accounts are supplied by each user or deployment.
