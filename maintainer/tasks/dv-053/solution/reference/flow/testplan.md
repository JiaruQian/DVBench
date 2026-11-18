# testplan

## T1

test_id: T1

feature_ids: ["F1"]

requirement_ids: ["R-dv-053-001"]

stimulus: Initialize all native inputs, generate a10ns clock, drive on falling edges and sample after settling. Maintain independent two-way table, folded extended-memory and pipeline state solely from input history; retain unknowns before initialization. Assert/deassert and repeat synchronous reset while requests and updates continue; distinguish unspecified startup, reset sweep and payload captures.

expected: The complete BTBBranchPredictorBank with both original 128-row target/tag memory types and the supplied reduced ebtb_128x40 dependency is in scope. There are four slots, two ways, no top parameters and no backpressure. All native input bit patterns are legal. State updates at rising clock edges; reset is synchronous active high. Unknown initial storage/pipeline state stays unspecified until initialized. Reset sets only a sweep flag and index; request/update/output pipeline captures continue through reset.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates only at rising edges. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T2

test_id: T2

feature_ids: ["F2"]

requirement_ids: ["R-dv-053-002"]

stimulus: Initialize all native inputs, generate a10ns clock, drive on falling edges and sample after settling. Maintain independent two-way table, folded extended-memory and pipeline state solely from input history; retain unknowns before initialization. Train both ways with distinct tags and offsets, request matching/nonmatching tags, create simultaneous dual hits, and use tag zero after reset; cross all four slots and read-enable bubbles.

expected: Each way contains 128 rows of four 14-bit target entries and four 30-bit metadata entries. The lookup edge captures f0_valid, row pc[10:4] and full pc. Memory read output is current contents of that captured row when captured valid is one, and unknown otherwise. Each slot compares the29 low bits of its metadata with captured pc[39:11], with no separate valid bit. Either matching way is a hit; way0 has priority if both match. Therefore zeroed tags can hit tag zero. Target bits13:1 hold a signed13-bit offset and bit0 selects extended target; metadata bit29 classifies branch, zero classifies jump.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates only at rising edges. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T3

test_id: T3

feature_ids: ["F3"]

requirement_ids: ["R-dv-053-003"]

stimulus: Initialize all native inputs, generate a10ns clock, drive on falling edges and sample after settling. Maintain independent two-way table, folded extended-memory and pipeline state solely from input history; retain unknowns before initialization. Exercise signed offsets-4096,-2049,-1,0,2048,4095,4096,4097 and modular wrap, all slot additions, extended aliases and alternating update addresses to expose the previous write row.

expected: A lookup result target for slot j is captured PC plus the sign-extended13-bit offset plus2*j, modulo40 bits, unless the selected target entry's extended bit is one, in which case it is the extended-memory read value. The supplied extended memory has16 rows with folded row h(R)=R[3:0] XOR zero-extended R[6:4]. It captures the current read enable and folded lookup row each edge, returns unknown when that enable is zero, and shares one40-bit target across all slots and both ways for that row. Its writes use the previous edge's captured folded update row, while data and write enable are current delayed-update controls. It has no reset clearing.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates only at rising edges. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T4

test_id: T4

feature_ids: ["F4"]

requirement_ids: ["R-dv-053-004"]

stimulus: Initialize all native inputs, generate a10ns clock, drive on falling edges and sample after settling. Maintain independent two-way table, folded extended-memory and pipeline state solely from input history; retain unknowns before initialization. Set upstream taken/valid/branch/jump independently under hits/misses, invalid f0 and sweep; verify f1 copies, f2 override priority and OR taken truth table.

expected: Every slot registers lookup hit as an override flag regardless of reset/sweep and registers predicted PC bits unconditionally. Its registered prediction-valid is pre-edge not-sweeping AND captured request-valid AND hit. Its branch/jump flags add the selected classification bit or its inverse. At f2, predicted PC valid/bits and is_br/is_jal select that registered prediction on override-hit, otherwise the current same-phase upstream input. f2 taken is upstream f2 taken OR registered-hit AND registered-valid-jump; upstream taken is preserved even on a branch hit. All f1 outputs always copy upstream f1 fields continuously.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates only at rising edges. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T5

test_id: T5

feature_ids: ["F5"]

requirement_ids: ["R-dv-053-005"]

stimulus: Initialize all native inputs, generate a10ns clock, drive on falling edges and sample after settling. Maintain independent two-way table, folded extended-memory and pipeline state solely from input history; retain unknowns before initialization. Change upstream f2 and f3 on adjacent cycles to check exact f3 capture versus current bypass; check replacement on way0 hit, way1-only hit and no-hit parity, and all119 high zero metadata bits.

expected: At every edge the f3 override flag captures the f2 override flag, and f3 prediction fields capture the pre-edge merged f2 PC/valid/branch/jump fields. f3 chooses those captured fields on its delayed override, otherwise current upstream f3 fields. f3 taken ORs current upstream f3 taken with the correspondingly delayed hit AND valid-jump injection. Reset does not directly clear these registers. Replacement metadata is also two captures: on any slot hit choose way0 if any slot hits way0, otherwise way1; on no hits choose XOR parity of captured pc[39:11] and all29-bit tags for every slot in both lookup ways. io_f3_meta bit0 exposes that choice after two captures and bits119:1 are always zero, independently of request valid and reset.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates only at rising edges. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T6

test_id: T6

feature_ids: ["F6"]

requirement_ids: ["R-dv-053-006"]

stimulus: Initialize all native inputs, generate a10ns clock, drive on falling edges and sample after settling. Maintain independent two-way table, folded extended-memory and pipeline state solely from input history; retain unknowns before initialization. Cross every update enable/suppressor, selected-index valid/taken, both ways and all slots; target offset boundaries, single-bit masks and update bubbles must preserve unwritten entries.

expected: All native update fields are sampled every edge; delayed controls apply on the next edge. A normal update requires delayed valid and no is_mispredict_update, no is_repair_update and no btb_mispredicts bits. Target write selects only cfi_idx_bits when normal AND cfi_idx_valid AND cfi_taken. Delayed meta bit0 selects the written way; row is update PC[10:4]. Compute40-bit modular difference target-(update PC+2*cfi_idx_bits), interpret that difference signed40: offsets from-4096 through4095 inclusive are relative, all others are extended. A selected target entry stores low13 difference bits and the extended flag. Every selected extended update also writes the full target to the shared extended store using its previous captured write row, even during sweeping.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates only at rising edges. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T7

test_id: T7

feature_ids: ["F7"]

requirement_ids: ["R-dv-053-007"]

stimulus: Initialize all native inputs, generate a10ns clock, drive on falling edges and sample after settling. Maintain independent two-way table, folded extended-memory and pipeline state solely from input history; retain unknowns before initialization. Cross branch masks with each bad-slot bit under normal, repair and mispredict controls; verify selective zero tags, classification and unchanged target entries independently.

expected: Outside sweep, metadata slot j writes in the delayed selected way when (target-write-selected[j] OR br_mask[j]) AND (normal-update OR delayed-valid AND btb_mispredicts[j]). The new classification bit is br_mask[j]. Its29-bit tag is zero when btb_mispredicts[j] is one and delayed update PC[39:11] otherwise. Thus selective bad-slot invalidation can write zero tags even while ordinary repair/mispredict suppresses target training; the exact mask conditions still apply. Unwritten entries retain all bits. Meta bits119:1 and all other native update fields absent from these rules do not alter state.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates only at rising edges. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv

## T8

test_id: T8

feature_ids: ["F8"]

requirement_ids: ["R-dv-053-008"]

stimulus: Initialize all native inputs, generate a10ns clock, drive on falling edges and sample after settling. Maintain independent two-way table, folded extended-memory and pipeline state solely from input history; retain unknowns before initialization. Check sweep indices0,126,127 and completion under active lookups/updates, repeat reset and preserve extended data; randomize every full-width upstream field and PC bit while comparing all valid and invalid outputs.

expected: A reset edge sets sweep active and index zero. Each nonreset edge seeing sweep active writes all four target entries and all four metadata entries to zero in both ways at the current sweep index, then increments the7-bit index; the edge with pre-index127 ends the sweep. While sweep is active the standard target/tag write address, enables, masks and data use this reset operation, overriding delayed training for those memories; the pre-edge sweep controls also apply on reset edges. Extended writes remain independent. Lookup and output pipelines keep advancing. Compare all native outputs, including invalid-cycle PC bits, upstream fields and replacement metadata; full-width PCs, per-slot masks and both ways remain independent.

checker: Drive inputs at falling clock edges and sample all native actual and independent model outputs after 2 ns. Model state updates only at rising edges. Compare with four-state !==, require 4096 observations and fail on every mismatch or empty run. Numerical uninitialized payload is not assigned an invented value; preserve four-state unknowns until an accepted capture initializes it.

implementation_id: aluexe_if.prepare+aluexe_sequence+aluexe_scoreboard

source: tb/aluexe_if.sv;tb/aluexe_pkg.sv;model/model.sv
