# testplan

## T1

test_id: T1

feature_ids: ["F1"]

requirement_ids: ["R-dv-024-001"]

stimulus: Initialize all native inputs, generate a 10 ns clock and synchronous reset, then initialize both payload slots before judging invalid payload numerically. Drive at falling edges; enforce the complete legal TileLink domain, source uniqueness, multibeat headers and stalled-payload retention. A downstream port agent returns matching acknowledgment source/size/opcode only for accepted outgoing requests and provides independently generated response data. Exercise all legal opcodes, source groups, sizes 0..6 and byte lanes; include multibeat reads/writes and both-direction concurrent handshakes.

expected: The complete native TLBuffer contains independent depth-two FIFOs for A requests from auto_in to auto_out and D responses from auto_out to auto_in, plus the original observational TileLink monitor. It has one clock and synchronous active-high reset, no top parameters, no combinational flow-through and no full-queue replacement path. Functional transformations operate per accepted beat, including multibeat messages. Legal active A messages use opcode 0/1/4 (PutFull/PutPartial/Get), param zero, source in {0..9,16,32..47}, size 0..6, address[12]=1 and address aligned to 2^size. Sizes above three span multiple 64-bit beats for writes and read responses. Get and PutFull use the exact addressed lane mask; PutPartial uses a subset, possibly zero. Get corrupt is zero; write corrupt is passed through. Match D source, size and acknowledgment opcode to the outstanding A transaction, preserve multibeat metadata, keep stalled payload stable and reuse sources only after completion. Native monitor assertions remain enabled.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates only at rising edges. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T2

test_id: T2

feature_ids: ["F2"]

requirement_ids: ["R-dv-024-002"]

stimulus: Initialize all native inputs, generate a 10 ns clock and synchronous reset, then initialize both payload slots before judging invalid payload numerically. Drive at falling edges; enforce the complete legal TileLink domain, source uniqueness, multibeat headers and stalled-payload retention. A downstream port agent returns matching acknowledgment source/size/opcode only for accepted outgoing requests and provides independently generated response data. Reset empty, partly occupied and full FIFOs, overlap input valid with reset and check reset-edge slot capture versus pointer/occupancy reset, without assuming zero payload.

expected: At each rising edge with reset high both FIFO occupancies and read/write positions become empty at slot zero. Payload storage is not reset or cleared. Outputs are not directly gated by the reset level before that edge. Reset discards pending beats. Separately, a pre-edge nonfull FIFO can still write incoming valid payload into its pre-edge write slot on a reset edge, while its occupancy and positions are reset; a pre-edge full FIFO cannot capture on that edge. Before slot initialization numerical payload is unspecified.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates only at rising edges. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T3

test_id: T3

feature_ids: ["F3"]

requirement_ids: ["R-dv-024-003"]

stimulus: Initialize all native inputs, generate a 10 ns clock and synchronous reset, then initialize both payload slots before judging invalid payload numerically. Drive at falling edges; enforce the complete legal TileLink domain, source uniqueness, multibeat headers and stalled-payload retention. A downstream port agent returns matching acknowledgment source/size/opcode only for accepted outgoing requests and provides independently generated response data. Fill A to two entries under downstream stall, offer a third stable beat, drain a full queue and verify no replacement on the draining edge; separately check empty latency and ready/valid combinations.

expected: auto_in_a_ready is one exactly when the A FIFO has fewer than two stored beats, and auto_out_a_valid is one exactly when it has at least one. An A input beat is captured at a rising edge iff auto_in_a_valid and auto_in_a_ready are one; an A output beat is removed iff auto_out_a_valid and auto_out_a_ready are one. At empty there is no same-cycle bypass. At full, input ready stays zero even when the output is ready; draining a full FIFO cannot also accept a replacement beat on that edge.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates only at rising edges. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T4

test_id: T4

feature_ids: ["F4"]

requirement_ids: ["R-dv-024-004"]

stimulus: Initialize all native inputs, generate a 10 ns clock and synchronous reset, then initialize both payload slots before judging invalid payload numerically. Drive at falling edges; enforce the complete legal TileLink domain, source uniqueness, multibeat headers and stalled-payload retention. A downstream port agent returns matching acknowledgment source/size/opcode only for accepted outgoing requests and provides independently generated response data. Use distinguishable patterns in all A fields, single and multibeat messages, wrap both slot positions, stall output and cross simultaneous input/output handshakes; compare every field in FIFO order.

expected: Every captured A beat retains all bits of opcode, param, size, source, address, mask, data and corrupt without transformation. Output payload is the oldest queued beat. Accepted beats preserve order across stalls, simultaneous enqueue/dequeue and wraparound. Output payload remains stable while output valid is one and output ready is zero. Input changes while full or invalid do not overwrite a retained beat.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates only at rising edges. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T5

test_id: T5

feature_ids: ["F5"]

requirement_ids: ["R-dv-024-005"]

stimulus: Initialize all native inputs, generate a 10 ns clock and synchronous reset, then initialize both payload slots before judging invalid payload numerically. Drive at falling edges; enforce the complete legal TileLink domain, source uniqueness, multibeat headers and stalled-payload retention. A downstream port agent returns matching acknowledgment source/size/opcode only for accepted outgoing requests and provides independently generated response data. Fill D to two beats under upstream stall, offer an additional stable response, then drain; test empty latency, partial occupancy, simultaneous capture/removal and no full replacement.

expected: auto_out_d_ready is one exactly when the D FIFO has fewer than two stored beats, and auto_in_d_valid is one exactly when it has at least one. Capture D at a rising edge iff auto_out_d_valid and auto_out_d_ready are one; remove its oldest beat iff auto_in_d_valid and auto_in_d_ready are one. It has no empty bypass and no same-edge replacement while full. Accepted response beats preserve order with simultaneous enqueue/dequeue and pointer wraparound.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates only at rising edges. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T6

test_id: T6

feature_ids: ["F6"]

requirement_ids: ["R-dv-024-006"]

stimulus: Initialize all native inputs, generate a 10 ns clock and synchronous reset, then initialize both payload slots before judging invalid payload numerically. Drive at falling edges; enforce the complete legal TileLink domain, source uniqueness, multibeat headers and stalled-payload retention. A downstream port agent returns matching acknowledgment source/size/opcode only for accepted outgoing requests and provides independently generated response data. Return opcode 0/1, all legal sizes/source groups and varied 64-bit response data; verify retained order, stalls and zero param/sink/denied/corrupt only after slot capture.

expected: D output opcode, size, source and all 64 data bits equal those of the oldest captured auto_out D beat. On each D capture, the stored output param, sink, denied and corrupt fields are all zero; after those slots are initialized these fields remain zero for their contents. D payload stays stable while valid and stalled. Invalid output payload is not automatically zeroed; it reflects the current read slot, including retained earlier data.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates only at rising edges. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T7

test_id: T7

feature_ids: ["F7"]

requirement_ids: ["R-dv-024-007"]

stimulus: Initialize all native inputs, generate a 10 ns clock and synchronous reset, then initialize both payload slots before judging invalid payload numerically. Drive at falling edges; enforce the complete legal TileLink domain, source uniqueness, multibeat headers and stalled-payload retention. A downstream port agent returns matching acknowledgment source/size/opcode only for accepted outgoing requests and provides independently generated response data. Independently stall each direction while the other progresses, then drive both directions together. Exercise sizes 4..6 with correct per-message beat counts and verify no loss/duplication/reordering.

expected: The A and D FIFO storage, occupancy, enqueue, dequeue and backpressure decisions are independent. Fullness or stalling in one direction cannot directly gate the other direction. Both directions may capture/remove beats simultaneously at the same rising edge. A FIFO stores each message beat rather than assembling a transaction, changing beat count, changing source IDs or interpreting addresses; legal multibeat payload ordering is preserved.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates only at rising edges. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T8

test_id: T8

feature_ids: ["F8"]

requirement_ids: ["R-dv-024-008"]

stimulus: Initialize all native inputs, generate a 10 ns clock and synchronous reset, then initialize both payload slots before judging invalid payload numerically. Drive at falling edges; enforce the complete legal TileLink domain, source uniqueness, multibeat headers and stalled-payload retention. A downstream port agent returns matching acknowledgment source/size/opcode only for accepted outgoing requests and provides independently generated response data. Initialize two distinct payloads per FIFO, drain to empty and inspect read-slot payload, wrap and reset both positions, then capture during reset from a nonfull state. Keep unknown/uninitialized numerical values out of obligated comparisons.

expected: Each FIFO has two persistent payload slots. Its write position advances modulo two only on accepted input beats; its read position advances modulo two only on accepted output beats. Non-reset simultaneous enqueue/dequeue advances both. Output payload continuously reflects the slot at the current read position, even while empty; after removing the last beat, it can therefore switch to the other slot's retained or uninitialized data. Reset returns both positions to slot zero without clearing its payload. Numerical comparisons before a slot's first initialization are outside the required domain; do not infer payload-zeroing from reset or valid low.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates only at rising edges. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv
