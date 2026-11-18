# SRAM Multi-Request-Port Arbiter

The target module is prim_sram_arbiter, which selects among multiple request ports to produce a single SRAM command stream and routes the returned valid according to the history of accepted read owners; it does not include an SRAM storage array.

### R-dv-017-sram-arbiter-001 — Combinational Round-Robin Arbitration

sram_req_o combinationally equals the OR of all bits of req_i. When there are no requests, gnt_o is all zeros; when there are requests, exactly one bit is set and its corresponding request is valid. After reset, the lowest index has priority. After each rising edge of clk_i with a request present, the next selection first considers requests at higher indices following the current winner; if there are none, it wraps around to the lowest index. Idle edges retain the next priority. The read/write type does not change arbitration priority. There is no SRAM ready or backpressure; one command is issued on every rising edge with a request present. Requests may change between acceptance edges, and remaining high allows commands to be formed repeatedly on subsequent edges.

### R-dv-017-sram-arbiter-002 — Command Fields and Mask

During a valid command window in which sram_req_o is 1, sram_addr_o, sram_write_o, and sram_wdata_o equal the granted port's req_addr_i, req_write_i, and req_wdata_i, respectively. When EnMask=1, sram_wmask_o equals the granted port's req_wmask_i; when EnMask=0, sram_wmask_o for a valid command is all ones. When there is no request, the command payload does not belong to a valid command, and no functional requirements apply to these payload fields.

### R-dv-017-sram-arbiter-003 — Read Response Routing by Acceptance History

Only read commands retain the granted port as an outstanding read owner; write commands do not retain an owner. Except for the first edge after reset deassertion and windows in which capacity is full, read owners are added to an ordered queue on the rising edge of clk_i. When the queue is nonempty and sram_rvalid_i is 1, rsp_rvalid_o combinationally equals the one-hot vector of the oldest owner, and that owner is removed on that rising edge; when sram_rvalid_i is 0, rsp_rvalid_o is all zeros. An empty queue does not produce a port valid even if sram_rvalid_i is 1. Issuing a new read and receiving a return in the same cycle with an empty queue does not bypass the new owner; the new owner can become the queue head only after the acceptance edge.

### R-dv-017-sram-arbiter-004 — Four-Entry Capacity and Same-Cycle Boundaries

At most four outstanding read owners are retained. Read commands issued when four entries are already present still receive a grant and an SRAM request, but the new owner is discarded, with neither backpressure nor a dedicated error signal. Acceptance capacity is determined from the occupancy before the rising edge: if the queue was full and an old read returns in the same cycle as a new read is issued, the old owner is removed but the new owner is still discarded; if the queue was neither full nor empty, a simultaneous return and new read preserve occupancy, appending the new owner to the tail.

### R-dv-017-sram-arbiter-005 — Unconditional Data and Error Broadcasts

rsp_rdata_o of every port always combinationally equals sram_rdata_i, and rsp_error_o of every port always combinationally equals sram_rerror_i; all four two-bit error codes propagate unchanged. This broadcast relationship holds regardless of which owner is valid, whether any reads are outstanding, whether the returned valid is high or low, or whether reset is asserted. This module does not implement SRAM storage contents or correct error codes.

### R-dv-017-sram-arbiter-006 — Asynchronous Reset and the First Edge After Deassertion

A low rst_ni asserts asynchronous reset, clearing all read owners and restoring the next priority to the lowest index. Reset does not mask combinational requests or grant; a nonzero req_i during reset still produces sram_req_o and a one-hot gnt_o, but no read owner is retained. The first rising edge of clk_i after deassertion performs arbitration and advances priority, but does not accept a read owner; normal owner retention starts only at the second rising edge. Reset discards previously outstanding reads, and a return to an empty queue after reset does not produce a port valid.

### R-dv-017-sram-arbiter-007 — Fixed Parameter Domain and Timing

This problem includes three configurations: N=4, SramAw=12, SramDw=32, ArbiterImpl set to PPC, EnMask=0 (default); the same widths with N=4, PPC, EnMask=1; and N=2, the same address and data widths, BINTREE, EnMask=1. Both arbitration implementations follow the same round-robin and response contract, with masks handled according to EnMask. Other parameter points are outside the domain of this problem. Inputs are known two-state values and are stable around the accepting rising edge; combinational relationships are observable after stable inputs have propagated. The return stream is consumed in retained-owner order, without identifying the source from the data.

