### F-001
feature_id: F-001
requirement_ids: R-dv-020-001
module: montre_sdram
definition: reset_n is an active-low asynchronous reset: queue occupancy is cleared to 0, in-flight requests and read returns are canceled, za_valid/data=0, command 1111, address bank mask=0, DQ is high-impedance, and cke is constantly 1. External memory contents are not cleared; read and write operations must remain inactive while reset is low.
interface: clk, reset_n, az_rd_n, az_wr_n, za_valid, za_data, za_waitrequest, zs_addr, zs_ba, zs_cs_n, zs_ras_n, zs_cas_n, zs_we_n, zs_dqm, zs_dq, zs_cke
timing: Assertion between edges takes effect immediately; full initialization is performed again after deassertion.
boundary: Reset during initialization, queuing, commands, or the read pipeline cancels them all; non-reset data registers are valid only after legal preparation.

### F-002
feature_id: F-002
requirement_ids: R-dv-020-002
module: montre_sdram
definition: At each rising edge, one item is accepted if (!az_wr_n or !az_rd_n) and waitrequest=0 before the edge; az_cs does not gate acceptance, and items can also be accepted during initialization/refresh. Both operations low simultaneously are encoded as a write. waitrequest only indicates that the two-entry FIFO is full; when full, no new item is accepted even if a dequeue occurs on the same edge. The source holds the request while full until it is accepted.
interface: clk, reset_n, az_cs, az_addr, az_be_n, az_data, az_rd_n, az_wr_n, za_waitrequest
timing: Acceptance is determined by the full flag before the edge; enqueueing does not mean SDRAM completion, and there is no empty-queue combinational bypass.
boundary: Continuous assertion causes acceptance on every non-full edge; empty/one-entry/two-entry states, dequeue while full, different az_cs values, and both operations are all defined.

### F-003
feature_id: F-003
requirement_ids: R-dv-020-003
module: montre_sdram
definition: The 22-bit word address maps to bank={addr21,addr8}, row=addr20:9, column=addr7:0. ACT outputs the row and bank; the upper 4 address bits of column commands are 0. The write mask is az_be_n, with 1 indicating masking of the corresponding byte; the read command mask is 00.
interface: az_addr, az_be_n, az_data, az_wr_n, zs_addr, zs_ba, zs_dqm, zs_dq, zs_cs_n, zs_ras_n, zs_cas_n, zs_we_n, clk
timing: Command/address/mask take effect as registered values after the source rising edge; sample at least 1ns later.
boundary: 4 banks, rows 0/fff, columns 0/ff and address boundaries, masks 00/01/10/11.

### F-004
feature_id: F-004
requirement_ids: R-dv-020-004
module: montre_sdram
definition: Count natural clock edges after reset deassertion: after edge 5003, issue precharge-all command 0010; after edges 5005 and 5009, issue refresh 0001 once each; after edge 5013, issue mode set 0000 with address 030, with NOP0111 in between; before this, INHIBIT1111. Main scheduling starts at edge 5018. Initialization does not clear requests already enqueued.
interface: clk, reset_n, zs_cs_n, zs_ras_n, zs_cas_n, zs_we_n, zs_addr, zs_cke
timing: Count edge 1 as the first rising edge after reset_n is deasserted; commands are the values after the corresponding edge. During initialization, the address changes to fff on the first edge; MRS030 lasts only one command cycle, followed by fff.
boundary: Must wait 5000 source edges; forcing the count or using acceleration macros is not allowed; cke is always 1.

### F-005
feature_id: F-005
requirement_ids: R-dv-020-005
module: montre_sdram
definition: On the edge after the main control fetches the first item, output ACT0011; on the next edge, NOP; on the next edge, the first READ0101 or WRITE0100. Drive the corresponding data during a write command, and be high-impedance otherwise. For the same direction/bank/row, consecutive column commands can be issued on successive edges; after the prefetched tail item is consumed, the last item must not be issued repeatedly.
interface: clk, az_addr, az_data, az_rd_n, az_wr_n, zs_addr, zs_ba, zs_dq, zs_dqm, zs_cs_n, zs_ras_n, zs_cas_n, zs_we_n, za_waitrequest
timing: The interval from enqueue to fetch is affected by initialization, the queue, refresh, and the preceding item, with no fixed total latency; use the main fetch edge or an observable ACT as the timing anchor.
boundary: Single item, two items, continuous stream, and queue-tail draining; DQ is driven only when write is enabled, read returns are provided externally, and bus contention is prohibited.

### F-006
feature_id: F-006
requirement_ids: R-dv-020-006
module: montre_sdram
definition: After draining, keep the row open and issue NOP; subsequent requests with the same direction/bank/row issue column commands directly, without a new ACT. On a direction, row, or bank mismatch, go through recovery NOP, precharge-all with address fff, and a wait, then fetch again and issue ACT; retain only one open-row context.
interface: clk, az_addr, az_rd_n, az_wr_n, zs_addr, zs_ba, zs_cs_n, zs_ras_n, zs_cas_n, zs_we_n
timing: An empty queue does not precharge on its own; a new matching request accesses the column on the next edge after being fetched.
boundary: All direction changes, bank/row changes, and same-row hits after idle are defined; FIFO order is not rearranged.

### F-007
feature_id: F-007
requirement_ids: R-dv-020-007
module: montre_sdram
definition: Using the first READ output after edge E as the anchor, after edge E+4, za_valid is 1 and za_data equals DQ before edge E+4; consecutive READs correspond to consecutive valid assertions. za_data still samples DQ when invalid, but does not constitute a response. There is no response ready; the consumer must accept every valid.
interface: clk, reset_n, za_valid, za_data, zs_dq, zs_cs_n, zs_ras_n, zs_cas_n, zs_we_n
timing: The external read value on DQ must be stable before the sampling edge and must not conflict with the controller's write drive; compare the response 1ns after the edge.
boundary: Single read, back-to-back reads, intermittent reads, and reset cancellation of the read pipeline; X/Z in a valid response is an error, and non-valid data is not checked.

### F-008
feature_id: F-008
requirement_ids: R-dv-020-008
module: montre_sdram
definition: After a startup count of 5000, expiry occurs steadily every 782 edges; the first operational refresh request is generated on edge 5783 after deassertion and remains asserted until serviced. When idle, prioritize precharge-all followed by REF; after refresh, wait for 3 WAIT execution edges before scheduling again. On encountering refresh, a read stream exits using 2 WAIT edges, a write stream uses 1, and the row-retention state uses 1. Refresh does not clear the FIFO; enqueueing is still limited only by fullness.
interface: clk, reset_n, az_rd_n, az_wr_n, az_addr, za_waitrequest, zs_addr, zs_cs_n, zs_ras_n, zs_cas_n, zs_we_n
timing: request is registered on the expiry edge and seen by control on the next edge; servicing reads the old ack, and request/ack must not be cleared on the same edge.
boundary: Cover idle, row retention, continuous reads, and continuous writes separately; forcing the internal refresh count is not allowed.
