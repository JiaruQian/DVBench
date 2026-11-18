### T-001
test_id: T-001
feature_ids: F-001
requirement_ids: R-dv-020-001
stimulus: First complete initialization and enqueue requests.; Separately apply reset between edges, hold it across edges, and apply reset with outstanding read/write items; resend after deassertion.
expected: Cancel only in-flight transactions internal to the controller; asynchronous ports reset immediately, followed by full initialization.
checker: Generate expectations using an independent transaction queue/event calendar; perform four-state comparisons of valid outputs, comparing both write drive and undriven Z; report UVM_ERROR on a mismatch and require transactions to drain. Actual sampling window for this test: assertion between edges takes effect immediately; full initialization is performed again after deassertion.
implementation_id: V-001
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-002
test_id: T-002
feature_ids: F-002
requirement_ids: R-dv-020-002
stimulus: Reset deasserted, operations inactive.; During initialization, enqueue continuously until both entries are full, hold the third item until fullness clears, and cover dequeue on the same edge while full; separately toggle az_cs and exercise both operations.
expected: An independent two-entry queue processes items in first-in, first-out order, with write priority and no loss or duplication of accepted items.
checker: An independent transaction queue/event calendar generates expectations; valid outputs are compared using four-state comparison, including both write drive and undriven Z; mismatches report UVM_ERROR, and transaction draining is required. Actual sampling window for this test: acceptance is determined by the full flag before the edge; enqueueing does not mean SDRAM completion, and there is no empty-queue combinational bypass.
implementation_id: V-002
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-003
test_id: T-003
feature_ids: F-003
requirement_ids: R-dv-020-003
stimulus: Complete natural initialization, with space available in the queue.; Enqueue reads and writes one by one across bank/row/column boundaries, and apply all four write masks.
expected: Independently decompose the address arithmetically; commands correspond to the row, column, bank, and mask, without determining expectations from DUT internal signals.
checker: An independent transaction queue/event calendar generates expectations; valid outputs are compared using four-state comparison, including both write drive and undriven Z; mismatches report UVM_ERROR, and transaction draining is required. Actual sampling window for this test: commands/addresses/masks take effect through registers after the source rising edge; sample at least 1ns later.
implementation_id: V-003
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-004
test_id: T-004
feature_ids: F-004
requirement_ids: R-dv-020-004
stimulus: Assert asynchronous reset, with operations inactive or at most two entries filling the queue.; After release, run for at least 5020 complete edges, recording PRE, two REF commands, MRS, and the earliest main scheduling time.
expected: An independent edge-count calendar predicts all initialization commands and the MRS address.
checker: An independent transaction queue/event calendar generates expectations; valid outputs are compared using four-state comparison, including both write drive and undriven Z; mismatches report UVM_ERROR, and transaction draining is required. Actual sampling window for this test: counted edge 1 is the first rising edge after reset_n is released; commands are the values after that edge. During initialization, the address becomes fff on the first edge, MRS030 lasts only one command cycle, and fff follows.
implementation_id: V-004
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-005
test_id: T-005
feature_ids: F-005
requirement_ids: R-dv-020-005
stimulus: Complete initialization and hold legal requests until accepted.; Perform consecutive column writes/reads in the same direction within the same row, insert gaps, and drain the queue tail; use distinct write data to distinguish active/the next entry.
expected: An independent queue and command schedule predict ACT→NOP→column, per-entry data and addresses, and no duplicated tail entry.
checker: An independent transaction queue/event calendar generates expectations; valid outputs are compared using four-state comparison, including both write drive and undriven Z; mismatches report UVM_ERROR, and transaction draining is required. Actual sampling window for this test: the interval from enqueueing to fetching is affected by initialization, the queue, refresh, and the preceding entry, with no fixed total latency; use the main fetch edge or an observable ACT as the timing anchor.
implementation_id: V-005
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-006
test_id: T-006
feature_ids: F-006
requirement_ids: R-dv-020-006
stimulus: Use the first transaction to establish an open row and wait for draining.; After an idle interval, hit the same row, then change direction/bank/row, and compare the complete command sequence and column transactions.
expected: A matching continuation omits ACT; a mismatch issues PRE before ACT, without losing queued entries.
checker: An independent transaction queue/event calendar generates expectations; valid outputs are compared using four-state comparison, including both write drive and undriven Z; mismatches report UVM_ERROR, and transaction draining is required. Actual sampling window for this test: an empty queue does not cause automatic precharge; a new matching request performs a column access on the edge after it is fetched.
implementation_id: V-006
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-007
test_id: T-007
feature_ids: F-007
requirement_ids: R-dv-020-007
stimulus: Complete initialization; the external-port fixture supplies independent known read data.; Drive distinct read-return data, covering consecutive and intermittent READ commands, and assert asynchronous reset while the pipeline is occupied.
expected: An independent READ event queue applies a delay of 4 edges, without using DUT za_valid/data as the expectation.
checker: An independent transaction queue/event calendar generates expectations; valid outputs are compared using four-state comparison, including both write drive and undriven Z; mismatches report UVM_ERROR, and transaction draining is required. Actual sampling window for this test: external read values on DQ must be stable before the sampling edge and must not conflict with controller write drive; compare responses 1ns after the edge.
implementation_id: V-007
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write

### T-008
test_id: T-008
feature_ids: F-008
requirement_ids: R-dv-020-008
stimulus: Run naturally for more than 5783 edges, keeping requests in the same direction and same row continuously present in the queue near expiration.; Naturally cross a refresh while idle, during a read stream, during a write stream, and while holding a row open, respectively; hold source requests, then drain.
expected: Use an independent cycle calendar and requests awaiting service to check PRE/REF and wait lengths; resume all accepted entries in order.
checker: An independent transaction queue/event calendar generates expectations; valid outputs are compared using four-state comparison, including both write drive and undriven Z; mismatches report UVM_ERROR, and transaction draining is required. Actual sampling window for this test: request is registered on the expiration edge and seen by control on the next edge; service reads the old ack, so request/ack cannot be cleared on the same edge.
implementation_id: V-008
source: reference_pkg.sv:reference_sequence.body;reference_scoreboard.write;reference_checker.write
