## T-1

feature_ids: F-1

requirement_ids: R-dv-037-001

stimulus: First reset simultaneously, then establish non-default configuration and nonzero operating history. Assert single-domain reset and dual-domain reset separately between edges of the two clocks; read default values after release; observe registered reads even when only changing the address without psel; compare reads on the write edge and on the next edge.

expected: Low presetn asynchronously resets the APB side: pready/prdata/trace are 0, CTRL=0xCA, TIMEOUT=65535, WINDOW=0, RESET_WIDTH=32, lock and refresh error are 0, and last_pc/the boot recovery bit are 0; low wdt_rstn asynchronously sets wdt_reset/count/flags to 0. The two domain resets are independent. On the first pclk edge after presetn is released, pready becomes 1 and remains so; prdata is registered on every pclk edge according to the pre-edge paddr, without requiring psel/penable/read enable, and a read on the same edge as a write returns the pre-write value.

checker: Predict using an independent input-history model, without reading actual DUT outputs. After asynchronous assertion and before the next clock; check registered reads and pready once stable after the pclk NBA. Use bit-by-bit four-state comparison of actual and expected, report UVM_ERROR on mismatch, record the comparison count, and trigger this scenario's check at least once.

implementation_id: V-1

source: reference_pkg.sv:native_scoreboard.write

## T-2

feature_ids: F-2

requirement_ids: R-dv-037-002

stimulus: After reset, write and read each writable register in turn, then lock. Reads and writes at each address, invalid addresses, non-access writes, incorrect lock keys/locking/unlocking; write the four protected addresses and boot while locked, with refresh and status unaffected by the lock; CTRL reserved bits and width truncation.

expected: Mapped addresses 00/04/08/0C/10/14/18/1C/20/24/28 are all hexadecimal. CTRL writes bits11:8 as hart, 7:6 as reset_scope, 4 as the lock hint bit, 3 as freeze enable, 2 as window enable, 1 as reset enable, and 0 as count enable; bit5 reads as 0. 04 is the 32-bit timeout, 08 the 32-bit window, and 28 the low 16 bits of reset width; 0C/14 read as 0, and unmapped addresses read as 0. Writing 0 to LOCK locks it, and 0x1ACCE551 unlocks it; other keys have no effect. CTRL.bit4 does not itself lock it. When locked, writes to 00/04/08/28 are rejected with pslverr=1; writes to 24 are silently ignored without an error; 0C/10/14 are always writable. pslverr combinationally indicates an invalid address or a protected access write while locked; invalid-address errors are not gated by psel.

checker: Predict using an independent input-history model, without reading actual DUT outputs. Combinational pslverr after inputs stabilize; read values after the pclk edge, with at least one additional pclk edge after a write. Use bit-by-bit four-state comparison of actual and expected, report UVM_ERROR on mismatch, record the comparison count, and trigger this scenario's check at least once.

implementation_id: V-2

source: reference_pkg.sv:native_scoreboard.write

## T-3

feature_ids: F-3

requirement_ids: R-dv-037-003

stimulus: Reset both domains, separate configuration requests and wait for synchronization to complete, and first write a small timeout while disabled. Use timeout values 0/1/nonzero, enable/disable/restart, toggle halt freezing, and separate initial load from reload after configuration updates; vary clock ordering and check stable COUNT snapshots.

expected: The control toggle uses two-stage synchronization plus a delayed XOR to capture enable/dbg_freeze on the third wdt edge after the write; the counting block uses the new values only on the next wdt edge. cfg likewise captures the three configuration values on the third wdt edge. reset_en/window_en/halt undergo two-stage wdt level sampling, and counting uses the pre-edge synchronized values. timeout is loaded on the first effective enable while not frozen; thereafter, with no refresh and count>0, the count decrements by 1 on each wdt edge, and timeout occurs only when the pre-edge count is already 0 and timeout_active is not set. Disabling or freezing pauses counting; re-enabling does not repeat the initial load.

checker: Predict using an independent input-history model, without reading actual DUT outputs. Advance independent models of the two domains based on input-event history; sample both after the third wdt edge for configuration and on the next edge where counting uses it. Do not equate write completion with taking effect in counting. Use bit-by-bit four-state comparison of actual and expected, report UVM_ERROR on mismatch, record the comparison count, and trigger this scenario's check at least once.

implementation_id: V-3

source: reference_pkg.sv:native_scoreboard.write

## T-4

feature_ids: F-4

requirement_ids: R-dv-037-004

stimulus: Reset, and separately establish legal histories for counting enabled, disabled, frozen, and window boundaries; requests must be separated by at least 4 wdt edges. Correct two-key sequence, incorrect first/second key, unrelated register writes interposed, and refreshes in states where consumption is prohibited; valid consumption at window-1/window/window+1, then a legal refresh after a violation followed by reading the sticky window bit.

expected: Only writing A5 followed by 5A to 0C generates a refresh toggle; other first/second keys set sticky refresh_error and reset the key state; successful keys do not clear old errors; intervening writes to other addresses do not cancel the first key. pclk acceptance differs from wdt consumption: the disabled/frozen/initial-load branches do not consume the refresh pulse. On consumption, if the window is enabled and the pre-edge count is strictly greater than window, set window_violation and hold the count for that cycle; otherwise load timeout and clear timeout_active and timeout_flag, without clearing window_violation. Equality with the window permits a refresh.

checker: Predict using an independent input-history model, without reading actual DUT outputs. Check APB error bits after the edge; consume the cross-domain pulse on the third wdt edge; compare using the count before the consumption edge, not the current delayed readback value. Compare actual and expected bit by bit using four-state comparison, issue UVM_ERROR on a mismatch, record the comparison count, and trigger this scenario's checks at least once.

implementation_id: V-4

source: reference_pkg.sv:native_scoreboard.write

## T-5

feature_ids: F-5

requirement_ids: R-dv-037-005

stimulus: After reset, configure timeout/width and reset_en, and wait for synchronization; generate an isolated timeout, then construct window and retrigger histories. width is 0/1/32, reset_en=0/1, freeze/disable after timeout, refresh during the pulse, repeated zero counts, and another timeout after refresh.

expected: A timeout sets timeout_flag and sticky reset_cause; when synchronized reset_en is 1, it simultaneously sets wdt_reset, reset_issued, and prev_reset. timeout_active makes a zero count trigger only once until a legal refresh; a window violation can also set reset and issued/prev, but does not set cause. An isolated reset-high pulse with stable configuration lasts reset_cycles+1 wdt cycles, including 0→1 cycles and 32→33 cycles; pulse timing is independent of disable/freeze and is not canceled by a legal refresh. Retriggering during the pulse does not clear reset_counter again; when deassertion and a new trigger occur on the same edge, the new trigger takes priority.

checker: Predict using an independent input-history model, without reading actual DUT outputs. After wdt edges, record the source-clock cycle numbers at which the high level starts and ends; flag readback follows two-stage pclk synchronization plus registered-read latency. Compare actual and expected bit by bit using four-state comparison, issue UVM_ERROR on a mismatch, record the comparison count, and trigger this scenario's checks at least once.

implementation_id: V-5

source: reference_pkg.sv:native_scoreboard.write

## T-6

feature_ids: F-6

requirement_ids: R-dv-037-006

stimulus: Generate all types of sticky flags and clear them at legal toggle intervals; hold CPU PC throughout valid propagation. Write 0/write 1 to each bit and overlap status setting and clearing; attempts to write cause do not clear it; boot writes and locking; PC valid/invalid and updates; COUNT countdown and frozen stable points, and fast/slow clock ratios.

expected: STATUS10 reads bits3:0 as reset_issued/refresh_error/window_violation/timeout. Writing 1 to clear bit2 directly clears the refresh error in pclk; bits0/1/3 flip toggles and clear the corresponding wdt flags on the third wdt edge, respectively, with setting by a new event on the same edge taking priority; writing 0 has no effect. RESET_CAUSE1C is cleared only by wdt reset. Writing 1 to BOOT24.bit0 clears prev_reset via a toggle, bit1 writes recovery, and the low read bit is synchronized prev_reset. COUNT18 snapshots the pre-edge count on each wdt edge, latches it in pclk through three-stage toggle detection, and then provides a registered read; snapshots may be skipped. LAST_PC20 updates from the current cpu_commit_pc after cpu_commit_valid passes through two pclk stages.

checker: Predict using an independent input-history model, without reading actual DUT outputs. The pclk registered read uses the pre-edge synchronized value; status clears on the third wdt edge, followed by two pclk cycles for synchronization and one more pclk cycle for reading; predict COUNT precisely using independent pipeline history. Compare actual and expected bit by bit using four-state comparison, issue UVM_ERROR on a mismatch, record the comparison count, and trigger this scenario's checks at least once.

implementation_id: V-6

source: reference_pkg.sv:native_scoreboard.write

## T-7

feature_ids: F-7

requirement_ids: R-dv-037-007

stimulus: Reset both domains, configure a small count and make pclk faster than wdt, predicting latching from independent event history; also use a slow pclk to create legal losses. Each type of APB event and wdt running, freeze, and timeout events; coincident APB and wdt latching, holding, and default reversion after no event; check data payload and event code together.

expected: The trace port is registered in pclk. APB events appear after the write-commit edge; on the next pclk, the default returns to the most recently latched wdt event rather than continuously holding the APB event. Codes 08/0C/10/14 are CTRL/timeout/window/width updates, 18/1C are lock/unlock, 24 is refresh acceptance, 2C/30 are incorrect first/second keys, 60 is a status write, and C0 is protected-write rejection; data is pwdata, for a status write it is the 4 flags before clearing, and for rejection it is paddr. The default A4 snapshot on each wdt edge has data equal to the pre-edge count; debug 80 is a synchronized halt rising edge with freeze_en, and 84 repeats on each edge while halt remains 1 and freeze_en=0; reset deassertion 48, initial load 20, legal reload 28, window 40/4C, and timeout 64/44 successively override earlier events. Data for 44/4C is the count, for 48 it is width, for 20/28 it is timeout, and for 64 it is the pre-edge synchronized cause. wdt events flip a toggle on every edge, pass through two pclk stages and third-cycle detection and latching, and reach the port on the next pclk; events may be lost, there is no lossless queue, and an APB event on the same edge overrides the wdt default.

checker: Predict using an independent input-history model, without reading actual DUT outputs. Check after the APB commit edge and after every subsequent pclk edge; use the actual toggle sampling history rather than requiring every internal event to appear. Compare actual and expected bit by bit using four-state comparison, issue UVM_ERROR on a mismatch, record the comparison count, and trigger this scenario's checks at least once.

implementation_id: V-7

source: reference_pkg.sv:native_scoreboard.write
