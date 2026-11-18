## T1

feature_ids: F1

requirement_ids: R-bb12edf1-001

stimulus: For four op values and mod=0/1, use pairwise combinations of these 18 classes of numbers: positive and negative zero, positive and negative one, two, minimum normal/subnormal, maximum subnormal, maximum positive and negative finite numbers, positive and negative infinity, qNaN/sNaN, 1+ulp, positive and negative half-ulp, and min-normal+ulp; additionally, use 100 sets of random 32-bit operands per combination. Include ADD ignoring A and MUL ignoring C.

expected: Compute the exact multiply-add on an arbitrary-precision signed-integer lattice and then round once, predicting according to the input opcode and mod.

checker: Input history drives an independent exact mathematical model; perform four-state comparisons of control, extension, and data/sidebands qualified by valid in combinational settling windows 1ns after falling-edge driving and 1ns after the rising edge, reporting UVM_ERROR on mismatches. Target event counts must be nonzero, and the fixed history must complete; do not backfill predictions with actual outputs.

implementation_id: V1

source: stimulus.svh:history; pins_pkg.sv:pin_monitor.run_phase/pin_scoreboard.write; model/model.sv:mathematical_fma

## T2

feature_ids: F2

requirement_ids: R-bb12edf1-002

stimulus: Cross all six rm values with four op values and mod; use 1+ulp, positive and negative 2^-24 added to one, positive and negative zero and opposite-sign cancellation, maximum finite numbers, and random values to cover midpoints, values below and above midpoints, even and odd least significant bits, signs, and carries.

expected: The guard/sticky bits and lowest retained bit of an independent exact lattice determine the six rounding modes; an exact zero from opposite signs is negative only for rm=2, while same-sign zeros retain their sign.

checker: Input history drives an independent exact mathematical model; perform four-state comparisons of control, extension, and data/sidebands qualified by valid in combinational settling windows 1ns after falling-edge driving and 1ns after the rising edge, reporting UVM_ERROR on mismatches. Target event counts must be nonzero, and the fixed history must complete; do not backfill predictions with actual outputs.

implementation_id: V2

source: stimulus.svh:history; pins_pkg.sv:pin_monitor.run_phase/pin_scoreboard.write; model/model.sv:mathematical_fma

## T3

feature_ids: F3

requirement_ids: R-bb12edf1-003

stimulus: Drive normal, subnormal, positive and negative zero, positive and negative inf, qNaN, and sNaN individually; randomly cover boxed values over 0..7, including unboxed finite/inf/sNaN bit patterns; also set A for ADD and C for MUL to exceptional values and unboxed values.

expected: Independently classify according to the operands used and boxed; treat unboxed operands as qNaN, and ignored operands do not generate exceptions.

checker: Input history drives an independent exact mathematical model; perform four-state comparisons of control, extension, and data/sidebands qualified by valid in combinational settling windows 1ns after falling-edge driving and 1ns after the rising edge, reporting UVM_ERROR on mismatches. Target event counts must be nonzero, and the fixed history must complete; do not backfill predictions with actual outputs.

implementation_id: V3

source: stimulus.svh:history; pins_pkg.sv:pin_monitor.run_phase/pin_scoreboard.write; model/model.sv:mathematical_fma

## T4

feature_ids: F4

requirement_ids: R-bb12edf1-004

stimulus: Cross six rm values, four op values, and mod with inf, zero, qNaN, and sNaN boundaries; include inf*0+qNaN, 0*inf+sNaN, and addition of effective opposite-sign infinities and same-sign infinities.

expected: After independent classification, check inf*zero first, then NaN, then infinity; NaN is 0x7fc00000, NV follows the priority, and all other flags are 0.

checker: Input history drives an independent exact mathematical model; perform four-state comparisons of control, extension, and data/sidebands qualified by valid in combinational settling windows 1ns after falling-edge driving and 1ns after the rising edge, reporting UVM_ERROR on mismatches. Target event counts must be nonzero, and the fixed history must complete; do not backfill predictions with actual outputs.

implementation_id: V4

source: stimulus.svh:history; pins_pkg.sv:pin_monitor.run_phase/pin_scoreboard.write; model/model.sv:mathematical_fma

## T5

feature_ids: F5

requirement_ids: R-bb12edf1-005

stimulus: Cross the maximum positive and negative finite numbers multiplied by two, minimum normal, minimum/maximum subnormal, and min-normal+ulp with six rm values; include exact subnormal, inexact tiny, and boundaries that round to the minimum normal, such as max-subnormal*(-2^-24)+min-normal.

expected: Independently predict the value and OF/NX using an exact lattice, and tiny using rounding with unbounded exponent precision; do not determine UF solely from the final exponent.

checker: Input history drives an independent exact mathematical model; perform four-state comparisons of control, extension, and data/sidebands qualified by valid in combinational settling windows 1ns after falling-edge driving and 1ns after the rising edge, reporting UVM_ERROR on mismatches. Target event counts must be nonzero, and the fixed history must complete; do not backfill predictions with actual outputs.

implementation_id: V5

source: stimulus.svh:history; pins_pkg.sv:pin_monitor.run_phase/pin_scoreboard.write; model/model.sv:mathematical_fma

## T6

feature_ids: F6

requirement_ids: R-bb12edf1-006

stimulus: Toggle in_valid/out_ready through 00/01/10/11, drive on the falling edge and hold across the rising edge; check 1ns after driving and 1ns after the rising edge, including valid data with valid=1 ready=0 and control with valid=0.

expected: Predict ready=out_ready, valid=busy=in_valid, and extension=1 directly from the inputs; for valid=1, compare independently computed numerical values and sidebands; for valid=0, compare only control and extension.

checker: Input history drives an independent exact mathematical model; perform four-state comparisons of control, extension, and data/sidebands qualified by valid in combinational settling windows 1ns after falling-edge driving and 1ns after the rising edge, reporting UVM_ERROR on mismatches. Target event counts must be nonzero, and the fixed history must complete; do not backfill predictions with actual outputs.

implementation_id: V6

source: stimulus.svh:history; pins_pkg.sv:pin_monitor.run_phase/pin_scoreboard.write; model/model.sv:mathematical_fma

## T7

feature_ids: F7

requirement_ids: R-bb12edf1-007

stimulus: First hold reset low for two cycles and then release it; cross one-bit tag/mask/aux, valid, flush, reg_ena, and ready; additionally, hold reset low with valid requests and generate reset transitions between edges to check the stateless combinational relationships.

expected: With valid=1, sidebands pass through unchanged, including mask=0; control and extension still satisfy the zero-stage pipeline relationships under any rst/flush/reg_ena.

checker: Input history drives an independent exact mathematical model; perform four-state comparisons of control, extension, and data/sidebands qualified by valid in combinational settling windows 1ns after falling-edge driving and 1ns after the rising edge, reporting UVM_ERROR on mismatches. Target event counts must be nonzero, and the fixed history must complete; do not backfill predictions with actual outputs.

implementation_id: V7

source: stimulus.svh:history; pins_pkg.sv:pin_monitor.run_phase/pin_scoreboard.write; model/model.sv:mathematical_fma

## T8

feature_ids: F8

requirement_ids: R-bb12edf1-008

stimulus: Initialize both configurations with reset; drive combinations of 18 boundary classes and random operands across four op values, mod, and six rm values, using 4-bit tag and 2-bit aux to exercise nonzero upper bits; feed both stages every cycle, inserting 8 cycles of backpressure, bubbles, flush with valid transactions in flight, asynchronous reset between edges, and recovery; cover 0/1 separately for each of the two external reg_ena bits. Explicitly drive FMA near the minimum normal and change external rm while a transaction is in flight to distinguish the saved rm from the live boundary behavior of UF.

expected: An independent two-stage elastic queue based on input history predicts valid/ready/busy and metadata; arithmetic uses the same exact model; reset/flush invalidate stored valid bits; detect the live-rm UF boundary exposed by the source RTL.

checker: Predict the elastic two-stage registers and exact arithmetic from input history, perform four-state comparisons of valid data and control, and report UVM_ERROR on mismatches; event counts for backpressure, flush, reset, wide sidebands, and the UF boundary must be nonzero.

implementation_id: V8

source: profiles/original_pipe2/stimulus.svh:history; profiles/original_pipe2/pins_pkg.sv:pin_monitor.run_phase/pin_scoreboard.write; model/model.sv


Specific expectations for the two-stage UF boundary: When the encoding is the minimum normal and NX=1, for a distance strictly between 1/4 and 1/2 subnormal steps, UF is determined by whether the live external rm is RNE/RMM; when the distance is >=1/2, UF=1, and when it is <=1/4, UF=0.
