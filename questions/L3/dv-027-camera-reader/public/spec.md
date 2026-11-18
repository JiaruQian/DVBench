# sf_camera_reader Native Behavior Contract

Fixed parameters follow ports.md; native ports only, with the model predicting independently from inputs and history. Uninitialized registers/storage retain four-state undefined values; do not use internal force to establish state.

### R-dv-027-001 — Native dual clocks and independent resets

Pixel capture and counting operate on rising edges of i_pix_clk; FIFO reading and status synchronization operate on rising edges of clk. !i_camera_reset or !i_clk_locked clears capture, byte assembly, and pixel/row counts on a pixel rising edge. rst or !i_clk_locked synchronously resets the FIFO and cross-domain state, but rst does not directly reset pixel assembly/counting; resetting only the camera does not clear the FIFO either. After reset is deasserted on the FIFO write and read sides, each side must undergo 5 edges of its own clock domain before its internal reset wait ends. There is no asynchronous camera reset.

### R-dv-027-002 — Frame start, enable, and busy completion

When i_enable=1, capture is inactive, i_vsync=0, an empty bank has been allocated, and i_memory_ready=1, capture starts on the next pixel edge. i_vsync=0 and memory_ready=0 cancel capture; low i_enable only prevents starting and pixel reception and does not directly clear capture that has already started. High i_vsync sets busy to 1, regardless of enable; when vsync is low, busy is high, the FIFO is empty, and capture is still active, busy is cleared and a completion event is generated. The completion event becomes an o_captured pulse through a pixel-domain toggle and an XOR of a three-cycle shift in the clk domain. o_inactive is the clk-domain synchronized value of the FIFO all-empty state, updated after confirmation by two consecutive high/low history bits.

### R-dv-027-003 — Pixel byte assembly and cross-line history for short lines

Bytes are received only on pixel edges when capture has started, enable is high, a bank has been allocated, and hsync/vsync are both high. Four bytes are assembled into a 32-bit word with the first arrival in the high bits; when a group is complete, a two-stage pixel-cycle write is scheduled. If fewer than four bytes have been assembled and there is not yet a complete word, low hsync does not release the bank or clear the residual bytes, and assembly continues on the next line; if a complete word already exists, the bank is released and trailing bytes totaling fewer than four are discarded only when the hsync/vsync condition is not met and both stages of the write pipeline are empty. A new bank starts at byte position 0.

### R-dv-027-004 — Image debug patterns and repeated toggling

When debug is off, assembled pixels are output. When debug is on, the first word of a bank in phase 1 is 001F001F and the rest are 07D007D0; in phase 0, the first word is FFFFFFFF and the rest are F800F800. The phase toggles each time capture starts; when vsync is low and memory_ready is low, the phase toggles on every pixel edge. The phase is initially cleared to 0 by camera reset; the pattern's first word is determined by this bank's complete-word count being 0.

### R-dv-027-005 — Dual-bank capacity, saturation, and address wraparound

Fixed BUFFER_SIZE=12, with physically 4096 32-bit words per bank and two banks. Allocation of an empty bank gives priority to bank0. When both banks are occupied, no writable bank is available and pixels are ignored, but the pixel counter continues counting according to hsync. The capture unit does not truncate or split lines at 4096 words; for a sustained long line, the write address wraps modulo 4096, the 24-bit word count continues incrementing modulo 2^24, and the published size is that count. The read address also wraps at 12 bits. Do not treat 4096 as an automatic backpressure boundary.

### R-dv-027-006 — Bank publication, cross-domain acknowledgment, and read selection

After the capture unit releases a bank containing data, it publishes its word count; publication and read completion each cross domains using a three-cycle shift and confirmation from consecutive high/low history. After the read side receives a publication, it records size, selects a bank in advance, and waits for RAM prefetch before asserting ready. When both banks are readable, selection alternates according to the next-bank preference; ambiguity when both first arrive simultaneously is resolved by a synchronized selection value that is 1 when only bank1 is published on the write side and 0 otherwise. After read activate is deasserted, the consumed bank becomes writable again through completion acknowledgment and cannot be reused before the handshake returns.

### R-dv-027-007 — FIFO prefetch, sustained strobe, and falling-edge hold

read_ready indicates a prefetched bank; after activate goes high, ready subsequently clears low. The read address increments after prefetching the first word; on each read_clock edge, the address advances when strobe is high and the address is less than size+1. The data output selects the synchronous RAM output when strobe was high in the preceding cycle, and otherwise selects the held value; the edge on which strobe changes from high to low latches the RAM output into the held value. Sustained high reads every cycle, and holding after low does not mean always returning the first word. size is provided when the bank is selected, rather than decremented with each strobe; do not determine that data is invalid from ready clearing low.

### R-dv-027-008 — Independent domains and priorities of pixel and row counts

Every pixel edge with hsync high increments the current line's pixel count, without restriction by enable, memory_ready, or vsync. When hsync is low and the current pixel count is nonzero, that count is published to o_pixel_count and the frame row count is incremented, after which the current pixel count is cleared. When vsync is low, if the frame row count is >0 and greater than the existing o_row_count, the row count is published, and then the frame row count is cleared. i_reset_counts first clears both outputs, but end-of-line/end-of-frame publication on the same edge takes priority and overrides the clearing; the current internal pixel/row accumulations are not cleared by this. When low vsync and low hsync occur on the same edge, the increment for a nonzero end-of-line takes priority over clearing the internal frame row count. The 32-bit count is modulo 2^32.

### R-dv-027-009 — Public debug combinational mapping and undriven bits

debug[0]=enable, [2:1] is the writable-bank bitmap, [4:3] is the pixel-side active bank, [5] is the current write strobe, [13:6]=pix_data, [14]=vsync, [15]=hsync, and [16]=busy; [31:17] is undriven and is Z in four-state simulation. The low-bit debug state follows the bank and pipeline contract above and does not grant the candidate permission to access internal state.
