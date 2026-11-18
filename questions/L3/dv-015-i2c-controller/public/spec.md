# i2c Behavioral Contract

No parameters; fixed macro DVSR=16 (from backfill/package.svh), with 16 clk cycles per SCL bit period. Two-state host inputs avoid clk rising edges; init is pulsed for one clk cycle only when idle after STOP completes, and addr/cmd/data/rd_wr/wr are held throughout from initiation to STOP. The external slave may only pull sda low or release it, must not drive it high, and must not drive scl; during DUT read termination when sda_en=1, the slave releases the line to avoid strong-drive contention. An external pull-up makes a released line 1. No guarantees for multi-master arbitration, clock stretching, or analog metastability.

### R-dv-015-001 — Synchronous Reset and Idle

Low rst_n resets the state only on a rising edge of clk, sets o_data to 0, and sets s_busy/s_done/sda_en to 0; sda/scl are released in idle. Asserting reset between edges does not immediately clear registered state. With init=0, no automatic start occurs in idle. No queuing; wait for STOP to complete before issuing the next request.

### R-dv-015-002 — Address and Transmitted Bytes

START is generated after init is sampled in idle. The address byte is {addr,rd_wr}, sent MSB first; in the write direction, cmd is sent next, followed by data when wr=1, or termination after cmd when wr=0. Each bit takes 16 clk cycles, and master fields remain stable throughout the frame; tx_data is refreshed internally on every edge, so do not assume that everything is latched at startup.

### R-dv-015-003 — Receive Length and Result Retention

When rd_wr=1, the read address is sent first, and bytes are received after ACK. If the low two bits of cmd are 00 or 11, two bytes are received: the first byte is written to the high 8 bits of o_data, and after the master ACK, the second byte is written to the low 8 bits, followed by NACK; for 01 or 10, only the first byte is received into the high 8 bits, while the low 8 bits retain their old value. Write frames do not modify o_data. The receiver samples the current bit every clk; the sample in the SCL low phase at the end of the bit, when the divider wraps around, determines the final value of that bit, rather than sampling only on the rising edge of SCL.

### R-dv-015-004 — ACK Waiting and Recovery from Missing ACK

At the end of a transmitted byte, busy becomes 0 and ACK is entered; sampling low during source clk phases 8 through 11 of each ACK bit can set the ACK memory, and advancement occurs only at the end of the 16-cycle divider period and only if ACK has been sampled. Without ACK, waiting continues and the ACK clock repeats; s_done does not occur. A subsequent valid ACK allows continuation; synchronous reset can cancel the wait and restore idle. s_busy is 0 during the ACK gap of every byte and does not indicate completion of the entire frame.

### R-dv-015-005 — Bus Phases and Final Drive

SCL is released for high and pulled to 0 for low; when sda_en=0, the DUT only pulls SDA low or releases it during transmit and normal receive data phases. During the first source clk cycle of the ACK gap at the end of a received byte, the response selection is still Z, and digital combinational resolution makes SDA X (even when the slave releases it); this cycle must not be treated as a definite 1. When sda_en=1, ACK=0 or NACK=1 is driven directly (NACK is actively driven high, so operation is not strictly open-drain throughout). During the 16 cycles before START, SCL is high for the first 8 cycles and low for the last 8 cycles, and SDA is pulled low after the count>4; during data/ACK periods, SCL is high at tick4 through 11 and low otherwise. Read ACK/NACK is driven by the sda_en window; it is still disabled on the first clk of the first receive ACK gap and is enabled only on the next clk. ACK drive is retained for the first clk at the start of the second byte, then released.

### R-dv-015-006 — Completion and STOP Timing

After the final byte ACK, the completion window is entered, with s_done at 1, s_busy at 0, and SCL/SDA low; the completion window spans tick0 through 5, totaling 6 source clk cycles. In the subsequent STOP phase, SCL is high starting at tick6, SDA is released starting at tick9, and idle is re-entered after tick15. s_done is already deasserted before STOP, so a rising edge of done must not be treated as completion of STOP; o_data is retained during idle and subsequent writes.

