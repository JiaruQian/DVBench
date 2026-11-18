# Verification plan

## T-01

Stimulus: Use fixed8warps/8groups/2fetch,known binary pins stable around rising edges and independent asynchronous reset. Establish sets and addresses through native dispatch,control and response histories only. Initialize nonzero workgroup membership,addresses,running/barrier state, then assert startup,midtraffic and wholly-between-edge reset pulses. Hold active controls during reset and inspect both state-derived and direct combinational outputs.

Expected: All registered histories clear asynchronously, including workgroup membership after a short pulse; direct control outputs continue their documented current-pin functions. Invalid payloads remain exact rather than unconstrained.

Checker: A self-contained independent model predicts abstract running/waiting/group-member sets and mathematical per-bank address/mask histories from inputs only. Separate actual/expected wires feed four-state comparisons1ns after rising clk and asynchronous reset; any mismatch emits UVM_ERROR,with finite stimulus and mandatory sample/reset counts.

## T-02

Stimulus: Use fixed8warps/8groups/2fetch,known binary pins stable around rising edges and independent asynchronous reset. Establish sets and addresses through native dispatch,control and response histories only. Sweep response valid/status,branch valid/jump,warp-control valid/op and response-ready independently, including simultaneous assertions and different warp IDs. Inspect current combinational ready,response,lookup and flush signals before edges.

Expected: Only valid-and-status requests a cache flush and blocks both control paths; branch acceptance blocks warp control even without a jump. End/branch flushes and all payload IDs follow the exact priority, without a response holding register.

Checker: A self-contained independent model predicts abstract running/waiting/group-member sets and mathematical per-bank address/mask histories from inputs only. Separate actual/expected wires feed four-state comparisons1ns after rising clk and asynchronous reset; any mismatch emits UVM_ERROR,with finite stimulus and mandatory sample/reset counts.

## T-03

Stimulus: Use fixed8warps/8groups/2fetch,known binary pins stable around rising edges and independent asynchronous reset. Establish sets and addresses through native dispatch,control and response histories only. Dispatch/end same and different banks/groups, vary response ready, re-dispatch a warp into a different group and vary tag low bits. Observe subsequent barrier completion and running readiness to expose both independent sets.

Expected: Running end wins coincident dispatch, while membership dispatch wins coincident response-handshake removal. Group indices use only tag upper three bits, and old group membership persists unless explicitly removed/reset.

Checker: A self-contained independent model predicts abstract running/waiting/group-member sets and mathematical per-bank address/mask histories from inputs only. Separate actual/expected wires feed four-state comparisons1ns after rising clk and asynchronous reset; any mismatch emits UVM_ERROR,with finite stimulus and mandatory sample/reset counts.

## T-04

Stimulus: Use fixed8warps/8groups/2fetch,known binary pins stable around rising edges and independent asynchronous reset. Establish sets and addresses through native dispatch,control and response histories only. Build one- and multiwarp groups,arrive in every order,repeat arrivals and include an unrelated group waiting bit. Combine last arrival with dispatch and vary tag low bits; inspect warp_ready across release and stalls.

Expected: Only exact whole-set equality releases selected members. Otherwise arriving bits accumulate,unrelated waiting bits persist and old group membership governs coincident arrivals.

Checker: A self-contained independent model predicts abstract running/waiting/group-member sets and mathematical per-bank address/mask histories from inputs only. Separate actual/expected wires feed four-state comparisons1ns after rising clk and asynchronous reset; any mismatch emits UVM_ERROR,with finite stimulus and mandatory sample/reset counts.

## T-05

Stimulus: Use fixed8warps/8groups/2fetch,known binary pins stable around rising edges and independent asynchronous reset. Establish sets and addresses through native dispatch,control and response histories only. Dispatch all banks,apply every one-hot/multiple/zero buffer-ready pattern and varied scoreboard/barrier states. Branch to the selected and a different warp with jump0/1. Observe all ready and fetch outputs including no-eligible cycles.

Expected: Fetch always uses lowest eligible bank and defaults to bank0 while invalid. Busy/barrier only affect warp_ready. Only an accepted selected-warp jump suppresses request valid.

Checker: A self-contained independent model predicts abstract running/waiting/group-member sets and mathematical per-bank address/mask histories from inputs only. Separate actual/expected wires feed four-state comparisons1ns after rising clk and asynchronous reset; any mismatch emits UVM_ERROR,with finite stimulus and mandatory sample/reset counts.

## T-06

Stimulus: Use fixed8warps/8groups/2fetch,known binary pins stable around rising edges and independent asynchronous reset. Establish sets and addresses through native dispatch,control and response histories only. Dispatch and branch every byte offset0..7 in ordinary and0xfffffff8 lines to each bank,including coincident dispatch/branch and dispatch/failed-response targets. Later select each bank and inspect aligned address and both mask bits.

Expected: Address alignment and unsigned greater-or-equal lane tests are exact,including offset0/4 equality boundaries. Dispatch target wins coincident same-bank inputs and all eight bank histories remain independent.

Checker: A self-contained independent model predicts abstract running/waiting/group-member sets and mathematical per-bank address/mask histories from inputs only. Separate actual/expected wires feed four-state comparisons1ns after rising clk and asynchronous reset; any mismatch emits UVM_ERROR,with finite stimulus and mandatory sample/reset counts.

## T-07

Stimulus: Use fixed8warps/8groups/2fetch,known binary pins stable around rising edges and independent asynchronous reset. Establish sets and addresses through native dispatch,control and response histories only. Observe several idle clocks after reset,then run selected/unselected banks through wraparound,failed response unaligned address/mask and successful response histories. Combine different-bank and same-bank dispatch/branch/replay and check every later-selected address.

Expected: Exact update priority and modulo increment occur on every edge as stated,including invalid request cycles. Failed responses copy unaligned payload; successful responses only affect the explicit replay condition in the next obligation.

Checker: A self-contained independent model predicts abstract running/waiting/group-member sets and mathematical per-bank address/mask histories from inputs only. Separate actual/expected wires feed four-state comparisons1ns after rising clk and asynchronous reset; any mismatch emits UVM_ERROR,with finite stimulus and mandatory sample/reset counts.

## T-08

Stimulus: Use fixed8warps/8groups/2fetch,known binary pins stable around rising edges and independent asynchronous reset. Establish sets and addresses through native dispatch,control and response histories only. Construct zero,one-warp0,one-higher-warp,two-warp and three-warp active sets with all buffer-ready bits0. Toggle response-valid/status,dispatch/end and track bank0 address/mask before later making it eligible.

Expected: The greater-than-one population threshold and exact bitvector01 exception are distinguished from generic one-active-warp logic. Response-valid alone can remove the warp0-only hold; higher-priority updates retain precedence.

Checker: A self-contained independent model predicts abstract running/waiting/group-member sets and mathematical per-bank address/mask histories from inputs only. Separate actual/expected wires feed four-state comparisons1ns after rising clk and asynchronous reset; any mismatch emits UVM_ERROR,with finite stimulus and mandatory sample/reset counts.

## T-09

Stimulus: Use fixed8warps/8groups/2fetch,known binary pins stable around rising edges and independent asynchronous reset. Establish sets and addresses through native dispatch,control and response histories only. Establish distinct bank/group histories,perturb neutral field combinations and selectors between edges,and sweep IDs0..7. Repeat identical accepted histories with only tag low bits and unrelated response-ready/busy fields changed; compare complete native vectors and invalid payloads.

Expected: No bank or group is rerouted/truncated. Direct payload IDs track pins while stored address/mask changes only through defined edges; each neutral field is neutral only in the stated domain.

Checker: A self-contained independent model predicts abstract running/waiting/group-member sets and mathematical per-bank address/mask histories from inputs only. Separate actual/expected wires feed four-state comparisons1ns after rising clk and asynchronous reset; any mismatch emits UVM_ERROR,with finite stimulus and mandatory sample/reset counts.
