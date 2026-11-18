# VGASyncModule_TopLevel Module Specification

### R-VGA-001 — Purpose and Boundaries
This module is a VGA vertical (frame) timing counter: it counts on a single clock and outputs the current count, four phase flags
(visible region, front porch, sync pulse phase, back porch), and a last-line flag. The phase flags are mutually exclusive and exhaustive over counts 0..524.
The module contains no pixel or horizontal timing logic and has no external register or bus interface; the thresholds are fixed constants.
OutSP is an active-high sync pulse phase indicator; the module has no separate port for polarity conversion.
Upstream provides Clock, Reset, and Enabled; downstream consumes OutCounter and the flags. The module contains no subinstances,
queues, storage arrays, or arbiters, and there are no cross-module reset or arbitration semantics.

### R-VGA-002 — Interface Contract
There are 9 ports in total: Clock, Reset, and Enabled are inputs; OutVisible, OutFP, OutSP, OutBP, and OutMax
are 1-bit outputs; OutCounter is a 10-bit unsigned output ([9:0]).
- Clock is the only clock; the count state during operation updates only on the rising edge of Clock.
- Reset is a synchronous, active-high reset, sampled only on the rising edge of Clock. Changing Reset between edges does not immediately load the count,
  and a reset pulse entirely between two rising edges does not change the count. There is no combinational gating that forces outputs during reset.
- Enabled is sampled on the rising edge of Clock; when Reset is 0, Enabled at 1 advances the count, and at 0 holds it.
- Outputs are combinational, with no output registers: outputs are in phase with OutCounter and reflect the new count immediately after the clock
  edge. Here, “after the edge” refers to a stable observation point at which both the nonblocking state update and combinational propagation have completed,
  and does not mean that the new state can already be read in the rising-edge active region before the NBA update.
The module has no ready/valid handshake, backpressure, or cancellation; input acceptance conditions are determined by the rising edge of Clock and Reset/Enabled.

### R-VGA-003 — Vertical Counting
The count state is a 10-bit unsigned number. It updates on each rising edge of Clock according to the following priority:
- When Reset == 1, load 1, meaning the count after reset is 1 (not 0), regardless of whether Enabled is 0 or 1.
- When Reset == 0 and Enabled == 1, if the current count is 524, the next state is 0; otherwise, increment by 1.
- When Reset == 0 and Enabled == 0, hold the current count.
After a sampled reset establishes the state, legal input histories keep the count within 0..524, with a cycle length of 525.
The first cycle established by reset starts at 1; the first enabled rising edge after reset deassertion advances 1 to 2.
The register declaration in the fixed RTL also has an initial value of 0: after HDL simulation initialization and combinational settling, and before the first rising edge,
OutCounter=0 can be observed. This declaration initial value is not equal to the synchronous reset value, nor does it guarantee the power-up state of physical hardware without reset.
For state preparation and the valid scope of runtime checks in this problem, see R-VGA-005.

### R-VGA-004 — Phase Boundaries
Combinational decoding directly uses the current OutCounter, with thresholds of 480, 490, 492, and 525, and a last-line value of 524:
- OutVisible is 1 if and only if the count is less than 480: within the legal domain, this is 0..479, totaling 480 counts.
- OutFP is 1 if and only if 480 <= count < 490: 480..489, totaling 10 counts.
- OutSP is 1 if and only if 490 <= count < 492: 490..491, totaling 2 counts.
- OutBP is 1 if and only if 492 <= count < 525: 492..524, totaling 33 counts.
- OutMax is 1 if and only if the count equals 524.
When a flag's conditions are not met, that flag is 0. The sum of the four phase lengths is 525, and count 0 belongs to the visible region.
OutMax and OutBP may both be 1 simultaneously; the requirement that the four phases be mutually exclusive does not include OutMax.
10 bits can represent values up to 1023, but the normal cycle explicitly wraps around at 524 rather than relying on bit-width overflow.

### R-VGA-005 — Valid Input History and Observation Timing
For verification runs, prepare the state by having Reset=1 sampled on at least one rising edge of Clock; then use native inputs to advance or hold,
producing reachable counts of 0..524. Reset and Enabled use definite 0/1 levels, established before the rising edge and kept
stable during sampling to avoid races between input driving and state sampling. Outputs must be checked after the NBA updates for the rising edge of interest and after the combinational logic
has settled; values observed before the edge or before the NBA updates still belong to the pre-update state and must not be treated as post-update values for that same edge.
Reset behavior between edges may be observed once combinational logic has settled after an input change, and must be distinguished from the reset effect at the next sampling edge.
X/Z inputs, forced internal states, and counts 525..1023 are outside the operating domain required to be covered in this task; the delta
propagation process at initialization is also not an output comparison window. The simulation fact of declared initial values before reset cannot replace the state preparation described above.
