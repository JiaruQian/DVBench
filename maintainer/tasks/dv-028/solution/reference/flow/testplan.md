# testplan

## T1

test_id: T1

feature_ids: ["F1"]

requirement_ids: ["R-dv-028-001"]

stimulus: Initialize every native input, generate a 10 ns clock and sample reset on rising edges; drive inputs on falling edges and establish two known rising-edge histories before numerical state checks. Use legal two-state values for every full-width native port, maintain an independent two-stage input-history predictor and compare all registered and combinational outputs. Trace both pipeline stages through reset on/off, bubbles and simultaneous independent lane issue; check valid and payload timing separately.

expected: RegisterRead has two issue lanes and two synchronous pipeline stages, six external register-file read ports, no top parameters and no backpressure. All native input bits are legal two-state values. At each rising edge, a first stage captures current issue metadata and decoded controls. The second stage captures the previous first-stage contents. Numeric state before initialization is unspecified; establish known inputs over two rising edges before numerical state checks. Reset is synchronous active high and clears only the two execution valid outputs; it does not clear either metadata stage, operand data or register-file addresses. Combinational addresses and registered payload remain observable with valid low.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates only at rising edges. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T2

test_id: T2

feature_ids: ["F2"]

requirement_ids: ["R-dv-028-002"]

stimulus: Initialize every native input, generate a 10 ns clock and sample reset on rising edges; drive inputs on falling edges and establish two known rising-edge histories before numerical state checks. Use legal two-state values for every full-width native port, maintain an independent two-stage input-history predictor and compare all registered and combinational outputs. Exercise all six ports with nonzero distinguishable 65-bit data, zero and nonzero physical indices, type values, kill/reset overlap and valid bubbles. Change RF data between issue and execution edges to verify sampling phase.

expected: Read-port addresses 0/1/2 continuously equal lane 0 prs1/prs2/prs3; addresses 3/4/5 continuously equal lane 1 prs1/prs2/prs3, independently of valid, kill and reset. At each rising edge the execution operand data captures the current corresponding 65-bit external read data unless that operand's physical source index captured at the previous edge was zero, in which case it captures 65-bit zero. The zero-source flags depend solely on physical index equality to zero, not type, valid or lane. Kill/reset do not gate operand capture.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates only at rising edges. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T3

test_id: T3

feature_ids: ["F3"]

requirement_ids: ["R-dv-028-003"]

stimulus: Initialize every native input, generate a 10 ns clock and sample reset on rising edges; drive inputs on falling edges and establish two known rising-edge histories before numerical state checks. Use legal two-state values for every full-width native port, maintain an independent two-stage input-history predictor and compare all registered and combinational outputs. Cross issue valid, mispredict overlap and resolve overlap in each lane; include a bit simultaneously resolved and mispredicted so valid uses original mask but stored mask clears resolve.

expected: For each lane, the first-stage valid captures issue valid AND no overlap between the original current issue branch mask and current mispredict mask. It is updated even during reset and io_kill. The first-stage branch mask captures current issue mask with all current resolve-mask bits cleared; all other metadata is captured every edge regardless of valid. The two poison fields are generated as zero. Decoded control and immediate exceptions below replace their corresponding incoming fields.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates only at rising edges. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T4

test_id: T4

feature_ids: ["F4"]

requirement_ids: ["R-dv-028-004"]

stimulus: Initialize every native input, generate a 10 ns clock and sample reset on rising edges; drive inputs on falling edges and establish two known rising-edge histories before numerical state checks. Use legal two-state values for every full-width native port, maintain an independent two-stage input-history predictor and compare all registered and combinational outputs. Set io_kill alone, each lane's stored-mask mispredict alone and their combination; resolve a bit at the prior edge then mispredict it at the next edge. Reset overrides execution valid only.

expected: For each lane independently, second-stage cancel is current io_kill OR an overlap of that lane's stored first-stage branch mask with the current mispredict mask. On the rising edge reset sets execution valid zero; otherwise execution valid captures previous first-stage valid AND no cancel. There is no cross-lane mask use. Misprediction is tested on the stored mask after the previous edge's resolution, so already resolved bits cannot later cancel through that stored bit.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates only at rising edges. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T5

test_id: T5

feature_ids: ["F5"]

requirement_ids: ["R-dv-028-005"]

stimulus: Initialize every native input, generate a 10 ns clock and sample reset on rising edges; drive inputs on falling edges and establish two known rising-edge histories before numerical state checks. Use legal two-state values for every full-width native port, maintain an independent two-stage input-history predictor and compare all registered and combinational outputs. Kill distinctive metadata with dst_rtype 0/1/2/3; verify cancelled dst_rtype two, all other zero defaults, branch-mask continuing resolution and operand data unaffected. Contrast reset without kill.

expected: At each rising edge, execution metadata takes the previous first-stage metadata when not cancelled. When cancelled every metadata field becomes zero except dst_rtype becomes numeric two and br_mask still equals the stored first-stage branch mask with current resolve bits cleared. This branch-mask update occurs even when cancelled, reset or invalid. Reset alone does not force metadata to the cancelled values. Poison fields remain zero once initialized. Operand data is independent of this metadata cancellation.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates only at rising edges. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T6

test_id: T6

feature_ids: ["F6"]

requirement_ids: ["R-dv-028-006"]

stimulus: Initialize every native input, generate a 10 ns clock and sample reset on rising edges; drive inputs on falling edges and establish two known rising-edge histories before numerical state checks. Use legal two-state values for every full-width native port, maintain an independent two-stage input-history predictor and compare all registered and combinational outputs. Enumerate all 128 uopc values for both lanes and all lrs2_rtype values; cross mem_cmd six/non-six at load opcode and uopc 67. Verify every six-field decode-table entry and immediate exceptions after pipeline delay.

expected: The exact numeric shared decode table in public/decode.md defines br_type, op1_sel, op2_sel, imm_sel, op_fcn and fcn_dw for all 128 uopc values. csr_cmd is always zero. is_load is one only for uopc 1; is_sta only for uopc 2 or 67; is_std for uopc 3, or for uopc 2/67 with lrs2_rtype zero. The decoded immediate is zero for uopc 67 and for uopc 1 with mem_cmd six, otherwise it copies issue imm_packed. Other metadata fields pass to the first stage without opcode-dependent change. No architectural instruction legality restriction narrows the seven-bit opcode domain.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates only at rising edges. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T7

test_id: T7

feature_ids: ["F7"]

requirement_ids: ["R-dv-028-007"]

stimulus: Initialize every native input, generate a 10 ns clock and sample reset on rising edges; drive inputs on falling edges and establish two known rising-edge histories before numerical state checks. Use legal two-state values for every full-width native port, maintain an independent two-stage input-history predictor and compare all registered and combinational outputs. Apply opcodes 100,101,102,103,104,105 and 86 concurrently on both lanes with kill disabled; compare numeric function differences at exactly 101..104 and identical decoding elsewhere.

expected: Both lanes use the shared table except uopc 101,102,103,104: lane 0 op_fcn is 15 and lane 1 op_fcn is zero. All other decoded fields for those opcodes follow the shared default. This is an observable lane asymmetry, not an unsupported-domain omission. Both lanes accept the complete uopc 0..127 domain and can issue independently and simultaneously.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates only at rising edges. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T8

test_id: T8

feature_ids: ["F8"]

requirement_ids: ["R-dv-028-008"]

stimulus: Initialize every native input, generate a 10 ns clock and sample reset on rising edges; drive inputs on falling edges and establish two known rising-edge histories before numerical state checks. Use legal two-state values for every full-width native port, maintain an independent two-stage input-history predictor and compare all registered and combinational outputs. Randomize all metadata fields over their full declared widths with nonzero high bits and independent lane patterns, vary valid low/high, global kill and per-lane masks, and verify complete output-bit preservation and both timing histories.

expected: Every native metadata field not changed by the specified decode, immediate, branch-mask, poison or cancellation rules is forwarded exactly through both stages, including every declared high bit. Execution output metadata therefore corresponds to issue inputs sampled one edge earlier, while operand data uses current RF input data and one-edge-old zero-source flags. Changes in issue valid do not freeze metadata. One lane's issue contents, source indices or cancellation mask cannot alter the other lane's metadata or operands; shared global kill and branch updates apply by their stated per-lane rules.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates only at rising edges. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv
