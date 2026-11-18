# Test Plan

## T-reset

Function: F-reset; requirement: R-ETH7FBC-001.

Stimulus: First reset for 3 cycles, release reset, and hold DV low until Idle; then, in Data0, Data1, and when a byte/End is in flight, assert Reset 1ns after the falling edge, sample 0.5ns later, hold it across rising edges for 3 cycles, and release it; cross DlyCrcEn=0/1, MaxFL=0/1518, and HugEn=0/1, and send another frame after release. All inputs are driven on falling edges, with no hierarchical reads or writes.

Expected: Behavior advances on MRxClk rising edges; Reset is asynchronous and active high. Reset immediately clears RxData, RxValid, RxStartFrm, RxEndFrm, internal byte count n, IFG count g, delay count d, byte and flag pipelines, broadcast/multicast candidates, unicast/multicast acceptance, RxAbort, and AddressMiss; the CRC state is set to ffffffff. Reception is in Drop, so StateIdle/StatePreamble/StateSFD/StateData are all 0. Only the hash index h is cleared to 0 on a rising edge when Reset or Idle is active; the hash-valid memory takes the pre-edge condition Data0 and n=6 on every rising edge and is not directly cleared by asynchronous Reset. ByteCnt is still offset by the live DlyCrcEn during reset, MaxFrame is still affected by the MaxFL/HugEn combination, and the reset value of CrcError is 1; not all outputs can be characterized as 0.

Check: An independent input-history predictor calculates all native outputs according to the defined priorities, comparing them using four-state actual!==expected at 1ns after rising edges, 1ns after falling edges, and 0.5ns after asynchronous Reset; expected values read only reset, inputs, and history, not DUT results. Any mismatch reports UVM_ERROR and identifies the seed/cycle/port. Record the actual stimulus, comparison count, and boundary hits for this scenario; report an error for an empty scenario; functional coverage cannot replace error checking. All synchronous formulas read pre-edge values and update simultaneously after the edge; observe asynchronous outputs after Reset propagation has settled.

Implementation: reference_pkg.sv:port_scoreboard.write; histories.svh:histories

## T-state

Function: F-state; requirement: R-ETH7FBC-002.

Stimulus: Starting from reset and DV low, cross DV high and Transmitting=0/1 with data 5/3 in Idle; in Preamble, use multiple non-5 values followed by 5, and in SFD use non-d values followed by d; deassert DV in both Data phases, and sustain DV in Drop before deasserting it; toggle Transmitting after entering Data, with the r_IFG bypass both on and off. All inputs are driven on falling edges, with no hierarchical reads or writes.

Expected: The abstract states are Drop, Idle, Preamble, SFD, Data0, and Data1. Drop enters Idle when DV is low; otherwise it holds. Idle holds when DV is low; when DV is high and Transmitting=1, it enters Drop; otherwise, MRxD=5 leads to SFD and all other values lead to Preamble. Preamble returns to Idle when DV is low, enters SFD when DV is high and data is 5, and otherwise holds; SFD returns to Idle when DV is low, enters Data0 or Drop according to IFG qualification when DV is high and data is d, and otherwise holds. Data0 returns to Idle when DV is low; otherwise it enters Drop if at the limit, or Data1 if not at the limit; Data1 returns to Idle when DV is low, and otherwise enters Data0. StateData[0]/[1] correspond to Data0/Data1; other derived states correspond to their names. No fixed number of preamble 5 values is required; Drop cannot be exited while DV remains high; Abort and CRC errors do not trigger a transition to the drop state, and changes to Transmitting after entering Data do not cancel the frame.

Check: An independent input-history predictor calculates all native outputs according to the defined priorities, comparing them using four-state actual!==expected at 1ns after rising edges, 1ns after falling edges, and 0.5ns after asynchronous Reset; expected values read only reset, inputs, and history, not DUT results. Any mismatch reports UVM_ERROR and identifies the seed/cycle/port. Record the actual stimulus, comparison count, and boundary hits for this scenario; report an error for an empty scenario; functional coverage cannot replace error checking. IFG and limit decisions use values from before the same rising edge; Transmitting determines Drop only at the start in Idle.

Implementation: reference_pkg.sv:port_scoreboard.write; histories.svh:histories

## T-gap

Function: F-gap; requirement: R-ETH7FBC-003.

Stimulus: After clearing g in Drop, drive DV low or a non-5 preamble to establish g=0, 1, 23, 24 and a 30-cycle history, then 5, d; separately toggle r_IFG midway through the gap and recognize d, ensuring insufficient/exactly sufficient/more than sufficient gaps and bypass. All inputs are driven on falling edges, with no hierarchical reads or writes.

Expected: g is a 5-bit count, reset to 0. An edge in Drop, or in SFD with DV high and MRxD=d, clears g to 0; otherwise, when in Idle/Preamble/SFD and IFG is not qualified, g increments by 1; otherwise it holds. IFG qualification means g=24 or r_IFG=1. Setting bypass to 1 also stops incrementing without changing the existing g. Compare short gaps, exactly 24, and long gaps; bypass switching takes effect live; the counting unit is clock edges rather than a fixed physical time.

Check: An independent input-history predictor calculates all native outputs according to the defined priorities, comparing them using four-state actual!==expected at 1ns after rising edges, 1ns after falling edges, and 0.5ns after asynchronous Reset; expected values read only reset, inputs, and history, not DUT results. Any mismatch reports UVM_ERROR and identifies the seed/cycle/port. Record the actual stimulus, comparison count, and boundary hits for this scenario; report an error for an empty scenario; functional coverage cannot replace error checking. Recognition of d in SFD uses g before clearing to determine acceptance.

Implementation: reference_pkg.sv:port_scoreboard.write; histories.svh:histories

## T-count

Function: F-count; requirement: R-ETH7FBC-004.

Stimulus: From reset, enter Data with 5, d, and drive long and short frames for MaxFL=0/1/2/3/20/1518/ffff and HugEn=0/1; deassert DV in Data0 and Data1; sustain a long preamble for more than 65536 cycles to verify wraparound, and long data for more than 65535 bytes to verify saturation at ffff; observe ByteCnt and the three comparison flags at every boundary. All inputs are driven on falling edges, with no hierarchical reads or writes.

Expected: n is a 16-bit unsigned count. With DV high, being in SFD and receiving d, or being in Data0 and at the limit, clears it to 0 with priority. Otherwise, with DV high and in Preamble/SFD/non-transmitting Idle, increment by 1; or, with DV high and in Data1, n not ffff, and DlyCrcEn and nonzero d not both true, increment by 1; otherwise hold. Addition on the preamble path is modulo 65536; Data1 saturates at ffff. At the limit is defined as n=MaxFL and HugEn=0. ByteCnt is n when DlyCrcEn=0, or (n+4) modulo 65536 when it is 1; ByteCntEq0 means n=0, ByteCntGreat2 means n>2, and ByteCntMaxFrame means at the limit. MaxFL may be 0, 1, 2 up to ffff; HugEn only masks the upper-limit comparison and does not remove saturation at ffff. The count holds when exiting Data with DV low.

Check: An independent input-history predictor calculates all native outputs according to the defined priorities, comparing them using four-state actual!==expected at 1ns after rising edges, 1ns after falling edges, and 0.5ns after asynchronous Reset; expected values read only reset, inputs, and history, not DUT results. Any mismatch reports UVM_ERROR and identifies the seed/cycle/port. Record the actual stimulus, comparison count, and boundary hits for this scenario; report an error for an empty scenario; functional coverage cannot replace error checking. Count state updates after the edge, and derived comparisons use the current value; the count clears only when Data0 at the limit and DV high are both true.

Implementation: reference_pkg.sv:port_scoreboard.write; histories.svh:histories

## T-delay

Function: F-delay; requirement: R-ETH7FBC-005.

Stimulus: Send the same data frame with DlyCrcEn=0/1, hold SFD for multiple cycles, then alternately disable/re-enable DlyCrcEn at each delay position d=1..9, and stay in Idle; maintain input history to track d and n, observe Start/Valid/ByteCnt/CRC, and also change the filtering configuration within the frame. All inputs are driven on falling edges, with no hierarchical reads or writes.

Expected: d is a 4-bit count, reset to 0; on each edge, old d=9 returns to 0 with priority; otherwise DlyCrcEn and SFD set it to 1; otherwise DlyCrcEn and nonzero d increment it by 1; otherwise it holds. Idle does not directly clear d; nonzero d suspends n increments in Data1 in delay mode; it affects valid/Start, CRC initialization, and the ByteCnt offset. All configurations are live inputs, with no latching at frame start. Disabling DlyCrcEn may leave d nonzero; old d=9 still clears with priority; X/Z inputs and values before reset are undefined.

Check: An independent input-history predictor calculates all native outputs according to the defined priorities, comparing them using four-state actual!==expected at 1ns after rising edges, 1ns after falling edges, and 0.5ns after asynchronous Reset; expected values read only reset, inputs, and history, not DUT results. Any mismatch reports UVM_ERROR and identifies the seed/cycle/port. Record the actual stimulus, comparison count, and boundary hits for this scenario; report an error for an empty scenario; functional coverage cannot replace error checking. Configuration is stable before the sampling edge; DlyCrcEn and filtering configuration may be updated in different cycles, with decisions on each edge based on their values at that time.

Implementation: reference_pkg.sv:port_scoreboard.write; histories.svh:histories

## T-data

Function: F-data; requirement: R-ETH7FBC-006.

Stimulus: For a long gap and r_IFG=1 respectively, drive 5, d and then input low/high nibbles for 00, 12, a5, ff, and consecutive random bytes; deassert DV in both phases and include frames with Abort/CRC errors; execute in both normal and delayed CRC modes, and continue changing MRxD when DV is low to observe invalid data clearing/holding. All inputs are driven on falling edges, with no hierarchical reads or writes.

Expected: Use input-history memory L: on every edge, regardless of DV, it takes {current MRxD, upper 4 bits of old L}. When pre-edge Data0 and (n is nonzero or d>=3), generate a byte event and store old L in pending output byte P; otherwise, if the previous cycle was not Data0, clear P to 0; otherwise hold. RxData takes old P on every edge. The byte event passes through pending output-valid memory and becomes RxValid on the next edge. The Start event is Data0 and (n=1 in normal mode, or d=3 in delay mode), and likewise becomes RxStartFrm on the next edge. There is no ready/backpressure; events are not directly gated by DV, Abort, or CRC, and the exit edge where DV is deasserted in Data0 can still generate pipeline output; when RxData is invalid it still changes according to the clearing/holding pipeline described above.

Check: An independent input-history predictor calculates all native outputs according to the defined priorities, comparing them using four-state actual!==expected at 1ns after rising edges, 1ns after falling edges, and 0.5ns after asynchronous Reset; expected values read only reset, inputs, and history, not DUT results. Any mismatch reports UVM_ERROR and identifies the seed/cycle/port. Record the actual stimulus, comparison count, and boundary hits for this scenario; report an error for an empty scenario; functional coverage cannot replace error checking. Event conditions are met before edge E, pending output is stored at edge E, and it appears at the output after edge E+1; valid comparisons must be paired with RxData from the same cycle.

Implementation: reference_pkg.sv:port_scoreboard.write; histories.svh:histories

## T-end

Function: F-end; requirement: R-ETH7FBC-007.

Stimulus: Use frame lengths of 0/1/2/3/8 bytes, plus termination after an additional nibble, deasserting DV in Data0/Data1 respectively; use MaxFL=0/1/2/3/20 and keep DV high until the limit, cross HugEn and DlyCrcEn, and sample continuously through 8 cycles after exit to drain old End; send a new frame immediately after a short frame to detect residual state. All inputs are driven on falling edges, with no hierarchical reads or writes.

Expected: The normal End event is Data0 and ((DV low and n>2) or at the limit), and becomes RxEndFrm on the next edge through pending output-End memory. The dribble event is Data1 and DV low and n>2, and is directly ORed into RxEndFrm after the current edge; old pending output End is also still ORed in. DV termination of a short frame with n<=2 does not generate a new End, but the Data0 at-limit branch has no such restriction and does not require DV low, and the old End pipeline can still produce output. At the limit in Data0, DV high transitions to Drop and clears n; DV low transitions to Idle and holds n.

Checks: An independent input-history predictor computes all native outputs according to the defined priorities, using four-state actual!==expected comparisons 1ns after rising edges, 1ns after falling edges, and 0.5ns after asynchronous Reset; expected values read only reset, inputs, and history, not DUT results. Any mismatch reports UVM_ERROR and identifies the seed/cycle/port. Record the actual stimulus, comparison count, and boundary hits for this scenario; report an error for an empty scenario. Functional coverage cannot replace error detection. An ordinary event triggers at E and outputs at E+1; dribble outputs at E.

Implementation: reference_pkg.sv:port_scoreboard.write; histories.svh:histories

## T-crc

Function: F-crc; requirement: R-ETH7FBC-008.

Stimulus: Send deterministic and random nibble frames in ordinary and delayed modes separately, including a directed 64-byte vector whose CRC reaches exactly c704dd7b and single-bit corruption, reaching the MaxFL limit, and idle shifting after exit; observe CrcError during SFD, delayed initialization, enabled windows, and disabled windows. Also compare the data/status outputs of erroneous frames. All inputs are driven on falling edges, with no hierarchical reads or writes.

Expected: CRC is a 32-bit historical value c. Initialize to ffffffff on asynchronous reset, or on a rising edge when in SFD or when DlyCrcEn and 1<=d<9; initialization has priority. On every other edge, process MRxD bit0, bit1, bit2, and bit3 in four successive steps: each step shifts left by 1 bit, filling the low bit with 0; only when DV is high, in either Data state, and the limit has not been reached, obtain feedback by XORing the highest bit before the shift with that input bit, and additionally XOR with 04c11db7 when feedback is 1. When not enabled, feedback is fixed at 0 and a total left shift of 4 bits still occurs; it is never a hold. CrcError continuously equals c not equal to c704dd7b. CRC errors do not suppress Valid/Start/End; the error status may continue changing after the end.

Checks: An independent input-history predictor computes all native outputs according to the defined priorities, using four-state actual!==expected comparisons 1ns after rising edges, 1ns after falling edges, and 0.5ns after asynchronous Reset; expected values read only reset, inputs, and history, not DUT results. Any mismatch reports UVM_ERROR and identifies the seed/cycle/port. Record the actual stimulus, comparison count, and boundary hits for this scenario; report an error for an empty scenario. Functional coverage cannot replace error detection. Observe after combinational logic settles following each edge, including during reception, the ending edge, and subsequent idle; do not latch the end-of-frame result.

Implementation: reference_pkg.sv:port_scoreboard.write; histories.svh:histories

## T-classify

Function: F-classify; requirement: R-ETH7FBC-009.

Stimulus: Cross all-ff broadcast and a non-ff intermediate byte with the first-byte multicast bit set to 1/0; r_Bro=0/1, all-0/all-1 hash, and walking-one 64 bits; predict the hash index from the input CRC, generate each index by directed generation or bounded search, and record unhit bins; change the hash table around counts 6/7, follow a short frame without End with a new frame, and observe classification lifetime. All inputs are driven on falling edges, with no hierarchical reads or writes.

Expected: The broadcast candidate is cleared to 0 with priority when Data0 and n<7 and old L is not ff; otherwise it is set to 1 when Data0 and n=1 and old L=ff; otherwise it is cleared to 0 on old RxAbort or old RxEndFrm; otherwise it holds. Broadcast acceptance is the candidate and r_Bro=0. The multicast candidate is set to 1 with priority when Data0 and n=1 and the least significant bit of old L is 1; otherwise old Abort/End clears it to 0; otherwise it holds. When Data0 and n=6, h latches old CRC[31:26], and the hash-valid memory is simultaneously set to 1; on other edges the valid memory is 0. Multicast acceptance is cleared to 0 with priority on old End/Abort; otherwise, when old hash-valid and old multicast candidate are true, it takes the bit at old h of the 64-bit {r_HASH1,r_HASH0}; otherwise it holds. Idle does not uniformly clear classification/acceptance, which may remain for short frames without End; r_Bro=1 disables broadcast acceptance, and hash bits cover 0..63.

Checks: An independent input-history predictor computes all native outputs according to the defined priorities, using four-state actual!==expected comparisons 1ns after rising edges, 1ns after falling edges, and 0.5ns after asynchronous Reset; expected values read only reset, inputs, and history, not DUT results. Any mismatch reports UVM_ERROR and identifies the seed/cycle/port. Record the actual stimulus, comparison count, and boundary hits for this scenario; report an error for an empty scenario. Functional coverage cannot replace error detection. Classification, hash, and acceptance all read pre-edge history; the hash index is cleared to 0 with priority on a rising edge with Reset or Idle.

Implementation: reference_pkg.sv:port_scoreboard.write; histories.svh:histories

## T-address

Function: F-address; requirement: R-ETH7FBC-010.

Stimulus: For frames with matching MAC, a mismatch in the first/middle/only the last byte, broadcast frames, and hash-accepted/rejected frames, observe both phases at counts 2..7; exhaustively enumerate r_Pro, PassAll, and ControlFrmAddressOK, and change MAC and exemption configuration before and after count 7; cross post-frame idle holding, n clearing, and short-frame history, checking RxAbort and AddressMiss separately. All inputs are driven on falling edges, with no hierarchical reads or writes.

Expected: In either Data phase with n=2, unicast acceptance takes the equality of old RxData and MAC[47:40]; at n=3..7 it is ANDed with old acceptance while successively comparing MAC[39:32] through [7:0]; these comparisons take priority over clearing to 0 on old End/Abort; otherwise it holds. On each edge, RxAbort takes (pre-edge n=7 and either Data state and no unicast/broadcast/multicast acceptance and r_Pro=0), and is 0 if this is false. AddressMiss is cleared to 0 with priority when n=0; otherwise, when n=7 and Data, it takes no acceptance of any of the three classes and not (PassAll and ControlFrmAddressOK); otherwise it holds. r_Pro exempts Abort but not Miss; PassAll and ControlFrmAddressOK exempts only Miss. Abort may last multiple cycles and does not automatically truncate output; comparisons do not require RxValid and follow the actual count/phase and pipeline association.

Checks: An independent input-history predictor computes all native outputs according to the defined priorities, using four-state actual!==expected comparisons 1ns after rising edges, 1ns after falling edges, and 0.5ns after asynchronous Reset; expected values read only reset, inputs, and history, not DUT results. Any mismatch reports UVM_ERROR and identifies the seed/cycle/port. Record the actual stimulus, comparison count, and boundary hits for this scenario; report an error for an empty scenario. Functional coverage cannot replace error detection. Rejection uses old acceptance, so the first decision at n=7 may reflect only the first five unicast comparisons, and subsequent edges can decide again; it does not read the last-byte result just completed on this edge.

Implementation: reference_pkg.sv:port_scoreboard.write; histories.svh:histories
