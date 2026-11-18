# features

## F1

feature_id: F1

requirement_ids: ["R-dv-028-001"]

module: RegisterRead

definition: RegisterRead has two issue lanes and two synchronous pipeline stages, six external register-file read ports, no top parameters and no backpressure. All native input bits are legal two-state values. At each rising edge, a first stage captures current issue metadata and decoded controls. The second stage captures the previous first-stage contents. Numeric state before initialization is unspecified; establish known inputs over two rising edges before numerical state checks. Reset is synchronous active high and clears only the two execution valid outputs; it does not clear either metadata stage, operand data or register-file addresses. Combinational addresses and registered payload remain observable with valid low.

interface: ["clock", "io_exe_reqs_0_valid", "io_exe_reqs_1_valid", "io_iss_valids_0", "io_iss_valids_1", "reset"]

timing: Drive at falling edges, update at rising edges and sample after propagation settles.

boundary: Initialize every native input, generate a 10 ns clock and sample reset on rising edges; drive inputs on falling edges and establish two known rising-edge histories before numerical state checks. Use legal two-state values for every full-width native port, maintain an independent two-stage input-history predictor and compare all registered and combinational outputs. Trace both pipeline stages through reset on/off, bubbles and simultaneous independent lane issue; check valid and payload timing separately.

## F2

feature_id: F2

requirement_ids: ["R-dv-028-002"]

module: RegisterRead

definition: Read-port addresses 0/1/2 continuously equal lane 0 prs1/prs2/prs3; addresses 3/4/5 continuously equal lane 1 prs1/prs2/prs3, independently of valid, kill and reset. At each rising edge the execution operand data captures the current corresponding 65-bit external read data unless that operand's physical source index captured at the previous edge was zero, in which case it captures 65-bit zero. The zero-source flags depend solely on physical index equality to zero, not type, valid or lane. Kill/reset do not gate operand capture.

interface: ["clock", "io_exe_reqs_0_bits_rs1_data", "io_exe_reqs_0_bits_rs2_data", "io_exe_reqs_0_bits_rs3_data", "io_exe_reqs_1_bits_rs1_data", "io_exe_reqs_1_bits_rs2_data", "io_exe_reqs_1_bits_rs3_data", "io_iss_uops_0_prs1", "io_iss_uops_0_prs2", "io_iss_uops_0_prs3", "io_iss_uops_1_prs1", "io_iss_uops_1_prs2", "io_iss_uops_1_prs3", "io_rf_read_ports_0_addr", "io_rf_read_ports_0_data", "io_rf_read_ports_1_addr", "io_rf_read_ports_1_data", "io_rf_read_ports_2_addr", "io_rf_read_ports_2_data", "io_rf_read_ports_3_addr", "io_rf_read_ports_3_data", "io_rf_read_ports_4_addr", "io_rf_read_ports_4_data", "io_rf_read_ports_5_addr", "io_rf_read_ports_5_data"]

timing: Drive at falling edges, update at rising edges and sample after propagation settles.

boundary: Initialize every native input, generate a 10 ns clock and sample reset on rising edges; drive inputs on falling edges and establish two known rising-edge histories before numerical state checks. Use legal two-state values for every full-width native port, maintain an independent two-stage input-history predictor and compare all registered and combinational outputs. Exercise all six ports with nonzero distinguishable 65-bit data, zero and nonzero physical indices, type values, kill/reset overlap and valid bubbles. Change RF data between issue and execution edges to verify sampling phase.

## F3

feature_id: F3

requirement_ids: ["R-dv-028-003"]

module: RegisterRead

definition: For each lane, the first-stage valid captures issue valid AND no overlap between the original current issue branch mask and current mispredict mask. It is updated even during reset and io_kill. The first-stage branch mask captures current issue mask with all current resolve-mask bits cleared; all other metadata is captured every edge regardless of valid. The two poison fields are generated as zero. Decoded control and immediate exceptions below replace their corresponding incoming fields.

interface: ["clock", "io_brupdate_b1_mispredict_mask", "io_brupdate_b1_resolve_mask", "io_exe_reqs_0_bits_uop_iw_p1_poisoned", "io_exe_reqs_0_bits_uop_iw_p2_poisoned", "io_exe_reqs_1_bits_uop_iw_p1_poisoned", "io_exe_reqs_1_bits_uop_iw_p2_poisoned", "io_iss_uops_0_br_mask", "io_iss_uops_1_br_mask", "io_iss_valids_0", "io_iss_valids_1"]

timing: Drive at falling edges, update at rising edges and sample after propagation settles.

boundary: Initialize every native input, generate a 10 ns clock and sample reset on rising edges; drive inputs on falling edges and establish two known rising-edge histories before numerical state checks. Use legal two-state values for every full-width native port, maintain an independent two-stage input-history predictor and compare all registered and combinational outputs. Cross issue valid, mispredict overlap and resolve overlap in each lane; include a bit simultaneously resolved and mispredicted so valid uses original mask but stored mask clears resolve.

## F4

feature_id: F4

requirement_ids: ["R-dv-028-004"]

module: RegisterRead

definition: For each lane independently, second-stage cancel is current io_kill OR an overlap of that lane's stored first-stage branch mask with the current mispredict mask. On the rising edge reset sets execution valid zero; otherwise execution valid captures previous first-stage valid AND no cancel. There is no cross-lane mask use. Misprediction is tested on the stored mask after the previous edge's resolution, so already resolved bits cannot later cancel through that stored bit.

interface: ["clock", "io_brupdate_b1_mispredict_mask", "io_brupdate_b1_resolve_mask", "io_exe_reqs_0_valid", "io_exe_reqs_1_valid", "io_iss_uops_0_br_mask", "io_iss_uops_1_br_mask", "io_iss_valids_0", "io_iss_valids_1", "io_kill", "reset"]

timing: Drive at falling edges, update at rising edges and sample after propagation settles.

boundary: Initialize every native input, generate a 10 ns clock and sample reset on rising edges; drive inputs on falling edges and establish two known rising-edge histories before numerical state checks. Use legal two-state values for every full-width native port, maintain an independent two-stage input-history predictor and compare all registered and combinational outputs. Set io_kill alone, each lane's stored-mask mispredict alone and their combination; resolve a bit at the prior edge then mispredict it at the next edge. Reset overrides execution valid only.

## F5

feature_id: F5

requirement_ids: ["R-dv-028-005"]

module: RegisterRead

definition: At each rising edge, execution metadata takes the previous first-stage metadata when not cancelled. When cancelled every metadata field becomes zero except dst_rtype becomes numeric two and br_mask still equals the stored first-stage branch mask with current resolve bits cleared. This branch-mask update occurs even when cancelled, reset or invalid. Reset alone does not force metadata to the cancelled values. Poison fields remain zero once initialized. Operand data is independent of this metadata cancellation.

interface: ["clock", "io_brupdate_b1_mispredict_mask", "io_brupdate_b1_resolve_mask", "io_exe_reqs_0_bits_uop_br_mask", "io_exe_reqs_0_bits_uop_dst_rtype", "io_exe_reqs_0_bits_uop_iw_p1_poisoned", "io_exe_reqs_0_bits_uop_iw_p2_poisoned", "io_exe_reqs_1_bits_uop_br_mask", "io_exe_reqs_1_bits_uop_dst_rtype", "io_exe_reqs_1_bits_uop_iw_p1_poisoned", "io_exe_reqs_1_bits_uop_iw_p2_poisoned", "io_kill", "reset"]

timing: Drive at falling edges, update at rising edges and sample after propagation settles.

boundary: Initialize every native input, generate a 10 ns clock and sample reset on rising edges; drive inputs on falling edges and establish two known rising-edge histories before numerical state checks. Use legal two-state values for every full-width native port, maintain an independent two-stage input-history predictor and compare all registered and combinational outputs. Kill distinctive metadata with dst_rtype 0/1/2/3; verify cancelled dst_rtype two, all other zero defaults, branch-mask continuing resolution and operand data unaffected. Contrast reset without kill.

## F6

feature_id: F6

requirement_ids: ["R-dv-028-006"]

module: RegisterRead

definition: The exact numeric shared decode table in public/decode.md defines br_type, op1_sel, op2_sel, imm_sel, op_fcn and fcn_dw for all 128 uopc values. csr_cmd is always zero. is_load is one only for uopc 1; is_sta only for uopc 2 or 67; is_std for uopc 3, or for uopc 2/67 with lrs2_rtype zero. The decoded immediate is zero for uopc 67 and for uopc 1 with mem_cmd six, otherwise it copies issue imm_packed. Other metadata fields pass to the first stage without opcode-dependent change. No architectural instruction legality restriction narrows the seven-bit opcode domain.

interface: ["clock", "io_exe_reqs_0_bits_uop_ctrl_br_type", "io_exe_reqs_0_bits_uop_ctrl_csr_cmd", "io_exe_reqs_0_bits_uop_ctrl_fcn_dw", "io_exe_reqs_0_bits_uop_ctrl_imm_sel", "io_exe_reqs_0_bits_uop_ctrl_is_load", "io_exe_reqs_0_bits_uop_ctrl_is_sta", "io_exe_reqs_0_bits_uop_ctrl_is_std", "io_exe_reqs_0_bits_uop_ctrl_op1_sel", "io_exe_reqs_0_bits_uop_ctrl_op2_sel", "io_exe_reqs_0_bits_uop_ctrl_op_fcn", "io_exe_reqs_0_bits_uop_imm_packed", "io_exe_reqs_1_bits_uop_ctrl_br_type", "io_exe_reqs_1_bits_uop_ctrl_csr_cmd", "io_exe_reqs_1_bits_uop_ctrl_fcn_dw", "io_exe_reqs_1_bits_uop_ctrl_imm_sel", "io_exe_reqs_1_bits_uop_ctrl_is_load", "io_exe_reqs_1_bits_uop_ctrl_is_sta", "io_exe_reqs_1_bits_uop_ctrl_is_std", "io_exe_reqs_1_bits_uop_ctrl_op1_sel", "io_exe_reqs_1_bits_uop_ctrl_op2_sel", "io_exe_reqs_1_bits_uop_ctrl_op_fcn", "io_exe_reqs_1_bits_uop_imm_packed", "io_iss_uops_0_imm_packed", "io_iss_uops_0_lrs2_rtype", "io_iss_uops_0_mem_cmd", "io_iss_uops_0_uopc", "io_iss_uops_1_imm_packed", "io_iss_uops_1_lrs2_rtype", "io_iss_uops_1_mem_cmd", "io_iss_uops_1_uopc"]

timing: Drive at falling edges, update at rising edges and sample after propagation settles.

boundary: Initialize every native input, generate a 10 ns clock and sample reset on rising edges; drive inputs on falling edges and establish two known rising-edge histories before numerical state checks. Use legal two-state values for every full-width native port, maintain an independent two-stage input-history predictor and compare all registered and combinational outputs. Enumerate all 128 uopc values for both lanes and all lrs2_rtype values; cross mem_cmd six/non-six at load opcode and uopc 67. Verify every six-field decode-table entry and immediate exceptions after pipeline delay.

## F7

feature_id: F7

requirement_ids: ["R-dv-028-007"]

module: RegisterRead

definition: Both lanes use the shared table except uopc 101,102,103,104: lane 0 op_fcn is 15 and lane 1 op_fcn is zero. All other decoded fields for those opcodes follow the shared default. This is an observable lane asymmetry, not an unsupported-domain omission. Both lanes accept the complete uopc 0..127 domain and can issue independently and simultaneously.

interface: ["clock", "io_exe_reqs_0_bits_uop_ctrl_op_fcn", "io_exe_reqs_1_bits_uop_ctrl_op_fcn", "io_iss_uops_0_uopc", "io_iss_uops_1_uopc"]

timing: Drive at falling edges, update at rising edges and sample after propagation settles.

boundary: Initialize every native input, generate a 10 ns clock and sample reset on rising edges; drive inputs on falling edges and establish two known rising-edge histories before numerical state checks. Use legal two-state values for every full-width native port, maintain an independent two-stage input-history predictor and compare all registered and combinational outputs. Apply opcodes 100,101,102,103,104,105 and 86 concurrently on both lanes with kill disabled; compare numeric function differences at exactly 101..104 and identical decoding elsewhere.

## F8

feature_id: F8

requirement_ids: ["R-dv-028-008"]

module: RegisterRead

definition: Every native metadata field not changed by the specified decode, immediate, branch-mask, poison or cancellation rules is forwarded exactly through both stages, including every declared high bit. Execution output metadata therefore corresponds to issue inputs sampled one edge earlier, while operand data uses current RF input data and one-edge-old zero-source flags. Changes in issue valid do not freeze metadata. One lane's issue contents, source indices or cancellation mask cannot alter the other lane's metadata or operands; shared global kill and branch updates apply by their stated per-lane rules.

interface: ["clock", "io_exe_reqs_0_bits_uop_bp_debug_if", "io_exe_reqs_0_bits_uop_bp_xcpt_if", "io_exe_reqs_0_bits_uop_br_mask", "io_exe_reqs_0_bits_uop_br_tag", "io_exe_reqs_0_bits_uop_bypassable", "io_exe_reqs_0_bits_uop_csr_addr", "io_exe_reqs_0_bits_uop_ctrl_br_type", "io_exe_reqs_0_bits_uop_ctrl_csr_cmd", "io_exe_reqs_0_bits_uop_ctrl_fcn_dw", "io_exe_reqs_0_bits_uop_ctrl_imm_sel", "io_exe_reqs_0_bits_uop_ctrl_is_load", "io_exe_reqs_0_bits_uop_ctrl_is_sta", "io_exe_reqs_0_bits_uop_ctrl_is_std", "io_exe_reqs_0_bits_uop_ctrl_op1_sel", "io_exe_reqs_0_bits_uop_ctrl_op2_sel", "io_exe_reqs_0_bits_uop_ctrl_op_fcn", "io_exe_reqs_0_bits_uop_debug_fsrc", "io_exe_reqs_0_bits_uop_debug_inst", "io_exe_reqs_0_bits_uop_debug_pc", "io_exe_reqs_0_bits_uop_debug_tsrc", "io_exe_reqs_0_bits_uop_dst_rtype", "io_exe_reqs_0_bits_uop_edge_inst", "io_exe_reqs_0_bits_uop_exc_cause", "io_exe_reqs_0_bits_uop_exception", "io_exe_reqs_0_bits_uop_flush_on_commit", "io_exe_reqs_0_bits_uop_fp_single", "io_exe_reqs_0_bits_uop_fp_val", "io_exe_reqs_0_bits_uop_frs3_en", "io_exe_reqs_0_bits_uop_ftq_idx", "io_exe_reqs_0_bits_uop_fu_code", "io_exe_reqs_0_bits_uop_imm_packed", "io_exe_reqs_0_bits_uop_inst", "io_exe_reqs_0_bits_uop_iq_type", "io_exe_reqs_0_bits_uop_is_amo", "io_exe_reqs_0_bits_uop_is_br", "io_exe_reqs_0_bits_uop_is_fence", "io_exe_reqs_0_bits_uop_is_fencei", "io_exe_reqs_0_bits_uop_is_jal", "io_exe_reqs_0_bits_uop_is_jalr", "io_exe_reqs_0_bits_uop_is_rvc", "io_exe_reqs_0_bits_uop_is_sfb", "io_exe_reqs_0_bits_uop_is_sys_pc2epc", "io_exe_reqs_0_bits_uop_is_unique", "io_exe_reqs_0_bits_uop_iw_p1_poisoned", "io_exe_reqs_0_bits_uop_iw_p2_poisoned", "io_exe_reqs_0_bits_uop_iw_state", "io_exe_reqs_0_bits_uop_ldq_idx", "io_exe_reqs_0_bits_uop_ldst", "io_exe_reqs_0_bits_uop_ldst_is_rs1", "io_exe_reqs_0_bits_uop_ldst_val", "io_exe_reqs_0_bits_uop_lrs1", "io_exe_reqs_0_bits_uop_lrs1_rtype", "io_exe_reqs_0_bits_uop_lrs2", "io_exe_reqs_0_bits_uop_lrs2_rtype", "io_exe_reqs_0_bits_uop_lrs3", "io_exe_reqs_0_bits_uop_mem_cmd", "io_exe_reqs_0_bits_uop_mem_signed", "io_exe_reqs_0_bits_uop_mem_size", "io_exe_reqs_0_bits_uop_pc_lob", "io_exe_reqs_0_bits_uop_pdst", "io_exe_reqs_0_bits_uop_ppred", "io_exe_reqs_0_bits_uop_ppred_busy", "io_exe_reqs_0_bits_uop_prs1", "io_exe_reqs_0_bits_uop_prs1_busy", "io_exe_reqs_0_bits_uop_prs2", "io_exe_reqs_0_bits_uop_prs2_busy", "io_exe_reqs_0_bits_uop_prs3", "io_exe_reqs_0_bits_uop_prs3_busy", "io_exe_reqs_0_bits_uop_rob_idx", "io_exe_reqs_0_bits_uop_rxq_idx", "io_exe_reqs_0_bits_uop_stale_pdst", "io_exe_reqs_0_bits_uop_stq_idx", "io_exe_reqs_0_bits_uop_taken", "io_exe_reqs_0_bits_uop_uopc", "io_exe_reqs_0_bits_uop_uses_ldq", "io_exe_reqs_0_bits_uop_uses_stq", "io_exe_reqs_0_bits_uop_xcpt_ae_if", "io_exe_reqs_0_bits_uop_xcpt_ma_if", "io_exe_reqs_0_bits_uop_xcpt_pf_if", "io_exe_reqs_1_bits_uop_bp_debug_if", "io_exe_reqs_1_bits_uop_bp_xcpt_if", "io_exe_reqs_1_bits_uop_br_mask", "io_exe_reqs_1_bits_uop_br_tag", "io_exe_reqs_1_bits_uop_bypassable", "io_exe_reqs_1_bits_uop_csr_addr", "io_exe_reqs_1_bits_uop_ctrl_br_type", "io_exe_reqs_1_bits_uop_ctrl_csr_cmd", "io_exe_reqs_1_bits_uop_ctrl_fcn_dw", "io_exe_reqs_1_bits_uop_ctrl_imm_sel", "io_exe_reqs_1_bits_uop_ctrl_is_load", "io_exe_reqs_1_bits_uop_ctrl_is_sta", "io_exe_reqs_1_bits_uop_ctrl_is_std", "io_exe_reqs_1_bits_uop_ctrl_op1_sel", "io_exe_reqs_1_bits_uop_ctrl_op2_sel", "io_exe_reqs_1_bits_uop_ctrl_op_fcn", "io_exe_reqs_1_bits_uop_debug_fsrc", "io_exe_reqs_1_bits_uop_debug_inst", "io_exe_reqs_1_bits_uop_debug_pc", "io_exe_reqs_1_bits_uop_debug_tsrc", "io_exe_reqs_1_bits_uop_dst_rtype", "io_exe_reqs_1_bits_uop_edge_inst", "io_exe_reqs_1_bits_uop_exc_cause", "io_exe_reqs_1_bits_uop_exception", "io_exe_reqs_1_bits_uop_flush_on_commit", "io_exe_reqs_1_bits_uop_fp_single", "io_exe_reqs_1_bits_uop_fp_val", "io_exe_reqs_1_bits_uop_frs3_en", "io_exe_reqs_1_bits_uop_ftq_idx", "io_exe_reqs_1_bits_uop_fu_code", "io_exe_reqs_1_bits_uop_imm_packed", "io_exe_reqs_1_bits_uop_inst", "io_exe_reqs_1_bits_uop_iq_type", "io_exe_reqs_1_bits_uop_is_amo", "io_exe_reqs_1_bits_uop_is_br", "io_exe_reqs_1_bits_uop_is_fence", "io_exe_reqs_1_bits_uop_is_fencei", "io_exe_reqs_1_bits_uop_is_jal", "io_exe_reqs_1_bits_uop_is_jalr", "io_exe_reqs_1_bits_uop_is_rvc", "io_exe_reqs_1_bits_uop_is_sfb", "io_exe_reqs_1_bits_uop_is_sys_pc2epc", "io_exe_reqs_1_bits_uop_is_unique", "io_exe_reqs_1_bits_uop_iw_p1_poisoned", "io_exe_reqs_1_bits_uop_iw_p2_poisoned", "io_exe_reqs_1_bits_uop_iw_state", "io_exe_reqs_1_bits_uop_ldq_idx", "io_exe_reqs_1_bits_uop_ldst", "io_exe_reqs_1_bits_uop_ldst_is_rs1", "io_exe_reqs_1_bits_uop_ldst_val", "io_exe_reqs_1_bits_uop_lrs1", "io_exe_reqs_1_bits_uop_lrs1_rtype", "io_exe_reqs_1_bits_uop_lrs2", "io_exe_reqs_1_bits_uop_lrs2_rtype", "io_exe_reqs_1_bits_uop_lrs3", "io_exe_reqs_1_bits_uop_mem_cmd", "io_exe_reqs_1_bits_uop_mem_signed", "io_exe_reqs_1_bits_uop_mem_size", "io_exe_reqs_1_bits_uop_pc_lob", "io_exe_reqs_1_bits_uop_pdst", "io_exe_reqs_1_bits_uop_ppred", "io_exe_reqs_1_bits_uop_ppred_busy", "io_exe_reqs_1_bits_uop_prs1", "io_exe_reqs_1_bits_uop_prs1_busy", "io_exe_reqs_1_bits_uop_prs2", "io_exe_reqs_1_bits_uop_prs2_busy", "io_exe_reqs_1_bits_uop_prs3", "io_exe_reqs_1_bits_uop_prs3_busy", "io_exe_reqs_1_bits_uop_rob_idx", "io_exe_reqs_1_bits_uop_rxq_idx", "io_exe_reqs_1_bits_uop_stale_pdst", "io_exe_reqs_1_bits_uop_stq_idx", "io_exe_reqs_1_bits_uop_taken", "io_exe_reqs_1_bits_uop_uopc", "io_exe_reqs_1_bits_uop_uses_ldq", "io_exe_reqs_1_bits_uop_uses_stq", "io_exe_reqs_1_bits_uop_xcpt_ae_if", "io_exe_reqs_1_bits_uop_xcpt_ma_if", "io_exe_reqs_1_bits_uop_xcpt_pf_if", "io_iss_uops_0_bp_debug_if", "io_iss_uops_0_bp_xcpt_if", "io_iss_uops_0_br_mask", "io_iss_uops_0_br_tag", "io_iss_uops_0_bypassable", "io_iss_uops_0_csr_addr", "io_iss_uops_0_debug_fsrc", "io_iss_uops_0_debug_inst", "io_iss_uops_0_debug_pc", "io_iss_uops_0_debug_tsrc", "io_iss_uops_0_dst_rtype", "io_iss_uops_0_edge_inst", "io_iss_uops_0_exc_cause", "io_iss_uops_0_exception", "io_iss_uops_0_flush_on_commit", "io_iss_uops_0_fp_single", "io_iss_uops_0_fp_val", "io_iss_uops_0_frs3_en", "io_iss_uops_0_ftq_idx", "io_iss_uops_0_fu_code", "io_iss_uops_0_imm_packed", "io_iss_uops_0_inst", "io_iss_uops_0_iq_type", "io_iss_uops_0_is_amo", "io_iss_uops_0_is_br", "io_iss_uops_0_is_fence", "io_iss_uops_0_is_fencei", "io_iss_uops_0_is_jal", "io_iss_uops_0_is_jalr", "io_iss_uops_0_is_rvc", "io_iss_uops_0_is_sfb", "io_iss_uops_0_is_sys_pc2epc", "io_iss_uops_0_is_unique", "io_iss_uops_0_iw_state", "io_iss_uops_0_ldq_idx", "io_iss_uops_0_ldst", "io_iss_uops_0_ldst_is_rs1", "io_iss_uops_0_ldst_val", "io_iss_uops_0_lrs1", "io_iss_uops_0_lrs1_rtype", "io_iss_uops_0_lrs2", "io_iss_uops_0_lrs2_rtype", "io_iss_uops_0_lrs3", "io_iss_uops_0_mem_cmd", "io_iss_uops_0_mem_signed", "io_iss_uops_0_mem_size", "io_iss_uops_0_pc_lob", "io_iss_uops_0_pdst", "io_iss_uops_0_ppred", "io_iss_uops_0_ppred_busy", "io_iss_uops_0_prs1", "io_iss_uops_0_prs1_busy", "io_iss_uops_0_prs2", "io_iss_uops_0_prs2_busy", "io_iss_uops_0_prs3", "io_iss_uops_0_prs3_busy", "io_iss_uops_0_rob_idx", "io_iss_uops_0_rxq_idx", "io_iss_uops_0_stale_pdst", "io_iss_uops_0_stq_idx", "io_iss_uops_0_taken", "io_iss_uops_0_uopc", "io_iss_uops_0_uses_ldq", "io_iss_uops_0_uses_stq", "io_iss_uops_0_xcpt_ae_if", "io_iss_uops_0_xcpt_ma_if", "io_iss_uops_0_xcpt_pf_if", "io_iss_uops_1_bp_debug_if", "io_iss_uops_1_bp_xcpt_if", "io_iss_uops_1_br_mask", "io_iss_uops_1_br_tag", "io_iss_uops_1_bypassable", "io_iss_uops_1_csr_addr", "io_iss_uops_1_debug_fsrc", "io_iss_uops_1_debug_inst", "io_iss_uops_1_debug_pc", "io_iss_uops_1_debug_tsrc", "io_iss_uops_1_dst_rtype", "io_iss_uops_1_edge_inst", "io_iss_uops_1_exc_cause", "io_iss_uops_1_exception", "io_iss_uops_1_flush_on_commit", "io_iss_uops_1_fp_single", "io_iss_uops_1_fp_val", "io_iss_uops_1_frs3_en", "io_iss_uops_1_ftq_idx", "io_iss_uops_1_fu_code", "io_iss_uops_1_imm_packed", "io_iss_uops_1_inst", "io_iss_uops_1_iq_type", "io_iss_uops_1_is_amo", "io_iss_uops_1_is_br", "io_iss_uops_1_is_fence", "io_iss_uops_1_is_fencei", "io_iss_uops_1_is_jal", "io_iss_uops_1_is_jalr", "io_iss_uops_1_is_rvc", "io_iss_uops_1_is_sfb", "io_iss_uops_1_is_sys_pc2epc", "io_iss_uops_1_is_unique", "io_iss_uops_1_iw_state", "io_iss_uops_1_ldq_idx", "io_iss_uops_1_ldst", "io_iss_uops_1_ldst_is_rs1", "io_iss_uops_1_ldst_val", "io_iss_uops_1_lrs1", "io_iss_uops_1_lrs1_rtype", "io_iss_uops_1_lrs2", "io_iss_uops_1_lrs2_rtype", "io_iss_uops_1_lrs3", "io_iss_uops_1_mem_cmd", "io_iss_uops_1_mem_signed", "io_iss_uops_1_mem_size", "io_iss_uops_1_pc_lob", "io_iss_uops_1_pdst", "io_iss_uops_1_ppred", "io_iss_uops_1_ppred_busy", "io_iss_uops_1_prs1", "io_iss_uops_1_prs1_busy", "io_iss_uops_1_prs2", "io_iss_uops_1_prs2_busy", "io_iss_uops_1_prs3", "io_iss_uops_1_prs3_busy", "io_iss_uops_1_rob_idx", "io_iss_uops_1_rxq_idx", "io_iss_uops_1_stale_pdst", "io_iss_uops_1_stq_idx", "io_iss_uops_1_taken", "io_iss_uops_1_uopc", "io_iss_uops_1_uses_ldq", "io_iss_uops_1_uses_stq", "io_iss_uops_1_xcpt_ae_if", "io_iss_uops_1_xcpt_ma_if", "io_iss_uops_1_xcpt_pf_if", "io_iss_valids_0", "io_iss_valids_1"]

timing: Drive at falling edges, update at rising edges and sample after propagation settles.

boundary: Initialize every native input, generate a 10 ns clock and sample reset on rising edges; drive inputs on falling edges and establish two known rising-edge histories before numerical state checks. Use legal two-state values for every full-width native port, maintain an independent two-stage input-history predictor and compare all registered and combinational outputs. Randomize all metadata fields over their full declared widths with nonzero high bits and independent lane patterns, vary valid low/high, global kill and per-lane masks, and verify complete output-bit preservation and both timing histories.
