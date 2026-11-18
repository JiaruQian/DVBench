# TLPLIC behavioral specification

The complete original native root and all listed dependencies are in scope.

### R-dv-025-001 — Native domain and timing

This is the complete native single-clock TileLink endpoint with synchronous active-high reset and a one-entry response metadata queue. Legal active requests outside reset have opcode 0 (PutFull), 1 (PutPartial) or 4 (Get), param zero, corrupt zero, source 0..767, address[27:26]=3, size 0..3 for 1,2,4,8 bytes and naturally aligned addresses. The mask is contained within addressed byte lanes; Get and PutFull select every addressed lane. A stalled A request holds valid and all payload until acceptance. Reuse a source only after its previous response completes. Assertions in the native monitors remain enabled. Observe settled combinational outputs; state updates at rising clock edges. There are no interrupt inputs, interrupt outputs or external interrupt state in this elaboration.

### R-dv-025-002 — Queue reset and empty/full state

A rising edge with reset high clears response occupancy to empty, overriding enqueue and dequeue for occupancy. Afterwards A ready is one and D valid is zero. Reset does not initialize the stored response opcode/source/size. Its combinational outputs are not directly gated by reset before a rising edge. Reset can discard a pending response.

### R-dv-025-003 — Request acceptance and enqueue latency

A ready is one exactly when response occupancy is empty. With empty occupancy and A valid one, the next rising edge captures the request metadata and makes the response full, unless reset clears occupancy. A request cannot flow through to D in the same cycle: D valid reflects previously stored occupancy. D ready does not affect A ready while empty.

### R-dv-025-004 — Response dequeue and full-queue backpressure

D valid is one exactly while occupied. A ready remains zero while full even when D ready is one, so a full queue cannot replace a response and enqueue another request on the same edge. A full queue with D ready one becomes empty at the next rising edge; with D ready zero it remains full. Incoming A valid and payload cannot overwrite a full response.

### R-dv-025-005 — Response opcode

Each captured request produces D opcode one for Get opcode four and D opcode zero for either legal write opcode. The read/write classification is captured on enqueue and retained through stalls, dequeue and empty cycles until another capture; the current input opcode does not bypass the stored classification.

### R-dv-025-006 — Response source and size

D source and D size equal the source and size captured with the queued request. They retain all declared bits, are not recoded, and remain stable while D is stalled. After dequeue these metadata outputs retain their previous values until another empty-queue capture. Varying current A source or size while full cannot change the stored response.

### R-dv-025-007 — Constant data and payload independence

D data is the constant 64-bit zero at all times, including reset, invalid cycles, reads and writes. Request data, mask and address have no effect on any public functional output, subject to the legal protocol domain. No memory contents, interrupt enable registers, priority registers or read/write side effects are observable on this native interface.

### R-dv-025-008 — Metadata capture during reset and invalid cycles

The metadata storage has no reset and its capture condition uses pre-edge empty occupancy and A valid, independently of reset. Consequently a request presented while reset high and occupancy already empty can update stored opcode/source/size at that edge while occupancy remains empty. A reset edge encountered while previously full clears occupancy but cannot capture metadata on that same edge. Without an eligible capture, metadata retains its value even during reset; before its first capture numerical metadata is unspecified. Invalid cycles never create a response or alter stored metadata.
