# Golden-design debugging

The controller supplies the feedback service address and a token scoped to this run. The agent uses only the golden design with fixed seed 1. Each session allows at most 50 feedback calls; compilation has a 900-second limit and golden simulation has a separate 600-second limit. Final verification uses seeds 1, 7 and 42 independently.

Submit ordinary files and write the response to a new JSON file:

```bash
bash /public/environment/run.sh simulate --submission /submission --output /tmp/feedback-01.json
```

Inspect the returned diagnostic index. Retrieve an available artifact using its attempt number and name:

```bash
bash /public/environment/run.sh artifact --attempt 1 --name compile.log --output /tmp/compile-01.log
```

Artifact downloads do not start another simulation. Compilation failures may have no waveform; unavailable artifacts include a reason. Read candidate compilation diagnostics, simulation logs and waveforms limited to public ports and candidate-owned signals. Files are downloaded in pages. Truncation and omissions must be explicit; use the supplied artifact index for actual sizes and availability.

Keep all feedback outside `/submission`. Revise the candidate files and retry within the session budget. Hidden RTL, DUT internal signals, reference answers, rubric and mutation results are not part of the debugging interface. Full evaluation follows submission freeze.
