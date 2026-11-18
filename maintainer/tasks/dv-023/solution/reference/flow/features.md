## F-FIFO-001

**requirement_ids**: ["R-dv-023-fifo-001"]

**module**: fifo

**definition**: rst is asynchronous and active high; upon assertion, full is 0, empty is 1, and both logical positions return to their starting points. After reset is released, operation follows subsequent clocks and requests. Reset empties the logical queue but does not clear storage contents; keep we and re at 0 during reset.

**interface**: ["rst", "w_clk", "r_clk", "full", "empty"]

**timing**: Decisions on the relevant rising edges use pre-edge values; asynchronous reset assertion takes effect immediately; port behavior is evaluated after the status and combinational outputs of the corresponding event have settled.

**boundary**: Fixed ADDR=16 and BIT_WIDTH=8; no valid-value guarantee is made for data in empty/uninitialized slots; the standalone UART is not included.

## F-FIFO-002

**requirement_ids**: ["R-dv-023-fifo-002"]

**module**: fifo

**definition**: On each w_clk rising edge, evaluate the we request using the pre-edge full value; when we is 1 and full is 0, accept wdata and advance the logical write position; otherwise, do not write or advance. The capacity is 16 8-bit data items, and positions wrap modulo 16. After 16 consecutive accepted writes without any advance of the read position, full becomes 1; additional writes while full must not overwrite stored data.

**interface**: ["w_clk", "we", "wdata", "full"]

**timing**: Decisions on the relevant rising edges use pre-edge values; asynchronous reset assertion takes effect immediately; port behavior is evaluated after the status and combinational outputs of the corresponding event have settled.

**boundary**: Fixed ADDR=16 and BIT_WIDTH=8; no valid-value guarantee is made for data in empty/uninitialized slots; the standalone UART is not included.

## F-FIFO-003

**requirement_ids**: ["R-dv-023-fifo-003"]

**module**: fifo

**definition**: On each r_clk rising edge, evaluate the re request using the pre-edge empty value; when re is 1 and empty is 0, advance the logical read position by one item; otherwise, hold it. rdata combinationally reflects the data at the current logical read position; it is not registered on the r_clk edge and is not gated by re. When empty is 0 and that slot has been written, its value must equal the data from the corresponding most recent accepted write; no valid-value guarantee is made for data in the empty state or in unwritten slots.

**interface**: ["r_clk", "re", "rdata", "empty"]

**timing**: Decisions on the relevant rising edges use pre-edge values; asynchronous reset assertion takes effect immediately; port behavior is evaluated after the status and combinational outputs of the corresponding event have settled.

**boundary**: Fixed ADDR=16 and BIT_WIDTH=8; no valid-value guarantee is made for data in empty/uninitialized slots; the standalone UART is not included.

## F-FIFO-004

**requirement_ids**: ["R-dv-023-fifo-004"]

**module**: fifo

**definition**: full and empty update only on w_clk rising edges or asynchronous reset; an r_clk edge alone does not directly update either flag. When we and re are both 0, the flags hold. When only we is 1, clear empty if the write is accepted; compare this edge's candidate write position with the current read position modulo 16, set full if they are equal, and otherwise retain the original full. When only re is 1, clear full if nonempty before the edge; compare the current write position with the candidate read position calculated from pre-edge empty and re modulo 16, set empty if they are equal, and otherwise retain the original empty. Here, the candidate read position anticipates one acceptable read request, even if there is no r_clk rising edge at this time; the actual read position still advances only on r_clk rising edges.

**interface**: ["w_clk", "r_clk", "we", "re", "full", "empty"]

**timing**: Decisions on the relevant rising edges use pre-edge values; asynchronous reset assertion takes effect immediately; port behavior is evaluated after the status and combinational outputs of the corresponding event have settled.

**boundary**: Fixed ADDR=16 and BIT_WIDTH=8; no valid-value guarantee is made for data in empty/uninitialized slots; the standalone UART is not included.

## F-FIFO-005

**requirement_ids**: ["R-dv-023-fifo-005"]

**module**: fifo

**definition**: When we and re are both 1: if full before the edge, only the read position is allowed to advance on the r_clk edge, the write is rejected, and full is cleared on the w_clk edge; if empty before the edge, only the write position is allowed to advance on the w_clk edge, the read is rejected, and empty is cleared on the w_clk edge; if neither full nor empty, each side advances on its own rising edge, while full and empty hold. If both clocks rise simultaneously, every decision uses the pre-edge status and logical positions at that same instant, not values newly updated by the other clock at that instant.

**interface**: ["w_clk", "r_clk", "we", "re", "full", "empty"]

**timing**: Decisions on the relevant rising edges use pre-edge values; asynchronous reset assertion takes effect immediately; port behavior is evaluated after the status and combinational outputs of the corresponding event have settled.

**boundary**: Fixed ADDR=16 and BIT_WIDTH=8; no valid-value guarantee is made for data in empty/uninitialized slots; the standalone UART is not included.

## F-FIFO-006

**requirement_ids**: ["R-dv-023-fifo-006"]

**module**: fifo

**definition**: w_clk and r_clk may operate independently; inputs are stable before and after the relevant sampling edges, and port comparisons are performed after the status and combinational outputs have settled within the same time step. The behavior specified here is ideal digital timing behavior; CDC synchronization, metastability tolerance, or latency guarantees of a standard asynchronous FIFO are not required. The above update rules for full and empty apply to different frequencies, phases, and coincident rising edges.

**interface**: ["w_clk", "r_clk", "rst", "we", "re", "wdata", "rdata", "full", "empty"]

**timing**: Decisions on the relevant rising edges use pre-edge values; asynchronous reset assertion takes effect immediately; port behavior is evaluated after the status and combinational outputs of the corresponding event have settled.

**boundary**: Fixed ADDR=16 and BIT_WIDTH=8; no valid-value guarantee is made for data in empty/uninitialized slots; the standalone UART is not included.
