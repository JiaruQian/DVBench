# Reference features

## F1

**feature_id**: F1

**requirement_ids**: ["R-dv-003-001"]

**module**: ALUExeUnit

**definition**: The complete native ALUExeUnit interface has no parameters or functional storage. Outputs react combinationally to current inputs; compare after propagation has settled. clock only checks legality on its rising edge. reset disables those legality checks but does not reset, clear or gate functional outputs. All described outputs remain defined for legal two-state inputs, including when corresponding valid is low. Numerical results with X/Z inputs are unspecified. Let G mean io_req_valid and bit 2 of io_req_bits_uop_fu_code. When reset is low at a rising edge, G and ctrl_is_std require rs2_data[64]=0 and fp_val=0; G and fp_val require uopc=1 or 2.

**interface**: ["clock", "reset", "io_req_valid", "io_req_bits_uop_fu_code"]

**timing**: Combinational, settle before sampling; legality checked at clock rising edge.

**boundary**: Toggle reset and all native inputs, exercise active and inactive G, and preserve asserted legal constraints at each rising edge.

## F2

**feature_id**: F2

**requirement_ids**: ["R-dv-003-002"]

**module**: ALUExeUnit

**definition**: io_lsu_io_req_valid equals G unless any bit is shared by the incoming uop br_mask and io_brupdate_b1_mispredict_mask, in which case it is zero. Every io_lsu_io_req_bits_uop_ field copies the correspondingly suffixed io_req_bits_uop_ field, except br_mask, whose resolved bits are cleared using io_brupdate_b1_resolve_mask. Branch resolution does not first remove bits when testing misprediction. Request payload forwarding is independent of validity, reset and exceptions.

**interface**: ["io_req_valid", "io_req_bits_uop_br_mask", "io_brupdate_b1_resolve_mask", "io_brupdate_b1_mispredict_mask", "io_lsu_io_req_valid"]

**timing**: Combinational, settle before sampling; legality checked at clock rising edge.

**boundary**: Randomize every native uop field; sweep valid/FU bit2 and branch masks including overlapping resolve/mispredict bits, empty masks, and highest bit.

## F3

**feature_id**: F3

**requirement_ids**: ["R-dv-003-003"]

**module**: ALUExeUnit

**definition**: Form a 64-bit modular sum S of rs1_data[63:0] and the sign-extended 12-bit immediate imm_packed[19:8]. Ignore rs1_data[64] and imm_packed[7:0]. Address output bits 38:0 equal S[38:0]. Address output bit39 equals 1 precisely when either S[38]=1 and S[63:39] consists entirely of ones, or S[38]=0 and S[63:39] is nonzero. This is unconditional and includes carries, negative immediates and 64-bit wraparound.

**interface**: ["io_req_bits_rs1_data", "io_req_bits_uop_imm_packed", "io_lsu_io_req_bits_addr"]

**timing**: Combinational, settle before sampling; legality checked at clock rising edge.

**boundary**: Exercise positive/negative 12-bit immediates, ignored bits, 64-bit carry/wrap, S[38] transitions and upper bits all-zero, all-one and mixed.

## F4

**feature_id**: F4

**requirement_ids**: ["R-dv-003-004"]

**module**: ALUExeUnit

**definition**: io_lsu_io_req_bits_data equals rs2_data[63:0], discarding bit64. Forward all 64 low bits regardless of opcode, valid, reset, branch outcome or alignment.

**interface**: ["io_req_bits_rs2_data", "io_lsu_io_req_bits_data"]

**timing**: Combinational, settle before sampling; legality checked at clock rising edge.

**boundary**: Toggle each of the 65 rs2 data bits with valid on/off, reset high/low and branch hits; independently vary all other fields.

## F5

**feature_id**: F5

**requirement_ids**: ["R-dv-003-005"]

**module**: ALUExeUnit

**definition**: Alignment is based on S: mem_size 0,1,2,3 respectively require divisibility by 1,2,4,8. io_lsu_io_req_bits_mxcpt_valid equals G and misalignment and membership of uopc in {1,2,0x43}. Other opcodes never cause this exception. A branch misprediction may suppress request valid while this exception remains asserted; neither exception nor misalignment suppresses request valid.

**interface**: ["io_req_bits_uop_uopc", "io_req_bits_uop_mem_size", "io_lsu_io_req_bits_mxcpt_valid", "io_lsu_io_req_bits_addr"]

**timing**: Combinational, settle before sampling; legality checked at clock rising edge.

**boundary**: Cross mem_size 0..3 and low address offsets 0..7 with opcodes 1,2,0x43 and neighbors 3/0x42; include G off, branch hit and immediate-induced misalignment.

## F6

**feature_id**: F6

**requirement_ids**: ["R-dv-003-006"]

**module**: ALUExeUnit

**definition**: io_lsu_io_req_bits_sfence_valid equals G and mem_cmd=0x14. It has no opcode, branch, reset or alignment gate. sfence_bits_rs1 equals mem_size[0]; sfence_bits_rs2 equals mem_size[1]. sfence_bits_addr equals incoming rs1_data[38:0], without adding the immediate. All sideband payload bits are unconditional.

**interface**: ["io_req_bits_uop_mem_cmd", "io_req_bits_uop_mem_size", "io_req_bits_rs1_data", "io_lsu_io_req_bits_sfence_valid"]

**timing**: Combinational, settle before sampling; legality checked at clock rising edge.

**boundary**: Cross commands 0x14/0x15, sizes 0..3, G on/off and branch hit; vary rs1 bit38 and immediate independently.

## F7

**feature_id**: F7

**requirement_ids**: ["R-dv-003-007"]

**module**: ALUExeUnit

**definition**: Every io_ll_iresp_ field directly copies its correspondingly suffixed io_lsu_io_iresp_ input. The 64-bit integer response data is zero-extended to the 65-bit output. Valid, metadata and data are independent of request activity, branch update and reset, and payload is forwarded when response valid is zero.

**interface**: ["io_ll_iresp_valid", "io_ll_iresp_bits_uop_rob_idx", "io_ll_iresp_bits_uop_pdst", "io_ll_iresp_bits_uop_is_amo", "io_ll_iresp_bits_uop_uses_stq", "io_ll_iresp_bits_uop_dst_rtype", "io_ll_iresp_bits_data", "io_lsu_io_iresp_valid", "io_lsu_io_iresp_bits_uop_rob_idx", "io_lsu_io_iresp_bits_uop_pdst", "io_lsu_io_iresp_bits_uop_is_amo", "io_lsu_io_iresp_bits_uop_uses_stq", "io_lsu_io_iresp_bits_uop_dst_rtype", "io_lsu_io_iresp_bits_data"]

**timing**: Combinational, settle before sampling; legality checked at clock rising edge.

**boundary**: Randomize every integer response field independently at both valid values; exercise data bit63 and simultaneous floating response.

## F8

**feature_id**: F8

**requirement_ids**: ["R-dv-003-008"]

**module**: ALUExeUnit

**definition**: Every io_ll_fresp_ field directly copies its correspondingly suffixed io_lsu_io_fresp_ input, preserving all 65 data bits and all metadata including br_mask. No branch-mask update, validity gating, reset gating or integer response selection applies. Both response channels may be active simultaneously.

**interface**: ["io_ll_fresp_valid", "io_ll_fresp_bits_uop_uopc", "io_ll_fresp_bits_uop_br_mask", "io_ll_fresp_bits_uop_rob_idx", "io_ll_fresp_bits_uop_stq_idx", "io_ll_fresp_bits_uop_pdst", "io_ll_fresp_bits_uop_mem_size", "io_ll_fresp_bits_uop_is_amo", "io_ll_fresp_bits_uop_uses_stq", "io_ll_fresp_bits_uop_dst_rtype", "io_ll_fresp_bits_uop_fp_val", "io_ll_fresp_bits_data", "io_lsu_io_fresp_valid", "io_lsu_io_fresp_bits_uop_uopc", "io_lsu_io_fresp_bits_uop_br_mask", "io_lsu_io_fresp_bits_uop_rob_idx", "io_lsu_io_fresp_bits_uop_stq_idx", "io_lsu_io_fresp_bits_uop_pdst", "io_lsu_io_fresp_bits_uop_mem_size", "io_lsu_io_fresp_bits_uop_is_amo", "io_lsu_io_fresp_bits_uop_uses_stq", "io_lsu_io_fresp_bits_uop_dst_rtype", "io_lsu_io_fresp_bits_uop_fp_val", "io_lsu_io_fresp_bits_data"]

**timing**: Combinational, settle before sampling; legality checked at clock rising edge.

**boundary**: Randomize every floating response field independently at both valid values, including data bit64 and br_mask; exercise simultaneous integer response and branch update.
