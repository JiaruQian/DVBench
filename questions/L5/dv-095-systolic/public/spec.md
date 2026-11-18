# systolic_top Behavioral Contract

Version 1.0.0; only the fixed native default configuration. Both inputs and outputs interact through public ports.

### R-N115-001 — Synchronous Hard Reset and Soft Cancellation

Fixed 8x8, INT8 inputs and INT32 results, with no overridable parameters. High rst resets the CSR and controller/array only on a rising edge: clear start, done, irq_en, tilecount, and AXIL pending/valid, with the core idle; reset behavior for the contents of the A/B/C buffers is not guaranteed. Writing 1 to CTRL bit1 generates a one-cycle soft_reset; on the next edge, it only cancels the controller/array and clears start, while CSR accumulation/IRQ configuration is retained.

### R-N115-002 — AXIL Independent Write Channels

AW/W each have a single-entry buffer and may be accepted in either order: awready=!aw_pending, wready=!w_pending. Commit on the next edge when both entries are already present and bvalid=0; bresp is always OKAY=0; bvalid is held until bready. The next address/data pair can still be captured during the response, but is not committed until the response is cleared. wstrb is completely ignored, including 0; addresses must match exactly, with no alignment aliases.

### R-N115-003 — AXIL Reads and Stable Responses

arready=!ar_pending&&!rvalid; on the next edge after AR is accepted, sample the register value and assert rvalid. rresp is always 0, and rdata/rvalid are held until rready. The next AR is not accepted until the response is accepted. Unknown/unaligned addresses read as 0; writes are ignored but receive normal responses. Check rdata only when rvalid is asserted.

### R-N115-004 — CSR Map and Priorities

0x00 CTRL bit0=start level; writing bit0 is allowed only when the core is idle; bit1 soft reset takes priority and clears start. 0x04 STATUS busy[0],sticky_done[1],overflow[2]=0; writing 1 to bit1 clears done. 0x08 read-only tilecount increments by 1 modulo 2^32 on each completion; 0x0c IRQ_EN bit0; 0x10 VERSION=0x10000. A done event takes priority over a bus write on the same edge: clear start, set sticky, tilecount++. irq=IRQ_EN&&sticky_done, not gated by busy state.

### R-N115-005 — Full-Tile Reception on Dual Inputs

The start level is accepted on an idle edge, after which busy=1 and reception is enabled. A is ready only during RECV and when fewer than 8 rows have been received; B can be received during RECV/the eight-cycle LOAD/WAIT_B stages, and is ready when fewer than 8 rows have been received. A row is received only on valid&&ready; the two streams are independent and may contain bubbles. tlast only diagnoses the expected 8th row and does not change the mathematical result or FSM. Only on the next edge after all of A has been received does the eight-cycle LOAD begin; if B has fewer than 8 rows, wait, and never compute a partial tile.

### R-N115-006 — Signed 8x8 Matrix Multiplication

Each 64-bit beat of A/B is one row, with little-endian bytes: element j is at [8j+:8], and all elements are two's-complement signed INT8. C[r][c]=sum(k=0..7,A[r][k]*B[k][c]), in 32-bit two's complement without saturation; no transpose, activation, or bias addition. Each 256-bit output is one row of C, with element j at [32j+:32], in row order 0 through 7.

### R-N115-007 — Load and Compute Timing

After all of A has been received, one additional cycle elapses before entering LOAD; LOAD lasts exactly 8 cycles. On the final LOAD edge, start COMPUTE if B is already complete; otherwise, WAIT_B observes the old count until it is complete. COMPUTE lasts a fixed 23 cycles (0..22), and OUTPUT is entered in the next cycle. busy includes all non-idle stages and one cycle of DONE. The cycle after the 8th C handshake is DONE; on the next edge, return to idle and make the CSR completion event take effect; start is automatically cleared at this point.

### R-N115-008 — Output Backpressure and Transaction Isolation

Output valid remains asserted until all 8 rows have been accepted through valid&&ready. tlast is asserted only for the 8th row; data/last remain stable during stalls, and the row increments only on a handshake. A/B are not accepted during output, and completion does not occur early. There is no obligation to check C data when valid=0; the next tile must receive all of A/B anew, without mixing in previous tiles.
