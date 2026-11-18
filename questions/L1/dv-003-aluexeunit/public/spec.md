# ALUExeUnit behavioral specification

The task covers the full native execution wrapper and both response channels. Names in the interface contract are authoritative; unqualified field names below refer to their native request inputs.

### R-dv-003-001 — Interface, timing and legal input domain

The complete native ALUExeUnit interface has no parameters or functional storage. Outputs react combinationally to current inputs; compare after propagation has settled. clock only checks legality on its rising edge. reset disables those legality checks but does not reset, clear or gate functional outputs. All described outputs remain defined for legal two-state inputs, including when corresponding valid is low. Numerical results with X/Z inputs are unspecified. Let G mean io_req_valid and bit 2 of io_req_bits_uop_fu_code. When reset is low at a rising edge, G and ctrl_is_std require rs2_data[64]=0 and fp_val=0; G and fp_val require uopc=1 or 2.

### R-dv-003-002 — Request routing and branch update

io_lsu_io_req_valid equals G unless any bit is shared by the incoming uop br_mask and io_brupdate_b1_mispredict_mask, in which case it is zero. Every io_lsu_io_req_bits_uop_ field copies the correspondingly suffixed io_req_bits_uop_ field, except br_mask, whose resolved bits are cleared using io_brupdate_b1_resolve_mask. Branch resolution does not first remove bits when testing misprediction. Request payload forwarding is independent of validity, reset and exceptions.

### R-dv-003-003 — Effective address arithmetic and compressed address

Form a 64-bit modular sum S of rs1_data[63:0] and the sign-extended 12-bit immediate imm_packed[19:8]. Ignore rs1_data[64] and imm_packed[7:0]. Address output bits 38:0 equal S[38:0]. Address output bit39 equals 1 precisely when either S[38]=1 and S[63:39] consists entirely of ones, or S[38]=0 and S[63:39] is nonzero. This is unconditional and includes carries, negative immediates and 64-bit wraparound.

### R-dv-003-004 — Store data forwarding

io_lsu_io_req_bits_data equals rs2_data[63:0], discarding bit64. Forward all 64 low bits regardless of opcode, valid, reset, branch outcome or alignment.

### R-dv-003-005 — Misalignment exception

Alignment is based on S: mem_size 0,1,2,3 respectively require divisibility by 1,2,4,8. io_lsu_io_req_bits_mxcpt_valid equals G and misalignment and membership of uopc in {1,2,0x43}. Other opcodes never cause this exception. A branch misprediction may suppress request valid while this exception remains asserted; neither exception nor misalignment suppresses request valid.

### R-dv-003-006 — SFENCE sideband

io_lsu_io_req_bits_sfence_valid equals G and mem_cmd=0x14. It has no opcode, branch, reset or alignment gate. sfence_bits_rs1 equals mem_size[0]; sfence_bits_rs2 equals mem_size[1]. sfence_bits_addr equals incoming rs1_data[38:0], without adding the immediate. All sideband payload bits are unconditional.

### R-dv-003-007 — Integer response forwarding

Every io_ll_iresp_ field directly copies its correspondingly suffixed io_lsu_io_iresp_ input. The 64-bit integer response data is zero-extended to the 65-bit output. Valid, metadata and data are independent of request activity, branch update and reset, and payload is forwarded when response valid is zero.

### R-dv-003-008 — Floating response forwarding

Every io_ll_fresp_ field directly copies its correspondingly suffixed io_lsu_io_fresp_ input, preserving all 65 data bits and all metadata including br_mask. No branch-mask update, validity gating, reset gating or integer response selection applies. Both response channels may be active simultaneously.
