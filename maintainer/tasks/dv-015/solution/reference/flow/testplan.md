## T-1

feature_ids: F-1

requirement_ids: R-dv-015-001

stimulus: First reset in idle to establish 0; also establish non-idle states during transmission and reception and nonzero read results. Reset between edges and check that registered outputs hold before the clock arrives, then pass through the rising edge; include a long idle wait, reset during a transfer, and a new transaction after recovery.

expected: Low rst_n resets the state only on a rising edge of clk, sets o_data to 0, and sets s_busy/s_done/sda_en to 0; sda/scl are released in idle. Asserting reset between edges does not immediately clear registered state. With init=0, no automatic start occurs in idle. No queuing; wait for STOP to complete before issuing the next request.

checker: Predict using an independent input-history model, without reading actual DUT outputs. Sample after settling following assertion between edges and following the rising edge; check bus release while init remains 0. Compare actual and expected bit by bit using four-state comparison, issue UVM_ERROR on a mismatch, record the comparison count, and trigger this scenario's check at least once.

implementation_id: V-1

source: reference_pkg.sv:native_scoreboard.write

## T-2

feature_ids: F-2

requirement_ids: R-dv-015-002

stimulus: Synchronously reset to idle; configure a legal slave to ACK every transmitted byte. Use addresses 0/127/random, cmd/data values 00/FF/AA/55 and random values; use wr=0/1 write frames, with an independent slave reconstructing bytes according to the valid SCL window.

expected: START is generated after init is sampled in idle. The address byte is {addr,rd_wr}, sent MSB first; in the write direction, cmd is sent next, followed by data when wr=1, or termination after cmd when wr=0. Each bit takes 16 clk cycles, and master fields remain stable throughout the frame; tx_data is refreshed internally on every edge, so do not assume that everything is latched at startup.

checker: Predict using an independent input-history model, without reading actual DUT outputs. Sample transmitted bytes during the stable high phase, compare the driven fields MSB→LSB, and check busy and ACK waiting at byte boundaries. Compare actual and expected bit by bit using four-state comparison, issue UVM_ERROR on a mismatch, record the comparison count, and trigger this scenario's check at least once.

implementation_id: V-2

source: reference_pkg.sv:native_scoreboard.write

## T-3

feature_ids: F-3

requirement_ids: R-dv-015-003

stimulus: First use a two-byte read to establish different high and low bytes, then perform a one-byte read and a write to verify retention rather than merely reset 0. Cover all four low-bit combinations of cmd; have the slave provide independent known 00/FF/asymmetric and random data over complete bit windows; change the bit value in the low phase at the end of the bit so it differs from the high-phase sample, to verify the actual valid window; retain the low bits across successive different frames.

expected: When rd_wr=1, the read address is sent first, and bytes are received after ACK. If the low two bits of cmd are 00 or 11, two bytes are received: the first byte is written to the high 8 bits of o_data, and after the master ACK, the second byte is written to the low 8 bits, followed by NACK; for 01 or 10, only the first byte is received into the high 8 bits, while the low 8 bits retain their old value. Write frames do not modify o_data. The receiver samples the current bit every clk; the sample in the SCL low phase at the end of the bit, when the divider wraps around, determines the final value of that bit, rather than sampling only on the rising edge of SCL.

checker: Predict using an independent input-history model, without reading actual DUT outputs. The result updates on the next rising edge of clk after byte busy falls; observe the values after each byte and after STOP, assembling them independently from the slave drive history. Compare actual and expected bit by bit using four-state comparison, issue UVM_ERROR on a mismatch, record the comparison count, and trigger this scenario's check at least once.

implementation_id: V-3

source: reference_pkg.sv:native_scoreboard.write

## T-4

feature_ids: F-4

requirement_ids: R-dv-015-004

stimulus: Complete START and one transmitted byte to reach the ACK window. Exercise normal ACK, release throughout the entire ACK window, pulling low after delaying several ACK periods, and reset while waiting; at each byte boundary, check that busy falls while done remains low.

expected: At the end of a transmitted byte, busy becomes 0 and ACK is entered; sampling low during source clk phases 8 through 11 of each ACK bit can set the ACK memory, and advancement occurs only at the end of the 16-cycle divider period and only if ACK has been sampled. Without ACK, waiting continues and the ACK clock repeats; s_done does not occur. A subsequent valid ACK allows continuation; synchronous reset can cancel the wait and restore idle. s_busy is 0 during the ACK gap of every byte and does not indicate completion of the entire frame.

checker: Predict using an independent input-history model, without reading actual DUT outputs. Sample separately during the valid ACK high phase and at the end of the divider period; wait at least two complete 16-cycle periods, and check recovery after reset. Compare actual and expected bit by bit using four-state comparison, issue UVM_ERROR on a mismatch, record the comparison count, and trigger this scenario's check at least once.

implementation_id: V-4

source: reference_pkg.sv:native_scoreboard.write

## T-5

feature_ids: F-5

requirement_ids: R-dv-015-005

stimulus: Release in idle, and configure the master and an external slave that obeys the finalization release rules. Exercise START, transmission of 0/1, slave ACK, master ACK/NACK for one-/two-byte reads, and reset; check bus levels and sda_en while the external slave releases the line.

expected: SCL is released for high and pulled to 0 for low; when sda_en=0, the DUT only pulls SDA low or releases it during transmit and normal receive data phases. During the first source clk cycle of the ACK gap at the end of a received byte, the response selection is still Z, and digital combinational resolution makes SDA X (even when the slave releases it); this cycle must not be treated as a definite 1. When sda_en=1, ACK=0 or NACK=1 is driven directly (NACK is actively driven high, so operation is not strictly open-drain throughout). During the 16 cycles before START, SCL is high for the first 8 cycles and low for the last 8 cycles, and SDA is pulled low after the count>4; during data/ACK periods, SCL is high at tick4 through 11 and low otherwise. Read ACK/NACK is driven by the sda_en window; it is still disabled on the first clk of the first receive ACK gap and is enabled only on the next clk. ACK drive is retained for the first clk at the start of the second byte, then released.

checker: Predict using an independent input-history model, without reading actual DUT outputs. Sample after settling after each clk and at phase midpoints; four-state bus resolution must not convert X/Z to bit in advance; compare only within the publicly specified legal, contention-free drive domain. Compare actual and expected bit by bit using four-state comparison, issue UVM_ERROR on a mismatch, record the comparison count, and trigger this scenario's check at least once.

implementation_id: V-5

source: reference_pkg.sv:native_scoreboard.write

## T-6

feature_ids: F-6

requirement_ids: R-dv-015-006

stimulus: Initiate complete writes, single-byte reads, and two-byte reads with ACK, pulsing init only once. Record done rising/falling and SCL/SDA finalization separately; wait for the entire STOP before issuing another request; continue observing o_data in idle.

expected: After the final byte ACK, the completion window is entered, with s_done at 1, s_busy at 0, and SCL/SDA low; the completion window spans tick0 through 5, totaling 6 source clk cycles. In the subsequent STOP phase, SCL is high starting at tick6, SDA is released starting at tick9, and idle is re-entered after tick15. s_done is already deasserted before STOP, so a rising edge of done must not be treated as completion of STOP; o_data is retained during idle and subsequent writes.

checker: Predict using an independent input-history model, without reading actual DUT outputs. Count the done width and the ordering relative to STOP in source clk cycles, rather than merely waiting for busy to fall. Compare actual and expected bit by bit using four-state comparison, issue UVM_ERROR on a mismatch, record the comparison count, and trigger this scenario's check at least once.

implementation_id: V-6

source: reference_pkg.sv:native_scoreboard.write
