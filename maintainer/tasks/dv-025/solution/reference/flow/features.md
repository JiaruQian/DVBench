# features

## F1

feature_id: F1

requirement_ids: ["R-dv-025-001"]

module: TLPLIC

definition: This is the complete native single-clock TileLink endpoint with synchronous active-high reset and a one-entry response metadata queue. Legal active requests outside reset have opcode 0 (PutFull), 1 (PutPartial) or 4 (Get), param zero, corrupt zero, source 0..767, address[27:26]=3, size 0..3 for 1,2,4,8 bytes and naturally aligned addresses. The mask is contained within addressed byte lanes; Get and PutFull select every addressed lane. A stalled A request holds valid and all payload until acceptance. Reuse a source only after its previous response completes. Assertions in the native monitors remain enabled. Observe settled combinational outputs; state updates at rising clock edges. There are no interrupt inputs, interrupt outputs or external interrupt state in this elaboration.

interface: ["clock", "reset", "auto_in_a_ready", "auto_in_a_valid", "auto_in_a_bits_opcode", "auto_in_a_bits_param", "auto_in_a_bits_size", "auto_in_a_bits_source", "auto_in_a_bits_address", "auto_in_a_bits_mask", "auto_in_a_bits_data", "auto_in_a_bits_corrupt", "auto_in_d_ready", "auto_in_d_valid", "auto_in_d_bits_opcode", "auto_in_d_bits_size", "auto_in_d_bits_source", "auto_in_d_bits_data"]

timing: Drive at falling edges, update at rising edges and sample after propagation settles.

boundary: Initialize all native inputs, generate a 10 ns clock, apply synchronous reset and first capture known metadata before numerical payload checks. Use only legal opcode 0/1/4, source 0..767 with no outstanding reuse, naturally aligned sizes 0..3, address top bits 3, zero param/corrupt and legal masks. Drive at falling edges and hold stalled request payload. Cross all legal sizes, source ranges, opcodes and byte lanes while checking endpoint timing and all outputs.

## F2

feature_id: F2

requirement_ids: ["R-dv-025-002"]

module: TLPLIC

definition: A rising edge with reset high clears response occupancy to empty, overriding enqueue and dequeue for occupancy. Afterwards A ready is one and D valid is zero. Reset does not initialize the stored response opcode/source/size. Its combinational outputs are not directly gated by reset before a rising edge. Reset can discard a pending response.

interface: ["clock", "reset", "auto_in_a_ready", "auto_in_a_valid", "auto_in_a_bits_opcode", "auto_in_a_bits_param", "auto_in_a_bits_size", "auto_in_a_bits_source", "auto_in_a_bits_address", "auto_in_a_bits_mask", "auto_in_a_bits_data", "auto_in_a_bits_corrupt", "auto_in_d_ready", "auto_in_d_valid", "auto_in_d_bits_opcode", "auto_in_d_bits_size", "auto_in_d_bits_source", "auto_in_d_bits_data"]

timing: Drive at falling edges, update at rising edges and sample after propagation settles.

boundary: Initialize all native inputs, generate a 10 ns clock, apply synchronous reset and first capture known metadata before numerical payload checks. Use only legal opcode 0/1/4, source 0..767 with no outstanding reuse, naturally aligned sizes 0..3, address top bits 3, zero param/corrupt and legal masks. Drive at falling edges and hold stalled request payload. Reset both empty and full queue, overlap reset with A valid and D ready, and observe occupancy after the reset edge with unchanged metadata where appropriate.

## F3

feature_id: F3

requirement_ids: ["R-dv-025-003"]

module: TLPLIC

definition: A ready is one exactly when response occupancy is empty. With empty occupancy and A valid one, the next rising edge captures the request metadata and makes the response full, unless reset clears occupancy. A request cannot flow through to D in the same cycle: D valid reflects previously stored occupancy. D ready does not affect A ready while empty.

interface: ["clock", "reset", "auto_in_a_ready", "auto_in_a_valid", "auto_in_a_bits_opcode", "auto_in_a_bits_param", "auto_in_a_bits_size", "auto_in_a_bits_source", "auto_in_a_bits_address", "auto_in_a_bits_mask", "auto_in_a_bits_data", "auto_in_a_bits_corrupt", "auto_in_d_ready", "auto_in_d_valid", "auto_in_d_bits_opcode", "auto_in_d_bits_size", "auto_in_d_bits_source", "auto_in_d_bits_data"]

timing: Drive at falling edges, update at rising edges and sample after propagation settles.

boundary: Initialize all native inputs, generate a 10 ns clock, apply synchronous reset and first capture known metadata before numerical payload checks. Use only legal opcode 0/1/4, source 0..767 with no outstanding reuse, naturally aligned sizes 0..3, address top bits 3, zero param/corrupt and legal masks. Drive at falling edges and hold stalled request payload. Enqueue into empty with D ready zero and one; check no combinational bypass, exact next-edge response latency and A ready independence from D ready while empty.

## F4

feature_id: F4

requirement_ids: ["R-dv-025-004"]

module: TLPLIC

definition: D valid is one exactly while occupied. A ready remains zero while full even when D ready is one, so a full queue cannot replace a response and enqueue another request on the same edge. A full queue with D ready one becomes empty at the next rising edge; with D ready zero it remains full. Incoming A valid and payload cannot overwrite a full response.

interface: ["clock", "reset", "auto_in_a_ready", "auto_in_a_valid", "auto_in_a_bits_opcode", "auto_in_a_bits_param", "auto_in_a_bits_size", "auto_in_a_bits_source", "auto_in_a_bits_address", "auto_in_a_bits_mask", "auto_in_a_bits_data", "auto_in_a_bits_corrupt", "auto_in_d_ready", "auto_in_d_valid", "auto_in_d_bits_opcode", "auto_in_d_bits_size", "auto_in_d_bits_source", "auto_in_d_bits_data"]

timing: Drive at falling edges, update at rising edges and sample after propagation settles.

boundary: Initialize all native inputs, generate a 10 ns clock, apply synchronous reset and first capture known metadata before numerical payload checks. Use only legal opcode 0/1/4, source 0..767 with no outstanding reuse, naturally aligned sizes 0..3, address top bits 3, zero param/corrupt and legal masks. Drive at falling edges and hold stalled request payload. Hold a response stalled for several cycles, offer a stable second request, then assert D ready; verify no same-edge replacement, one empty cycle, and no overwrite before the second request is accepted.

## F5

feature_id: F5

requirement_ids: ["R-dv-025-005"]

module: TLPLIC

definition: Each captured request produces D opcode one for Get opcode four and D opcode zero for either legal write opcode. The read/write classification is captured on enqueue and retained through stalls, dequeue and empty cycles until another capture; the current input opcode does not bypass the stored classification.

interface: ["clock", "reset", "auto_in_a_ready", "auto_in_a_valid", "auto_in_a_bits_opcode", "auto_in_a_bits_param", "auto_in_a_bits_size", "auto_in_a_bits_source", "auto_in_a_bits_address", "auto_in_a_bits_mask", "auto_in_a_bits_data", "auto_in_a_bits_corrupt", "auto_in_d_ready", "auto_in_d_valid", "auto_in_d_bits_opcode", "auto_in_d_bits_size", "auto_in_d_bits_source", "auto_in_d_bits_data"]

timing: Drive at falling edges, update at rising edges and sample after propagation settles.

boundary: Initialize all native inputs, generate a 10 ns clock, apply synchronous reset and first capture known metadata before numerical payload checks. Use only legal opcode 0/1/4, source 0..767 with no outstanding reuse, naturally aligned sizes 0..3, address top bits 3, zero param/corrupt and legal masks. Drive at falling edges and hold stalled request payload. Enqueue Get and both writes, vary the live input opcode while full and invalid, and check stored response classification before and after dequeue.

## F6

feature_id: F6

requirement_ids: ["R-dv-025-006"]

module: TLPLIC

definition: D source and D size equal the source and size captured with the queued request. They retain all declared bits, are not recoded, and remain stable while D is stalled. After dequeue these metadata outputs retain their previous values until another empty-queue capture. Varying current A source or size while full cannot change the stored response.

interface: ["clock", "reset", "auto_in_a_ready", "auto_in_a_valid", "auto_in_a_bits_opcode", "auto_in_a_bits_param", "auto_in_a_bits_size", "auto_in_a_bits_source", "auto_in_a_bits_address", "auto_in_a_bits_mask", "auto_in_a_bits_data", "auto_in_a_bits_corrupt", "auto_in_d_ready", "auto_in_d_valid", "auto_in_d_bits_opcode", "auto_in_d_bits_size", "auto_in_d_bits_source", "auto_in_d_bits_data"]

timing: Drive at falling edges, update at rising edges and sample after propagation settles.

boundary: Initialize all native inputs, generate a 10 ns clock, apply synchronous reset and first capture known metadata before numerical payload checks. Use only legal opcode 0/1/4, source 0..767 with no outstanding reuse, naturally aligned sizes 0..3, address top bits 3, zero param/corrupt and legal masks. Drive at falling edges and hold stalled request payload. Enqueue all four sizes and low/middle/high source values including 0,255,256,511,512,767; vary live metadata under full stalls and check all retained bits through dequeue.

## F7

feature_id: F7

requirement_ids: ["R-dv-025-007"]

module: TLPLIC

definition: D data is the constant 64-bit zero at all times, including reset, invalid cycles, reads and writes. Request data, mask and address have no effect on any public functional output, subject to the legal protocol domain. No memory contents, interrupt enable registers, priority registers or read/write side effects are observable on this native interface.

interface: ["clock", "reset", "auto_in_a_ready", "auto_in_a_valid", "auto_in_a_bits_opcode", "auto_in_a_bits_param", "auto_in_a_bits_size", "auto_in_a_bits_source", "auto_in_a_bits_address", "auto_in_a_bits_mask", "auto_in_a_bits_data", "auto_in_a_bits_corrupt", "auto_in_d_ready", "auto_in_d_valid", "auto_in_d_bits_opcode", "auto_in_d_bits_size", "auto_in_d_bits_source", "auto_in_d_bits_data"]

timing: Drive at falling edges, update at rising edges and sample after propagation settles.

boundary: Initialize all native inputs, generate a 10 ns clock, apply synchronous reset and first capture known metadata before numerical payload checks. Use only legal opcode 0/1/4, source 0..767 with no outstanding reuse, naturally aligned sizes 0..3, address top bits 3, zero param/corrupt and legal masks. Drive at falling edges and hold stalled request payload. Vary data across zero, all ones and mixed patterns, legal masks including partial zero, and several mapped-range addresses; check D data remains zero across reset, valid and invalid cycles.

## F8

feature_id: F8

requirement_ids: ["R-dv-025-008"]

module: TLPLIC

definition: The metadata storage has no reset and its capture condition uses pre-edge empty occupancy and A valid, independently of reset. Consequently a request presented while reset high and occupancy already empty can update stored opcode/source/size at that edge while occupancy remains empty. A reset edge encountered while previously full clears occupancy but cannot capture metadata on that same edge. Without an eligible capture, metadata retains its value even during reset; before its first capture numerical metadata is unspecified. Invalid cycles never create a response or alter stored metadata.

interface: ["clock", "reset", "auto_in_a_ready", "auto_in_a_valid", "auto_in_a_bits_opcode", "auto_in_a_bits_param", "auto_in_a_bits_size", "auto_in_a_bits_source", "auto_in_a_bits_address", "auto_in_a_bits_mask", "auto_in_a_bits_data", "auto_in_a_bits_corrupt", "auto_in_d_ready", "auto_in_d_valid", "auto_in_d_bits_opcode", "auto_in_d_bits_size", "auto_in_d_bits_source", "auto_in_d_bits_data"]

timing: Drive at falling edges, update at rising edges and sample after propagation settles.

boundary: Initialize all native inputs, generate a 10 ns clock, apply synchronous reset and first capture known metadata before numerical payload checks. Use only legal opcode 0/1/4, source 0..767 with no outstanding reuse, naturally aligned sizes 0..3, address top bits 3, zero param/corrupt and legal masks. Drive at falling edges and hold stalled request payload. Initialize metadata, clear occupancy, then capture different metadata under reset while already empty. Reset while full separately and verify old metadata retention. Vary invalid payloads without capture and check no metadata change.
