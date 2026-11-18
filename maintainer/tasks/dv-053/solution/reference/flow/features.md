# features

## F1

feature_id: F1

requirement_ids: ["R-dv-053-001"]

module: BTBBranchPredictorBank

definition: The complete BTBBranchPredictorBank with both original 128-row target/tag memory types and the supplied reduced ebtb_128x40 dependency is in scope. There are four slots, two ways, no top parameters and no backpressure. All native input bit patterns are legal. State updates at rising clock edges; reset is synchronous active high. Unknown initial storage/pipeline state stays unspecified until initialized. Reset sets only a sweep flag and index; request/update/output pipeline captures continue through reset.

interface: ["clock", "io_f0_pc", "io_f0_valid", "io_update_valid", "reset"]

timing: Drive at falling edges, update at rising edges and sample after propagation settles.

boundary: Initialize all native inputs, generate a10ns clock, drive on falling edges and sample after settling. Maintain independent two-way table, folded extended-memory and pipeline state solely from input history; retain unknowns before initialization. Assert/deassert and repeat synchronous reset while requests and updates continue; distinguish unspecified startup, reset sweep and payload captures.

## F2

feature_id: F2

requirement_ids: ["R-dv-053-002"]

module: BTBBranchPredictorBank

definition: Each way contains 128 rows of four 14-bit target entries and four 30-bit metadata entries. The lookup edge captures f0_valid, row pc[10:4] and full pc. Memory read output is current contents of that captured row when captured valid is one, and unknown otherwise. Each slot compares the29 low bits of its metadata with captured pc[39:11], with no separate valid bit. Either matching way is a hit; way0 has priority if both match. Therefore zeroed tags can hit tag zero. Target bits13:1 hold a signed13-bit offset and bit0 selects extended target; metadata bit29 classifies branch, zero classifies jump.

interface: ["clock", "io_f0_pc", "io_f0_valid", "io_resp_f2_0_is_br", "io_resp_f2_0_is_jal", "io_resp_f2_0_predicted_pc_valid", "io_resp_f2_1_is_br", "io_resp_f2_1_is_jal", "io_resp_f2_1_predicted_pc_valid", "io_resp_f2_2_is_br", "io_resp_f2_2_is_jal", "io_resp_f2_2_predicted_pc_valid", "io_resp_f2_3_is_br", "io_resp_f2_3_is_jal", "io_resp_f2_3_predicted_pc_valid"]

timing: Drive at falling edges, update at rising edges and sample after propagation settles.

boundary: Initialize all native inputs, generate a10ns clock, drive on falling edges and sample after settling. Maintain independent two-way table, folded extended-memory and pipeline state solely from input history; retain unknowns before initialization. Train both ways with distinct tags and offsets, request matching/nonmatching tags, create simultaneous dual hits, and use tag zero after reset; cross all four slots and read-enable bubbles.

## F3

feature_id: F3

requirement_ids: ["R-dv-053-003"]

module: BTBBranchPredictorBank

definition: A lookup result target for slot j is captured PC plus the sign-extended13-bit offset plus2*j, modulo40 bits, unless the selected target entry's extended bit is one, in which case it is the extended-memory read value. The supplied extended memory has16 rows with folded row h(R)=R[3:0] XOR zero-extended R[6:4]. It captures the current read enable and folded lookup row each edge, returns unknown when that enable is zero, and shares one40-bit target across all slots and both ways for that row. Its writes use the previous edge's captured folded update row, while data and write enable are current delayed-update controls. It has no reset clearing.

interface: ["clock", "io_f0_pc", "io_f0_valid", "io_resp_f2_0_predicted_pc_bits", "io_resp_f2_1_predicted_pc_bits", "io_resp_f2_2_predicted_pc_bits", "io_resp_f2_3_predicted_pc_bits", "io_resp_f3_0_predicted_pc_bits", "io_resp_f3_1_predicted_pc_bits", "io_resp_f3_2_predicted_pc_bits", "io_resp_f3_3_predicted_pc_bits", "io_update_bits_pc", "io_update_bits_target"]

timing: Drive at falling edges, update at rising edges and sample after propagation settles.

boundary: Initialize all native inputs, generate a10ns clock, drive on falling edges and sample after settling. Maintain independent two-way table, folded extended-memory and pipeline state solely from input history; retain unknowns before initialization. Exercise signed offsets-4096,-2049,-1,0,2048,4095,4096,4097 and modular wrap, all slot additions, extended aliases and alternating update addresses to expose the previous write row.

## F4

feature_id: F4

requirement_ids: ["R-dv-053-004"]

module: BTBBranchPredictorBank

definition: Every slot registers lookup hit as an override flag regardless of reset/sweep and registers predicted PC bits unconditionally. Its registered prediction-valid is pre-edge not-sweeping AND captured request-valid AND hit. Its branch/jump flags add the selected classification bit or its inverse. At f2, predicted PC valid/bits and is_br/is_jal select that registered prediction on override-hit, otherwise the current same-phase upstream input. f2 taken is upstream f2 taken OR registered-hit AND registered-valid-jump; upstream taken is preserved even on a branch hit. All f1 outputs always copy upstream f1 fields continuously.

interface: ["clock", "io_resp_f1_0_is_br", "io_resp_f1_0_is_jal", "io_resp_f1_0_predicted_pc_bits", "io_resp_f1_0_predicted_pc_valid", "io_resp_f1_0_taken", "io_resp_f1_1_is_br", "io_resp_f1_1_is_jal", "io_resp_f1_1_predicted_pc_bits", "io_resp_f1_1_predicted_pc_valid", "io_resp_f1_1_taken", "io_resp_f1_2_is_br", "io_resp_f1_2_is_jal", "io_resp_f1_2_predicted_pc_bits", "io_resp_f1_2_predicted_pc_valid", "io_resp_f1_2_taken", "io_resp_f1_3_is_br", "io_resp_f1_3_is_jal", "io_resp_f1_3_predicted_pc_bits", "io_resp_f1_3_predicted_pc_valid", "io_resp_f1_3_taken", "io_resp_f2_0_is_br", "io_resp_f2_0_is_jal", "io_resp_f2_0_predicted_pc_bits", "io_resp_f2_0_predicted_pc_valid", "io_resp_f2_0_taken", "io_resp_f2_1_is_br", "io_resp_f2_1_is_jal", "io_resp_f2_1_predicted_pc_bits", "io_resp_f2_1_predicted_pc_valid", "io_resp_f2_1_taken", "io_resp_f2_2_is_br", "io_resp_f2_2_is_jal", "io_resp_f2_2_predicted_pc_bits", "io_resp_f2_2_predicted_pc_valid", "io_resp_f2_2_taken", "io_resp_f2_3_is_br", "io_resp_f2_3_is_jal", "io_resp_f2_3_predicted_pc_bits", "io_resp_f2_3_predicted_pc_valid", "io_resp_f2_3_taken", "io_resp_in_0_f1_0_is_br", "io_resp_in_0_f1_0_is_jal", "io_resp_in_0_f1_0_predicted_pc_bits", "io_resp_in_0_f1_0_predicted_pc_valid", "io_resp_in_0_f1_0_taken", "io_resp_in_0_f1_1_is_br", "io_resp_in_0_f1_1_is_jal", "io_resp_in_0_f1_1_predicted_pc_bits", "io_resp_in_0_f1_1_predicted_pc_valid", "io_resp_in_0_f1_1_taken", "io_resp_in_0_f1_2_is_br", "io_resp_in_0_f1_2_is_jal", "io_resp_in_0_f1_2_predicted_pc_bits", "io_resp_in_0_f1_2_predicted_pc_valid", "io_resp_in_0_f1_2_taken", "io_resp_in_0_f1_3_is_br", "io_resp_in_0_f1_3_is_jal", "io_resp_in_0_f1_3_predicted_pc_bits", "io_resp_in_0_f1_3_predicted_pc_valid", "io_resp_in_0_f1_3_taken", "io_resp_in_0_f2_0_is_br", "io_resp_in_0_f2_0_is_jal", "io_resp_in_0_f2_0_predicted_pc_bits", "io_resp_in_0_f2_0_predicted_pc_valid", "io_resp_in_0_f2_0_taken", "io_resp_in_0_f2_1_is_br", "io_resp_in_0_f2_1_is_jal", "io_resp_in_0_f2_1_predicted_pc_bits", "io_resp_in_0_f2_1_predicted_pc_valid", "io_resp_in_0_f2_1_taken", "io_resp_in_0_f2_2_is_br", "io_resp_in_0_f2_2_is_jal", "io_resp_in_0_f2_2_predicted_pc_bits", "io_resp_in_0_f2_2_predicted_pc_valid", "io_resp_in_0_f2_2_taken", "io_resp_in_0_f2_3_is_br", "io_resp_in_0_f2_3_is_jal", "io_resp_in_0_f2_3_predicted_pc_bits", "io_resp_in_0_f2_3_predicted_pc_valid", "io_resp_in_0_f2_3_taken"]

timing: Drive at falling edges, update at rising edges and sample after propagation settles.

boundary: Initialize all native inputs, generate a10ns clock, drive on falling edges and sample after settling. Maintain independent two-way table, folded extended-memory and pipeline state solely from input history; retain unknowns before initialization. Set upstream taken/valid/branch/jump independently under hits/misses, invalid f0 and sweep; verify f1 copies, f2 override priority and OR taken truth table.

## F5

feature_id: F5

requirement_ids: ["R-dv-053-005"]

module: BTBBranchPredictorBank

definition: At every edge the f3 override flag captures the f2 override flag, and f3 prediction fields capture the pre-edge merged f2 PC/valid/branch/jump fields. f3 chooses those captured fields on its delayed override, otherwise current upstream f3 fields. f3 taken ORs current upstream f3 taken with the correspondingly delayed hit AND valid-jump injection. Reset does not directly clear these registers. Replacement metadata is also two captures: on any slot hit choose way0 if any slot hits way0, otherwise way1; on no hits choose XOR parity of captured pc[39:11] and all29-bit tags for every slot in both lookup ways. io_f3_meta bit0 exposes that choice after two captures and bits119:1 are always zero, independently of request valid and reset.

interface: ["clock", "io_f0_pc", "io_f3_meta", "io_resp_f3_0_is_br", "io_resp_f3_0_is_jal", "io_resp_f3_0_predicted_pc_bits", "io_resp_f3_0_predicted_pc_valid", "io_resp_f3_0_taken", "io_resp_f3_1_is_br", "io_resp_f3_1_is_jal", "io_resp_f3_1_predicted_pc_bits", "io_resp_f3_1_predicted_pc_valid", "io_resp_f3_1_taken", "io_resp_f3_2_is_br", "io_resp_f3_2_is_jal", "io_resp_f3_2_predicted_pc_bits", "io_resp_f3_2_predicted_pc_valid", "io_resp_f3_2_taken", "io_resp_f3_3_is_br", "io_resp_f3_3_is_jal", "io_resp_f3_3_predicted_pc_bits", "io_resp_f3_3_predicted_pc_valid", "io_resp_f3_3_taken", "io_resp_in_0_f3_0_is_br", "io_resp_in_0_f3_0_is_jal", "io_resp_in_0_f3_0_predicted_pc_bits", "io_resp_in_0_f3_0_predicted_pc_valid", "io_resp_in_0_f3_0_taken", "io_resp_in_0_f3_1_is_br", "io_resp_in_0_f3_1_is_jal", "io_resp_in_0_f3_1_predicted_pc_bits", "io_resp_in_0_f3_1_predicted_pc_valid", "io_resp_in_0_f3_1_taken", "io_resp_in_0_f3_2_is_br", "io_resp_in_0_f3_2_is_jal", "io_resp_in_0_f3_2_predicted_pc_bits", "io_resp_in_0_f3_2_predicted_pc_valid", "io_resp_in_0_f3_2_taken", "io_resp_in_0_f3_3_is_br", "io_resp_in_0_f3_3_is_jal", "io_resp_in_0_f3_3_predicted_pc_bits", "io_resp_in_0_f3_3_predicted_pc_valid", "io_resp_in_0_f3_3_taken"]

timing: Drive at falling edges, update at rising edges and sample after propagation settles.

boundary: Initialize all native inputs, generate a10ns clock, drive on falling edges and sample after settling. Maintain independent two-way table, folded extended-memory and pipeline state solely from input history; retain unknowns before initialization. Change upstream f2 and f3 on adjacent cycles to check exact f3 capture versus current bypass; check replacement on way0 hit, way1-only hit and no-hit parity, and all119 high zero metadata bits.

## F6

feature_id: F6

requirement_ids: ["R-dv-053-006"]

module: BTBBranchPredictorBank

definition: All native update fields are sampled every edge; delayed controls apply on the next edge. A normal update requires delayed valid and no is_mispredict_update, no is_repair_update and no btb_mispredicts bits. Target write selects only cfi_idx_bits when normal AND cfi_idx_valid AND cfi_taken. Delayed meta bit0 selects the written way; row is update PC[10:4]. Compute40-bit modular difference target-(update PC+2*cfi_idx_bits), interpret that difference signed40: offsets from-4096 through4095 inclusive are relative, all others are extended. A selected target entry stores low13 difference bits and the extended flag. Every selected extended update also writes the full target to the shared extended store using its previous captured write row, even during sweeping.

interface: ["clock", "io_update_bits_br_mask", "io_update_bits_btb_mispredicts", "io_update_bits_cfi_idx_bits", "io_update_bits_cfi_idx_valid", "io_update_bits_cfi_taken", "io_update_bits_is_mispredict_update", "io_update_bits_is_repair_update", "io_update_bits_meta", "io_update_bits_pc", "io_update_bits_target", "io_update_valid", "reset"]

timing: Drive at falling edges, update at rising edges and sample after propagation settles.

boundary: Initialize all native inputs, generate a10ns clock, drive on falling edges and sample after settling. Maintain independent two-way table, folded extended-memory and pipeline state solely from input history; retain unknowns before initialization. Cross every update enable/suppressor, selected-index valid/taken, both ways and all slots; target offset boundaries, single-bit masks and update bubbles must preserve unwritten entries.

## F7

feature_id: F7

requirement_ids: ["R-dv-053-007"]

module: BTBBranchPredictorBank

definition: Outside sweep, metadata slot j writes in the delayed selected way when (target-write-selected[j] OR br_mask[j]) AND (normal-update OR delayed-valid AND btb_mispredicts[j]). The new classification bit is br_mask[j]. Its29-bit tag is zero when btb_mispredicts[j] is one and delayed update PC[39:11] otherwise. Thus selective bad-slot invalidation can write zero tags even while ordinary repair/mispredict suppresses target training; the exact mask conditions still apply. Unwritten entries retain all bits. Meta bits119:1 and all other native update fields absent from these rules do not alter state.

interface: ["clock", "io_update_bits_br_mask", "io_update_bits_btb_mispredicts", "io_update_bits_cfi_idx_bits", "io_update_bits_cfi_idx_valid", "io_update_bits_cfi_taken", "io_update_bits_is_mispredict_update", "io_update_bits_is_repair_update", "io_update_bits_meta", "io_update_bits_pc", "io_update_valid", "reset"]

timing: Drive at falling edges, update at rising edges and sample after propagation settles.

boundary: Initialize all native inputs, generate a10ns clock, drive on falling edges and sample after settling. Maintain independent two-way table, folded extended-memory and pipeline state solely from input history; retain unknowns before initialization. Cross branch masks with each bad-slot bit under normal, repair and mispredict controls; verify selective zero tags, classification and unchanged target entries independently.

## F8

feature_id: F8

requirement_ids: ["R-dv-053-008"]

module: BTBBranchPredictorBank

definition: A reset edge sets sweep active and index zero. Each nonreset edge seeing sweep active writes all four target entries and all four metadata entries to zero in both ways at the current sweep index, then increments the7-bit index; the edge with pre-index127 ends the sweep. While sweep is active the standard target/tag write address, enables, masks and data use this reset operation, overriding delayed training for those memories; the pre-edge sweep controls also apply on reset edges. Extended writes remain independent. Lookup and output pipelines keep advancing. Compare all native outputs, including invalid-cycle PC bits, upstream fields and replacement metadata; full-width PCs, per-slot masks and both ways remain independent.

interface: ["clock", "io_f0_pc", "io_f0_valid", "io_f3_meta", "io_resp_f2_0_predicted_pc_valid", "io_resp_f2_1_predicted_pc_valid", "io_resp_f2_2_predicted_pc_valid", "io_resp_f2_3_predicted_pc_valid", "io_update_valid", "reset"]

timing: Drive at falling edges, update at rising edges and sample after propagation settles.

boundary: Initialize all native inputs, generate a10ns clock, drive on falling edges and sample after settling. Maintain independent two-way table, folded extended-memory and pipeline state solely from input history; retain unknowns before initialization. Check sweep indices0,126,127 and completion under active lookups/updates, repeat reset and preserve extended data; randomize every full-width upstream field and PC bit while comparing all valid and invalid outputs.
