# montre_sdram

This task specifies native port behavior according to a fixed functional simulation implementation. See ports.md for ports and fixed parameters. Use four-state checks within the defined domains below; unspecified domains must not be used to report errors.

### R-dv-020-001 — Asynchronous Reset and Cancellation

reset_n is an active-low asynchronous reset: queue occupancy is cleared to 0, in-flight requests and read returns are canceled, za_valid/data=0, command 1111, address/bank/mask=0, DQ is high-impedance, and cke is constantly 1. External memory contents are not cleared; read and write operations must remain inactive while reset is low.

Assertion between edges takes effect immediately; after deassertion, the complete initialization sequence is performed again.

Reset during initialization, queuing, commands, or the read pipeline cancels them all; non-reset data registers are valid only after legal preparation.

### R-dv-020-002 — Acceptance, Two-Entry FIFO, and Write Priority

One entry is accepted on each rising edge when (!az_wr_n or !az_rd_n) and waitrequest=0 before the edge; az_cs does not gate acceptance, and acceptance is also allowed during initialization/refresh. Both operations low simultaneously encode a write. waitrequest indicates only that the two-entry FIFO is full; when full, no new entry is accepted even if a dequeue occurs on the same edge. When full, the source holds its request until it is accepted.

Acceptance is determined by the full flag before the edge; enqueuing does not mean that SDRAM has completed the operation, and there is no combinational bypass for an empty queue.

Continuously asserted valid requests are accepted on every non-full edge; empty/one-entry/two-entry states, dequeue while full, different az_cs values, and simultaneous operations are all defined.

### R-dv-020-003 — Word Address, Row/Bank, and Mask

The 22-bit word address maps to bank={addr21,addr8}, row=addr20:9, and column=addr7:0. ACT outputs the row and bank, and the upper 4 address bits of column commands are 0. The write mask is az_be_n, with 1 indicating that the corresponding byte is masked; the read command mask is 00.

Command/address/mask take effect as registered values after the source rising edge; sample at least 1ns later.

4 banks, rows 0/fff, columns 0/ff, and address boundaries; masks 00/01/10/11.

### R-dv-020-004 — Initialization Command Calendar

Count natural clock edges after reset deassertion: after edge 5003, issue precharge-all command 0010; after edges 5005 and 5009, issue one refresh 0001 each; after edge 5013, issue mode set 0000 with address 030, with NOP0111 in between; before these, issue INHIBIT1111. Main scheduling begins at edge 5018. Initialization does not clear enqueued requests.

Edge 1 is the first rising edge after reset_n deassertion; the command is the value after that edge. During initialization, the address changes to fff on the first edge; MRS030 lasts only one command cycle, followed by fff.

The 5000 source edges must be waited out; forcing the counter or using acceleration macros is not allowed; cke is always 1.

### R-dv-020-005 — Activation, Column Access, and the Tail Entry

The edge after the main controller fetches the first entry outputs ACT0011, the next edge outputs NOP, and the next edge outputs the first READ0101 or WRITE0100. The corresponding data is driven during a write command; at all other times, the bus is high-impedance. For the same direction/bank/row, column commands can be consecutive on every edge; after the prefetched tail entry is consumed, the final entry must not be issued again.

The interval from enqueue to fetch is affected by initialization, the queue, refresh, and preceding entries, so there is no fixed total latency; use the main fetch edge or an observable ACT as the timing anchor.

Single entry, two entries, continuous streams, and queue-tail draining; DQ is driven only when write enable is active, read returns are provided externally, and bus contention is prohibited.

### R-dv-020-006 — Open-Row Retention and Mismatch Switching

After draining, keep the row open and issue NOP; subsequent requests with the same direction/bank/row issue column commands directly, without a new ACT. A direction, row, or bank mismatch goes through recovery NOP, precharge-all with address fff, and a wait, then fetches again and issues ACT; only one open-row context is retained.

An empty queue does not initiate precharge on its own; a new matching request performs a column access on the edge after it is fetched.

All direction switches, bank/row switches, and same-row hits after idle are defined; FIFO order is not rearranged.

### R-dv-020-007 — Read-Return Valid Window

Using the first READ output after edge E as the anchor, after edge E+4, za_valid is 1 and za_data equals DQ before edge E+4; consecutive READs correspond to consecutive valid cycles. za_data still samples DQ when invalid, but is not treated as a response. There is no response ready; the consumer must accept every valid response.

External read values on DQ must be stable before the sampling edge and must not conflict with the controller's write drive; compare responses 1ns after the edge.

Single reads, back-to-back reads, intermittent reads, and reset cancellation of the read pipeline; X/Z in a valid response is an error, and data when not valid is not checked.

### R-dv-020-008 — Natural Refresh and Recovery

After the startup count of 5000, refresh becomes due steadily once every 782 edges; the first operational refresh request is generated on edge 5783 after deassertion and remains asserted until serviced. When idle, prioritize precharge-all followed by REF; after refresh, wait for 3 WAIT execution edges before scheduling again. A read stream exits for refresh using 2 WAIT edges, a write stream uses 1, and the row-retention state uses 1. Refresh does not clear the FIFO, and enqueuing is still restricted only by full status.

The request is registered on the due edge and is seen by control on the next edge; servicing reads the old ack, and request/ack must not be cleared on the same edge.

Cover idle, row retention, continuous reads, and continuous writes separately; forcing the internal refresh counter is not allowed.
