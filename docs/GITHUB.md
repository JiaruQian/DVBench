# Server setup and evaluation connection

For the step-by-step user workflow, start with [the README](../README.md). This document is for the person preparing the server that other users will run DVBench on. It describes the services that must be ready before users launch a task.

The repository supplies questions, hidden task assets, launch scripts and clients. It does **not** include a complete, ready-to-start simulation and scoring service. You must connect your licensed tools and evaluation implementation to the supplied interfaces. This connecting program is called an **execution adapter**: it accepts a request such as “evaluate this run,” starts the appropriate work and returns its results.

## What the server operator prepares

| Component | Purpose | Who can access it? |
|---|---|---|
| Public question | Gives the agent the specification, ports and required submission format. | The agent for that task. |
| Agent container | Runs the answering model's tools and holds its working files. | The answering agent and the operator. |
| Feedback service | Lets the agent test its current answer against the correct design. | The matching run, using its own feedback token. |
| Simulation workers | Run VCS and URG using your licensed installation and UVM environment. | The feedback and evaluation services. |
| Hidden task assets | Supply the correct RTL, faulty designs, references and scoring material. | The evaluation service, never the answering agent. |
| Judge model | Assesses the submitted feature descriptions and test plan. | The evaluation service. |
| Execution adapter | Connects requests to your running jobs, saved answers and scoring implementation. | The operator and authenticated management clients. |

Use Linux with Docker and Python 3.10 or later. Install VCS, URG and UVM under licenses that cover your intended use. The full repository includes `maintainer/tasks/dv-NNN/`; a copy containing only public questions is insufficient for self-hosted evaluation.

The public question for `dv-001` is under `questions/L1/dv-001-four-bit-alu-display`. Its private evaluation assets are under `maintainer/tasks/dv-001/`. Only mount the public question into the agent container.

## Optional: connect from your workstation

You can run the server-side commands directly in a Linux terminal. If you work from a separate computer, configure SSH access to a dedicated benchmark account. Add your workstation's public key to that account and create a host entry in your workstation's SSH configuration:

```sshconfig
Host my-dvbench
    HostName your-server.example.org
    User benchmark
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
    ServerAliveInterval 30
```

Replace the host, account and key path with your own. Connect once to verify the server identity:

```bash
ssh my-dvbench
```

After leaving that server session, check non-interactive access from the workstation:

```bash
ssh -T -o BatchMode=yes my-dvbench 'python3 --version'
```

Clone DVBench on the server as described in the README. Alternatively, upload a workstation copy from the directory containing `DVBench/`:

```bash
rsync -az ./DVBench/ my-dvbench:~/DVBench/
```

The SSH connection is for the person managing the experiment. Do not give the agent your SSH key or access to the whole server checkout.

## Prepare simulation workers and the agent network

The agent writes code in one container; simulation workers compile and run it separately. `containers/claude-code.Dockerfile` builds the example agent environment. `containers/worker.Dockerfile` provides a base for a simulation worker. Neither supplies commercial simulator binaries or licenses.

Mount your authorized simulator installation read-only into the simulation workers and provide the license settings there. Give each attempt its own build directory so simultaneous tasks cannot overwrite each other's files. The agent needs only the selected public question, its skill, its writable answer directory and access to feedback.

Configure a Docker network from which the agent can reach the model service and task feedback service. Creating a network does not start either service. Check connectivity from a container with the same network settings as the actual agent. The supplied launchers reject host networking. Configure any separate license-server access on the simulation side.

## Connect the feedback service

**The server operator implements** a service that accepts the agent's current files, checks that they belong to the correct run and task, runs an allowed simulation and returns diagnostics. The public task's client expects:

- `POST /simulate`: an ordinary-file snapshot as `{"files":{"relative/path":"base64 content"}}`.
- `POST /artifact`: `attempt`, `name` and `offset`; the response contains `offset`, `base64`, `bytes` and `eof`.
- Authentication through a run-scoped `x-api-key` header.

Bind the endpoint and token to the user, run and task. A file map is different from a submission archive; do not send a tar file to an endpoint expecting that JSON file map. Implement responses compatible with the task's feedback client and return the available permitted diagnostic artifacts.

**The agent calls** the public task's `environment/run.sh` to test its work and retrieve available logs. It does not select the hidden design, mutant or final evaluation seed. Ordinary debugging uses the correct design, seed 1 and at most 50 simulation calls. Reading an existing artifact does not start another simulation.

**The service enforces** a 900-second compilation limit, a separate 600-second golden simulation limit, and task permissions and feedback-call accounting. The feedback client timeout is 3660 seconds. Return candidate diagnostics and permitted public-interface artifacts without exposing hidden references or faulty designs. Use the current task configuration and source order described in [the evaluation implementation guide](../maintainer/README.md).

Before freezing an answer, prevent new feedback requests and wait for accepted requests to finish. Use the final saved answer consistently for evaluation.

## Configure the judge

The answering model solves the task. The judge assesses the submitted documents. Configure the judge in the **evaluation service's environment**, separately from the answering-model key.

For example, in Bash in the account that runs evaluation:

```bash
read -rsp 'Judge key: ' DVBENCH_JUDGE_API_KEY; echo
export DVBENCH_JUDGE_API_KEY
export DVBENCH_JUDGE_BASE_URL='https://your-judge-service.example.org/v1'
export DVBENCH_JUDGE_MODEL='gpt-6.1-sol'
```

Use the model identifier accepted by your provider. The evaluation setup calls for GPT 6.1 Sol or an equivalently capable judge; record the judge used in your results. Configure your evaluation program to read these variables, or map them to its own settings. Setting shell variables alone does not configure a service running under a different account or environment. Never pass this judge key into the answering agent's container.

## Connect final evaluation

The service must import the frozen answer and associate it with the task ID and run name. A direct `tools/run-claude.sh` run produces local files but does not register a job in your evaluation service. Provide and document that import step for your users; there is no universal import command supplied by this repository.

The service evaluates the documents, independent model, correct-design behavior, detection of ten fixed faulty designs and coverage using the same frozen files throughout. Final seeds are 1, 7 and 42. Mutant simulation has a limit of 1800 seconds per seed. The complete scoring conditions are in [the benchmark overview](BENCHMARK.md), with limits in [runtime configuration](RUNTIME.md).

Use the current `maintainer/tasks/dv-NNN/task.json`, scoring rubrics, references and selected mutants. The [evaluation implementation guide](../maintainer/README.md) specifies source ordering, native interfaces, model replay and coverage handling. These requirements must be implemented in the service, not only copied into a configuration file.

## Optional: manage runs from your workstation

This interface lets a workstation request status or evaluation over SSH. It is optional when users run directly on the server and use your own evaluation interface.

`service.py` handles the request connection; your execution adapter performs the work. Install that adapter first. It must keep job state independently of the client connection, accept the documented requests and return results in the agreed format. See [the adapter protocol](../maintainer/README.md#execution-adapter) for request and response fields.

Copy `examples/service.json` to a server configuration path such as `/etc/dvbench/service.json`. Set `adapter_argv` to the absolute command for your installed adapter. The example path is a placeholder, not a program included with DVBench. Give the service account access to its configuration and required task assets.

Install a fixed executable command named `dvbench-worker` in the account's command search path. For an installation at `/srv/dvbench`, its contents can be:

```sh
#!/bin/sh
exec /usr/bin/python3 -B /srv/dvbench/service.py \
  --config /etc/dvbench/service.json --stdio
```

Replace the installation and Python paths with the actual paths on your server. The adapter reads one JSON request from standard input and returns a response with the same `request_id`. Write diagnostic logs to standard error or a private file so they do not corrupt the response.

On the workstation, from its DVBench checkout:

```bash
export DVBENCH_SSH_ALIAS='my-dvbench'
python3 -B dvbench.py --config examples/ssh.json doctor
```

The remote check should confirm the configured tools and services; it does not replace a real end-to-end trial. Credential names in configuration files refer to environment variables. The SSH client does not automatically transfer their secret values: configure credentials in the server account or service that needs them. Any additional SSH connection needed by your HDL installation is configured separately on the simulation side.

For a run already registered with your service:

```bash
python3 -B dvbench.py --config examples/ssh.json status --run experiment-001
python3 -B dvbench.py --config examples/ssh.json verify \
  --run experiment-001 --jobs 1 --output ./verified.json
```

If evaluation continues in the background, the initial response may identify a job instead of containing its scores. Explain to users how to obtain the completed result in your deployment. The `report` command needs completed data with a nonempty `tasks` array; it cannot turn a job identifier into evaluation results.

## Check the installation before a full experiment

First confirm the local task files, model access and tool versions. Then use a separate trial run to check that an agent can edit a file, request a simulation, read a compilation error, repair its own answer and retrieve the next simulation's logs. Finally, freeze and import the answer and run all scoring stages. A successful model response or local file check does not establish that this full sequence works.

Check the 250-turn reminder and 300-turn limit, including any recovery behavior supported by your deployment. The direct Claude Code launcher starts a new run and does not implement session recovery. For other frameworks, verify that the editing and shell tools are actually available; [runtime configuration](RUNTIME.md) explains the repaired Codex and OpenCode requirements.

Qualify task-specific source ordering, parameterized interfaces, shared model files and coverage measurement, including the cases listed in [deployment qualification](../maintainer/README.md#deployment-qualification). Record the image and CLI versions, model and judge settings, skill and budget profile used in the experiment.

When these checks pass, give users the network name, feedback address, task/run token and final-evaluation instructions they need, then return to [the README](../README.md).
