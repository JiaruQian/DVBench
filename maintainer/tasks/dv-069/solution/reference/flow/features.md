# Reference features

{
  "feature_id": "F1",
  "module": "vmul_top",
  "requirement_ids": [
    "R-p8-vmul-001"
  ],
  "definition": "Use fixed top parameters SOFT_THREAD=4,HARD_THREAD=4,MAX_ITER=1 and the supplied fixed32-bit arithmetic configuration. Other parameter values are outside this task. Lane j uses packed bits32*j+:32, with lane0 lowest. Let A be in2 and B be in1 when current reverse1, otherwise A=in1,B=in2. Let C=in3. For current6-bit function26 or27, multiplier left=C,right=B,addend=A; for every other function left=A,right=B,addend=C. This selection is applied independently to all4 lanes. Mask never gates arithmetic or lane evaluation; all4 result words are computed. Scalar results use lane0 only. Every known binary6-bit function and both write flags, including00/11, are admitted; no instruction-name assumption imposes a narrower domain.",
  "interface": [
    "clk",
    "ctrl_alu_fn_i",
    "ctrl_reg_idxw_i",
    "ctrl_reverse_i",
    "ctrl_wid_i",
    "ctrl_wvd_i",
    "ctrl_wxd_i",
    "in1_i",
    "in2_i",
    "in3_i",
    "in_ready_o",
    "in_valid_i",
    "mask_i",
    "outv_ready_i",
    "outv_reg_idxw_o",
    "outv_valid_o",
    "outv_warp_id_o",
    "outv_wb_wxd_rd_o",
    "outv_wvd_mask_o",
    "outv_wvd_o",
    "outx_ready_i",
    "outx_reg_idwx_o",
    "outx_valid_o",
    "outx_warp_id_o",
    "outx_wb_wxd_rd_o",
    "outx_wxd_o",
    "rst_n"
  ],
  "timing": "Asynchronous reset on rst_n falling edge; all other state samples pre-edge values at clk rising edges. Compare settled native outputs before/after edges.",
  "boundary": "Fixed4 lanes and all binary6-bit functions,reverse,flags,valid/ready histories; arithmetic modulo stated widths."
}

{
  "feature_id": "F2",
  "module": "vmul_top",
  "requirement_ids": [
    "R-p8-vmul-002"
  ],
  "definition": "There is an unconditional one-clock magnitude register per lane. At every rising edge with reset inactive, form unsigned32-bit magnitudes of the CURRENT selected multiplier operands: left is interpreted signed only for current function21 or23, right only for current function21. For a negative signed operand its magnitude is its32-bit two-complement negation; otherwise it is unchanged. Register the unsigned64-bit magnitude product every clock, even when input valid0, not accepted, or the elastic pipeline stalls. Reset clears this register0. The combinational corrected product P uses that registered magnitude with the CURRENT live operand-sign parity, not saved sign bits: negate it modulo2^64 when current signed-left-negative XOR signed-right-negative is1. Stage1 saves function/addend on accepted input. When stage1 advances into stage2, use its saved function f and saved32-bit addend c, but P from the currently visible magnitude/sign history: if f[4:2]=binary110 (both24..27 and56..59), result is low32(P+c) for exact f24/26, otherwise low32(c-P). For exact f21/22/23 return P[63:32]. All other f return P[31:0]. Arithmetic wraps at its stated width. The free-running magnitude and live sign correction remain observable under changing invalid/stalled inputs; do not replace this behavior with an ideal transaction-only multiplier.",
  "interface": [
    "clk",
    "ctrl_alu_fn_i",
    "ctrl_reg_idxw_i",
    "ctrl_reverse_i",
    "ctrl_wid_i",
    "ctrl_wvd_i",
    "ctrl_wxd_i",
    "in1_i",
    "in2_i",
    "in3_i",
    "in_ready_o",
    "in_valid_i",
    "mask_i",
    "outv_ready_i",
    "outv_reg_idxw_o",
    "outv_valid_o",
    "outv_warp_id_o",
    "outv_wb_wxd_rd_o",
    "outv_wvd_mask_o",
    "outv_wvd_o",
    "outx_ready_i",
    "outx_reg_idwx_o",
    "outx_valid_o",
    "outx_warp_id_o",
    "outx_wb_wxd_rd_o",
    "outx_wxd_o",
    "rst_n"
  ],
  "timing": "Asynchronous reset on rst_n falling edge; all other state samples pre-edge values at clk rising edges. Compare settled native outputs before/after edges.",
  "boundary": "Fixed4 lanes and all binary6-bit functions,reverse,flags,valid/ready histories; arithmetic modulo stated widths."
}

{
  "feature_id": "F3",
  "module": "vmul_top",
  "requirement_ids": [
    "R-p8-vmul-003"
  ],
  "definition": "Maintain stage1 valid v1 and stage2 valid v2, reset0. Let Xready=!scalar_FIFO_full OR outx_ready; Vready=!vector_FIFO_full OR outv_ready. Sink readiness R is Xready when saved stage2 scalar-write flag1, otherwise Vready, regardless of stage2 valid or vector flag. Native in_ready is NOT(v1 AND v2 AND NOT R), with no reset gating. Each rising edge outside reset: if in_ready, v1 becomes current in_valid; otherwise hold v1. If NOT v2 OR R, v2 becomes old v1; otherwise hold v2. Accept/save input payload exactly when in_valid AND in_ready. Advance/save stage2 result and metadata exactly when old v1 AND (NOT old v2 OR R). Each saved payload holds when its own enable is false, even when its valid clears. With both FIFOs available, an input accepted at E reaches stage2 after E+1 and its result FIFO after E+2; there is no combinational FIFO fall-through.",
  "interface": [
    "clk",
    "ctrl_alu_fn_i",
    "ctrl_reg_idxw_i",
    "ctrl_reverse_i",
    "ctrl_wid_i",
    "ctrl_wvd_i",
    "ctrl_wxd_i",
    "in1_i",
    "in2_i",
    "in3_i",
    "in_ready_o",
    "in_valid_i",
    "mask_i",
    "outv_ready_i",
    "outv_reg_idxw_o",
    "outv_valid_o",
    "outv_warp_id_o",
    "outv_wb_wxd_rd_o",
    "outv_wvd_mask_o",
    "outv_wvd_o",
    "outx_ready_i",
    "outx_reg_idwx_o",
    "outx_valid_o",
    "outx_warp_id_o",
    "outx_wb_wxd_rd_o",
    "outx_wxd_o",
    "rst_n"
  ],
  "timing": "Asynchronous reset on rst_n falling edge; all other state samples pre-edge values at clk rising edges. Compare settled native outputs before/after edges.",
  "boundary": "Fixed4 lanes and all binary6-bit functions,reverse,flags,valid/ready histories; arithmetic modulo stated widths."
}

{
  "feature_id": "F4",
  "module": "vmul_top",
  "requirement_ids": [
    "R-p8-vmul-004"
  ],
  "definition": "On accepted input save function,selected per-lane addend,4-bit mask,3-bit warp,8-bit destination,vector-write and scalar-write flags into stage1. On stage2 advance transfer that metadata and the4 newly computed result words together. Neither mask0 nor an individual masked-off lane changes the arithmetic; vector output always carries all128 result bits with the saved mask separately. Scalar FIFO payload is saved warp,destination,scalar-write and lane0 result. Vector FIFO payload is saved warp,destination,vector-write,all4 mask bits and all4 results in native lane order. Current inputs do not replace held stage metadata when blocked.",
  "interface": [
    "clk",
    "ctrl_alu_fn_i",
    "ctrl_reg_idxw_i",
    "ctrl_reverse_i",
    "ctrl_wid_i",
    "ctrl_wvd_i",
    "ctrl_wxd_i",
    "in1_i",
    "in2_i",
    "in3_i",
    "in_ready_o",
    "in_valid_i",
    "mask_i",
    "outv_ready_i",
    "outv_reg_idxw_o",
    "outv_valid_o",
    "outv_warp_id_o",
    "outv_wb_wxd_rd_o",
    "outv_wvd_mask_o",
    "outv_wvd_o",
    "outx_ready_i",
    "outx_reg_idwx_o",
    "outx_valid_o",
    "outx_warp_id_o",
    "outx_wb_wxd_rd_o",
    "outx_wxd_o",
    "rst_n"
  ],
  "timing": "Asynchronous reset on rst_n falling edge; all other state samples pre-edge values at clk rising edges. Compare settled native outputs before/after edges.",
  "boundary": "Fixed4 lanes and all binary6-bit functions,reverse,flags,valid/ready histories; arithmetic modulo stated widths."
}

{
  "feature_id": "F5",
  "module": "vmul_top",
  "requirement_ids": [
    "R-p8-vmul-005"
  ],
  "definition": "There are separate depth1 scalar and vector FIFOs, each with registered full/valid and stored payload, reset0. For each FIFO define capacity=!full OR its external ready. Its pop is full AND ready; scalar push is old stage2 valid AND stage2 scalar-write AND scalar capacity, vector push is old stage2 valid AND stage2 vector-write AND vector capacity. On an outside-reset edge a push replaces its stored payload; otherwise storage holds, including after a pop or while invalid. Full next is (old full AND NOT pop) OR push. A full FIFO permits simultaneous pop/push replacement. An empty FIFO receiving a push becomes valid only after the edge even if ready1. Native output valid equals that FIFO full and all payload outputs equal its stored fields continuously, including valid0. Reset clears payload0 as well as full. External scalar/vector readies are independent.",
  "interface": [
    "clk",
    "ctrl_alu_fn_i",
    "ctrl_reg_idxw_i",
    "ctrl_reverse_i",
    "ctrl_wid_i",
    "ctrl_wvd_i",
    "ctrl_wxd_i",
    "in1_i",
    "in2_i",
    "in3_i",
    "in_ready_o",
    "in_valid_i",
    "mask_i",
    "outv_ready_i",
    "outv_reg_idxw_o",
    "outv_valid_o",
    "outv_warp_id_o",
    "outv_wb_wxd_rd_o",
    "outv_wvd_mask_o",
    "outv_wvd_o",
    "outx_ready_i",
    "outx_reg_idwx_o",
    "outx_valid_o",
    "outx_warp_id_o",
    "outx_wb_wxd_rd_o",
    "outx_wxd_o",
    "rst_n"
  ],
  "timing": "Asynchronous reset on rst_n falling edge; all other state samples pre-edge values at clk rising edges. Compare settled native outputs before/after edges.",
  "boundary": "Fixed4 lanes and all binary6-bit functions,reverse,flags,valid/ready histories; arithmetic modulo stated widths."
}

{
  "feature_id": "F6",
  "module": "vmul_top",
  "requirement_ids": [
    "R-p8-vmul-006"
  ],
  "definition": "The two FIFO push predicates are independent while pipeline readiness R selects scalar whenever stage2 scalar-write1 and vector otherwise. These exact rules also define flags00 and11. Flags00 enqueue neither FIFO but still occupy/advance the elastic stages using vector readiness. With flags11, scalar capacity controls stage advancement while both FIFOs independently attempt enqueue; a stalled full vector FIFO can miss a scalar-advancing result, and an available vector FIFO can repeatedly enqueue the held stage2 result while scalar capacity blocks advancement. Conversely a stage2 vector-only result uses vector capacity and does not enqueue scalar. Do not impose exclusivity or invent atomic acceptance between the FIFOs. Preserve their exact independent state and payload histories.",
  "interface": [
    "clk",
    "ctrl_alu_fn_i",
    "ctrl_reg_idxw_i",
    "ctrl_reverse_i",
    "ctrl_wid_i",
    "ctrl_wvd_i",
    "ctrl_wxd_i",
    "in1_i",
    "in2_i",
    "in3_i",
    "in_ready_o",
    "in_valid_i",
    "mask_i",
    "outv_ready_i",
    "outv_reg_idxw_o",
    "outv_valid_o",
    "outv_warp_id_o",
    "outv_wb_wxd_rd_o",
    "outv_wvd_mask_o",
    "outv_wvd_o",
    "outx_ready_i",
    "outx_reg_idwx_o",
    "outx_valid_o",
    "outx_warp_id_o",
    "outx_wb_wxd_rd_o",
    "outx_wxd_o",
    "rst_n"
  ],
  "timing": "Asynchronous reset on rst_n falling edge; all other state samples pre-edge values at clk rising edges. Compare settled native outputs before/after edges.",
  "boundary": "Fixed4 lanes and all binary6-bit functions,reverse,flags,valid/ready histories; arithmetic modulo stated widths."
}

{
  "feature_id": "F7",
  "module": "vmul_top",
  "requirement_ids": [
    "R-p8-vmul-007"
  ],
  "definition": "rst_n is asynchronous active low. Its falling edge immediately clears both valid stages,all saved metadata/addends/functions,all4 magnitude registers,stage2 results and both FIFO payload/full states to0, without waiting for a clock. Holding reset low keeps state cleared at every rising edge. A short low pulse wholly between rising edges still flushes everything; pending results are abandoned. Output payload/valid clear through their reset state; in_ready remains its combinational expression and becomes1 after reset state settles. On deassertion no transaction is accepted until a subsequent rising edge. All binary input combinations and changes during invalid or blocked cycles are legal; only accepted-input metadata and stated magnitude/sign histories determine outputs. There are no internal assertions requiring an external protocol restriction, and no alternate folded datapath is selected in this fixed build.",
  "interface": [
    "clk",
    "ctrl_alu_fn_i",
    "ctrl_reg_idxw_i",
    "ctrl_reverse_i",
    "ctrl_wid_i",
    "ctrl_wvd_i",
    "ctrl_wxd_i",
    "in1_i",
    "in2_i",
    "in3_i",
    "in_ready_o",
    "in_valid_i",
    "mask_i",
    "outv_ready_i",
    "outv_reg_idxw_o",
    "outv_valid_o",
    "outv_warp_id_o",
    "outv_wb_wxd_rd_o",
    "outv_wvd_mask_o",
    "outv_wvd_o",
    "outx_ready_i",
    "outx_reg_idwx_o",
    "outx_valid_o",
    "outx_warp_id_o",
    "outx_wb_wxd_rd_o",
    "outx_wxd_o",
    "rst_n"
  ],
  "timing": "Asynchronous reset on rst_n falling edge; all other state samples pre-edge values at clk rising edges. Compare settled native outputs before/after edges.",
  "boundary": "Fixed4 lanes and all binary6-bit functions,reverse,flags,valid/ready histories; arithmetic modulo stated widths."
}
