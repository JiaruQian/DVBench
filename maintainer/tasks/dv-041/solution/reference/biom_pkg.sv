`timescale 1ns/1ps
package biom_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class biom_item extends uvm_sequence_item;
    `uvm_object_utils(biom_item)
    rand logic io_mem_access_ready;
    rand logic [127:0] io_mem_ack_bits_data;
    rand logic io_mem_ack_valid;
    rand logic [39:0] io_req_bits_addr;
    rand logic [63:0] io_req_bits_data;
    rand logic io_req_bits_is_hella;
    rand logic io_req_bits_uop_bp_debug_if;
    rand logic io_req_bits_uop_bp_xcpt_if;
    rand logic [19:0] io_req_bits_uop_br_mask;
    rand logic [4:0] io_req_bits_uop_br_tag;
    rand logic io_req_bits_uop_bypassable;
    rand logic [11:0] io_req_bits_uop_csr_addr;
    rand logic [3:0] io_req_bits_uop_ctrl_br_type;
    rand logic [2:0] io_req_bits_uop_ctrl_csr_cmd;
    rand logic io_req_bits_uop_ctrl_fcn_dw;
    rand logic [2:0] io_req_bits_uop_ctrl_imm_sel;
    rand logic io_req_bits_uop_ctrl_is_load;
    rand logic io_req_bits_uop_ctrl_is_sta;
    rand logic io_req_bits_uop_ctrl_is_std;
    rand logic [1:0] io_req_bits_uop_ctrl_op1_sel;
    rand logic [2:0] io_req_bits_uop_ctrl_op2_sel;
    rand logic [3:0] io_req_bits_uop_ctrl_op_fcn;
    rand logic [1:0] io_req_bits_uop_debug_fsrc;
    rand logic [31:0] io_req_bits_uop_debug_inst;
    rand logic [39:0] io_req_bits_uop_debug_pc;
    rand logic [1:0] io_req_bits_uop_debug_tsrc;
    rand logic [1:0] io_req_bits_uop_dst_rtype;
    rand logic io_req_bits_uop_edge_inst;
    rand logic [63:0] io_req_bits_uop_exc_cause;
    rand logic io_req_bits_uop_exception;
    rand logic io_req_bits_uop_flush_on_commit;
    rand logic io_req_bits_uop_fp_single;
    rand logic io_req_bits_uop_fp_val;
    rand logic io_req_bits_uop_frs3_en;
    rand logic [5:0] io_req_bits_uop_ftq_idx;
    rand logic [9:0] io_req_bits_uop_fu_code;
    rand logic [19:0] io_req_bits_uop_imm_packed;
    rand logic [31:0] io_req_bits_uop_inst;
    rand logic [2:0] io_req_bits_uop_iq_type;
    rand logic io_req_bits_uop_is_amo;
    rand logic io_req_bits_uop_is_br;
    rand logic io_req_bits_uop_is_fence;
    rand logic io_req_bits_uop_is_fencei;
    rand logic io_req_bits_uop_is_jal;
    rand logic io_req_bits_uop_is_jalr;
    rand logic io_req_bits_uop_is_rvc;
    rand logic io_req_bits_uop_is_sfb;
    rand logic io_req_bits_uop_is_sys_pc2epc;
    rand logic io_req_bits_uop_is_unique;
    rand logic io_req_bits_uop_iw_p1_poisoned;
    rand logic io_req_bits_uop_iw_p2_poisoned;
    rand logic [1:0] io_req_bits_uop_iw_state;
    rand logic [4:0] io_req_bits_uop_ldq_idx;
    rand logic [5:0] io_req_bits_uop_ldst;
    rand logic io_req_bits_uop_ldst_is_rs1;
    rand logic io_req_bits_uop_ldst_val;
    rand logic [5:0] io_req_bits_uop_lrs1;
    rand logic [1:0] io_req_bits_uop_lrs1_rtype;
    rand logic [5:0] io_req_bits_uop_lrs2;
    rand logic [1:0] io_req_bits_uop_lrs2_rtype;
    rand logic [5:0] io_req_bits_uop_lrs3;
    rand logic [4:0] io_req_bits_uop_mem_cmd;
    rand logic io_req_bits_uop_mem_signed;
    rand logic [1:0] io_req_bits_uop_mem_size;
    rand logic [5:0] io_req_bits_uop_pc_lob;
    rand logic [6:0] io_req_bits_uop_pdst;
    rand logic [5:0] io_req_bits_uop_ppred;
    rand logic io_req_bits_uop_ppred_busy;
    rand logic [6:0] io_req_bits_uop_prs1;
    rand logic io_req_bits_uop_prs1_busy;
    rand logic [6:0] io_req_bits_uop_prs2;
    rand logic io_req_bits_uop_prs2_busy;
    rand logic [6:0] io_req_bits_uop_prs3;
    rand logic io_req_bits_uop_prs3_busy;
    rand logic [6:0] io_req_bits_uop_rob_idx;
    rand logic [1:0] io_req_bits_uop_rxq_idx;
    rand logic [6:0] io_req_bits_uop_stale_pdst;
    rand logic [4:0] io_req_bits_uop_stq_idx;
    rand logic io_req_bits_uop_taken;
    rand logic [6:0] io_req_bits_uop_uopc;
    rand logic io_req_bits_uop_uses_ldq;
    rand logic io_req_bits_uop_uses_stq;
    rand logic io_req_bits_uop_xcpt_ae_if;
    rand logic io_req_bits_uop_xcpt_ma_if;
    rand logic io_req_bits_uop_xcpt_pf_if;
    rand logic io_req_valid;
    rand logic io_resp_ready;
    bit short_reset;
    rand logic reset;
    function new(string name="biom_item"); super.new(name); endfunction
  endclass
  class biom_driver extends uvm_driver #(biom_item);
    `uvm_component_utils(biom_driver)
    virtual biom_if vif;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase); if(!uvm_config_db#(virtual biom_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface") endfunction
    task run_phase(uvm_phase phase);
      biom_item item;
      forever begin seq_item_port.get_next_item(item); @(negedge vif.clock);
        vif.io_mem_access_ready=item.io_mem_access_ready;
        vif.io_mem_ack_bits_data=item.io_mem_ack_bits_data;
        vif.io_mem_ack_valid=item.io_mem_ack_valid;
        vif.io_req_bits_addr=item.io_req_bits_addr;
        vif.io_req_bits_data=item.io_req_bits_data;
        vif.io_req_bits_is_hella=item.io_req_bits_is_hella;
        vif.io_req_bits_uop_bp_debug_if=item.io_req_bits_uop_bp_debug_if;
        vif.io_req_bits_uop_bp_xcpt_if=item.io_req_bits_uop_bp_xcpt_if;
        vif.io_req_bits_uop_br_mask=item.io_req_bits_uop_br_mask;
        vif.io_req_bits_uop_br_tag=item.io_req_bits_uop_br_tag;
        vif.io_req_bits_uop_bypassable=item.io_req_bits_uop_bypassable;
        vif.io_req_bits_uop_csr_addr=item.io_req_bits_uop_csr_addr;
        vif.io_req_bits_uop_ctrl_br_type=item.io_req_bits_uop_ctrl_br_type;
        vif.io_req_bits_uop_ctrl_csr_cmd=item.io_req_bits_uop_ctrl_csr_cmd;
        vif.io_req_bits_uop_ctrl_fcn_dw=item.io_req_bits_uop_ctrl_fcn_dw;
        vif.io_req_bits_uop_ctrl_imm_sel=item.io_req_bits_uop_ctrl_imm_sel;
        vif.io_req_bits_uop_ctrl_is_load=item.io_req_bits_uop_ctrl_is_load;
        vif.io_req_bits_uop_ctrl_is_sta=item.io_req_bits_uop_ctrl_is_sta;
        vif.io_req_bits_uop_ctrl_is_std=item.io_req_bits_uop_ctrl_is_std;
        vif.io_req_bits_uop_ctrl_op1_sel=item.io_req_bits_uop_ctrl_op1_sel;
        vif.io_req_bits_uop_ctrl_op2_sel=item.io_req_bits_uop_ctrl_op2_sel;
        vif.io_req_bits_uop_ctrl_op_fcn=item.io_req_bits_uop_ctrl_op_fcn;
        vif.io_req_bits_uop_debug_fsrc=item.io_req_bits_uop_debug_fsrc;
        vif.io_req_bits_uop_debug_inst=item.io_req_bits_uop_debug_inst;
        vif.io_req_bits_uop_debug_pc=item.io_req_bits_uop_debug_pc;
        vif.io_req_bits_uop_debug_tsrc=item.io_req_bits_uop_debug_tsrc;
        vif.io_req_bits_uop_dst_rtype=item.io_req_bits_uop_dst_rtype;
        vif.io_req_bits_uop_edge_inst=item.io_req_bits_uop_edge_inst;
        vif.io_req_bits_uop_exc_cause=item.io_req_bits_uop_exc_cause;
        vif.io_req_bits_uop_exception=item.io_req_bits_uop_exception;
        vif.io_req_bits_uop_flush_on_commit=item.io_req_bits_uop_flush_on_commit;
        vif.io_req_bits_uop_fp_single=item.io_req_bits_uop_fp_single;
        vif.io_req_bits_uop_fp_val=item.io_req_bits_uop_fp_val;
        vif.io_req_bits_uop_frs3_en=item.io_req_bits_uop_frs3_en;
        vif.io_req_bits_uop_ftq_idx=item.io_req_bits_uop_ftq_idx;
        vif.io_req_bits_uop_fu_code=item.io_req_bits_uop_fu_code;
        vif.io_req_bits_uop_imm_packed=item.io_req_bits_uop_imm_packed;
        vif.io_req_bits_uop_inst=item.io_req_bits_uop_inst;
        vif.io_req_bits_uop_iq_type=item.io_req_bits_uop_iq_type;
        vif.io_req_bits_uop_is_amo=item.io_req_bits_uop_is_amo;
        vif.io_req_bits_uop_is_br=item.io_req_bits_uop_is_br;
        vif.io_req_bits_uop_is_fence=item.io_req_bits_uop_is_fence;
        vif.io_req_bits_uop_is_fencei=item.io_req_bits_uop_is_fencei;
        vif.io_req_bits_uop_is_jal=item.io_req_bits_uop_is_jal;
        vif.io_req_bits_uop_is_jalr=item.io_req_bits_uop_is_jalr;
        vif.io_req_bits_uop_is_rvc=item.io_req_bits_uop_is_rvc;
        vif.io_req_bits_uop_is_sfb=item.io_req_bits_uop_is_sfb;
        vif.io_req_bits_uop_is_sys_pc2epc=item.io_req_bits_uop_is_sys_pc2epc;
        vif.io_req_bits_uop_is_unique=item.io_req_bits_uop_is_unique;
        vif.io_req_bits_uop_iw_p1_poisoned=item.io_req_bits_uop_iw_p1_poisoned;
        vif.io_req_bits_uop_iw_p2_poisoned=item.io_req_bits_uop_iw_p2_poisoned;
        vif.io_req_bits_uop_iw_state=item.io_req_bits_uop_iw_state;
        vif.io_req_bits_uop_ldq_idx=item.io_req_bits_uop_ldq_idx;
        vif.io_req_bits_uop_ldst=item.io_req_bits_uop_ldst;
        vif.io_req_bits_uop_ldst_is_rs1=item.io_req_bits_uop_ldst_is_rs1;
        vif.io_req_bits_uop_ldst_val=item.io_req_bits_uop_ldst_val;
        vif.io_req_bits_uop_lrs1=item.io_req_bits_uop_lrs1;
        vif.io_req_bits_uop_lrs1_rtype=item.io_req_bits_uop_lrs1_rtype;
        vif.io_req_bits_uop_lrs2=item.io_req_bits_uop_lrs2;
        vif.io_req_bits_uop_lrs2_rtype=item.io_req_bits_uop_lrs2_rtype;
        vif.io_req_bits_uop_lrs3=item.io_req_bits_uop_lrs3;
        vif.io_req_bits_uop_mem_cmd=item.io_req_bits_uop_mem_cmd;
        vif.io_req_bits_uop_mem_signed=item.io_req_bits_uop_mem_signed;
        vif.io_req_bits_uop_mem_size=item.io_req_bits_uop_mem_size;
        vif.io_req_bits_uop_pc_lob=item.io_req_bits_uop_pc_lob;
        vif.io_req_bits_uop_pdst=item.io_req_bits_uop_pdst;
        vif.io_req_bits_uop_ppred=item.io_req_bits_uop_ppred;
        vif.io_req_bits_uop_ppred_busy=item.io_req_bits_uop_ppred_busy;
        vif.io_req_bits_uop_prs1=item.io_req_bits_uop_prs1;
        vif.io_req_bits_uop_prs1_busy=item.io_req_bits_uop_prs1_busy;
        vif.io_req_bits_uop_prs2=item.io_req_bits_uop_prs2;
        vif.io_req_bits_uop_prs2_busy=item.io_req_bits_uop_prs2_busy;
        vif.io_req_bits_uop_prs3=item.io_req_bits_uop_prs3;
        vif.io_req_bits_uop_prs3_busy=item.io_req_bits_uop_prs3_busy;
        vif.io_req_bits_uop_rob_idx=item.io_req_bits_uop_rob_idx;
        vif.io_req_bits_uop_rxq_idx=item.io_req_bits_uop_rxq_idx;
        vif.io_req_bits_uop_stale_pdst=item.io_req_bits_uop_stale_pdst;
        vif.io_req_bits_uop_stq_idx=item.io_req_bits_uop_stq_idx;
        vif.io_req_bits_uop_taken=item.io_req_bits_uop_taken;
        vif.io_req_bits_uop_uopc=item.io_req_bits_uop_uopc;
        vif.io_req_bits_uop_uses_ldq=item.io_req_bits_uop_uses_ldq;
        vif.io_req_bits_uop_uses_stq=item.io_req_bits_uop_uses_stq;
        vif.io_req_bits_uop_xcpt_ae_if=item.io_req_bits_uop_xcpt_ae_if;
        vif.io_req_bits_uop_xcpt_ma_if=item.io_req_bits_uop_xcpt_ma_if;
        vif.io_req_bits_uop_xcpt_pf_if=item.io_req_bits_uop_xcpt_pf_if;
        vif.io_req_valid=item.io_req_valid;
        vif.io_resp_ready=item.io_resp_ready;
        vif.reset=item.reset;
        if(item.short_reset) begin #1; vif.reset=1; #2; vif.reset=0; end
        @(posedge vif.clock); #3; seq_item_port.item_done(); end
    endtask
  endclass
  class biom_scoreboard extends uvm_component;
    `uvm_component_utils(biom_scoreboard)
    virtual biom_if vif;
    int observations;
    bit initialized;
    int mismatches;
    covergroup transactions with function sample(bit request,bit access,bit response,bit reset,bit[4:0] command,bit[1:0] size,bit[3:0] lane,bit signed_value);
      request_cp: coverpoint request;
      access_cp: coverpoint access;
      response_cp: coverpoint response;
      reset_cp: coverpoint reset;
      command_cp: coverpoint command;
      size_cp: coverpoint size;
      lane_cp: coverpoint lane;
      signed_cp: coverpoint signed_value;
      size_lane: cross size_cp,lane_cp;
    endgroup
    function new(string name,uvm_component parent); super.new(name,parent); transactions=new(); endfunction
    function void build_phase(uvm_phase phase); if(!uvm_config_db#(virtual biom_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface") endfunction
    task compare();
      if(!initialized) return;
      observations++;
      transactions.sample(vif.io_req_valid,vif.io_mem_access_valid,vif.io_resp_valid,vif.reset,vif.io_req_bits_uop_mem_cmd,vif.io_req_bits_uop_mem_size,vif.io_req_bits_addr[3:0],vif.io_req_bits_uop_mem_signed);
      if(vif.io_mem_access_bits_address !== vif.expected_io_mem_access_bits_address) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_mem_access_bits_address differs from independent predictor")
      end
      if(vif.io_mem_access_bits_data !== vif.expected_io_mem_access_bits_data) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_mem_access_bits_data differs from independent predictor")
      end
      if(vif.io_mem_access_bits_mask !== vif.expected_io_mem_access_bits_mask) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_mem_access_bits_mask differs from independent predictor")
      end
      if(vif.io_mem_access_bits_opcode !== vif.expected_io_mem_access_bits_opcode) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_mem_access_bits_opcode differs from independent predictor")
      end
      if(vif.io_mem_access_bits_param !== vif.expected_io_mem_access_bits_param) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_mem_access_bits_param differs from independent predictor")
      end
      if(vif.io_mem_access_bits_size !== vif.expected_io_mem_access_bits_size) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_mem_access_bits_size differs from independent predictor")
      end
      if(vif.io_mem_access_bits_source !== vif.expected_io_mem_access_bits_source) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_mem_access_bits_source differs from independent predictor")
      end
      if(vif.io_mem_access_valid !== vif.expected_io_mem_access_valid) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_mem_access_valid differs from independent predictor")
      end
      if(vif.io_req_ready !== vif.expected_io_req_ready) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_req_ready differs from independent predictor")
      end
      if(vif.io_resp_bits_data !== vif.expected_io_resp_bits_data) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_data differs from independent predictor")
      end
      if(vif.io_resp_bits_is_hella !== vif.expected_io_resp_bits_is_hella) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_is_hella differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_bp_debug_if !== vif.expected_io_resp_bits_uop_bp_debug_if) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_bp_debug_if differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_bp_xcpt_if !== vif.expected_io_resp_bits_uop_bp_xcpt_if) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_bp_xcpt_if differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_br_mask !== vif.expected_io_resp_bits_uop_br_mask) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_br_mask differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_br_tag !== vif.expected_io_resp_bits_uop_br_tag) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_br_tag differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_bypassable !== vif.expected_io_resp_bits_uop_bypassable) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_bypassable differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_csr_addr !== vif.expected_io_resp_bits_uop_csr_addr) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_csr_addr differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_ctrl_br_type !== vif.expected_io_resp_bits_uop_ctrl_br_type) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_ctrl_br_type differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_ctrl_csr_cmd !== vif.expected_io_resp_bits_uop_ctrl_csr_cmd) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_ctrl_csr_cmd differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_ctrl_fcn_dw !== vif.expected_io_resp_bits_uop_ctrl_fcn_dw) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_ctrl_fcn_dw differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_ctrl_imm_sel !== vif.expected_io_resp_bits_uop_ctrl_imm_sel) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_ctrl_imm_sel differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_ctrl_is_load !== vif.expected_io_resp_bits_uop_ctrl_is_load) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_ctrl_is_load differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_ctrl_is_sta !== vif.expected_io_resp_bits_uop_ctrl_is_sta) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_ctrl_is_sta differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_ctrl_is_std !== vif.expected_io_resp_bits_uop_ctrl_is_std) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_ctrl_is_std differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_ctrl_op1_sel !== vif.expected_io_resp_bits_uop_ctrl_op1_sel) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_ctrl_op1_sel differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_ctrl_op2_sel !== vif.expected_io_resp_bits_uop_ctrl_op2_sel) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_ctrl_op2_sel differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_ctrl_op_fcn !== vif.expected_io_resp_bits_uop_ctrl_op_fcn) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_ctrl_op_fcn differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_debug_fsrc !== vif.expected_io_resp_bits_uop_debug_fsrc) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_debug_fsrc differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_debug_inst !== vif.expected_io_resp_bits_uop_debug_inst) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_debug_inst differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_debug_pc !== vif.expected_io_resp_bits_uop_debug_pc) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_debug_pc differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_debug_tsrc !== vif.expected_io_resp_bits_uop_debug_tsrc) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_debug_tsrc differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_dst_rtype !== vif.expected_io_resp_bits_uop_dst_rtype) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_dst_rtype differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_edge_inst !== vif.expected_io_resp_bits_uop_edge_inst) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_edge_inst differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_exc_cause !== vif.expected_io_resp_bits_uop_exc_cause) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_exc_cause differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_exception !== vif.expected_io_resp_bits_uop_exception) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_exception differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_flush_on_commit !== vif.expected_io_resp_bits_uop_flush_on_commit) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_flush_on_commit differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_fp_single !== vif.expected_io_resp_bits_uop_fp_single) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_fp_single differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_fp_val !== vif.expected_io_resp_bits_uop_fp_val) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_fp_val differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_frs3_en !== vif.expected_io_resp_bits_uop_frs3_en) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_frs3_en differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_ftq_idx !== vif.expected_io_resp_bits_uop_ftq_idx) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_ftq_idx differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_fu_code !== vif.expected_io_resp_bits_uop_fu_code) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_fu_code differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_imm_packed !== vif.expected_io_resp_bits_uop_imm_packed) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_imm_packed differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_inst !== vif.expected_io_resp_bits_uop_inst) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_inst differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_iq_type !== vif.expected_io_resp_bits_uop_iq_type) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_iq_type differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_is_amo !== vif.expected_io_resp_bits_uop_is_amo) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_is_amo differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_is_br !== vif.expected_io_resp_bits_uop_is_br) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_is_br differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_is_fence !== vif.expected_io_resp_bits_uop_is_fence) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_is_fence differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_is_fencei !== vif.expected_io_resp_bits_uop_is_fencei) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_is_fencei differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_is_jal !== vif.expected_io_resp_bits_uop_is_jal) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_is_jal differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_is_jalr !== vif.expected_io_resp_bits_uop_is_jalr) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_is_jalr differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_is_rvc !== vif.expected_io_resp_bits_uop_is_rvc) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_is_rvc differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_is_sfb !== vif.expected_io_resp_bits_uop_is_sfb) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_is_sfb differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_is_sys_pc2epc !== vif.expected_io_resp_bits_uop_is_sys_pc2epc) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_is_sys_pc2epc differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_is_unique !== vif.expected_io_resp_bits_uop_is_unique) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_is_unique differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_iw_p1_poisoned !== vif.expected_io_resp_bits_uop_iw_p1_poisoned) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_iw_p1_poisoned differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_iw_p2_poisoned !== vif.expected_io_resp_bits_uop_iw_p2_poisoned) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_iw_p2_poisoned differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_iw_state !== vif.expected_io_resp_bits_uop_iw_state) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_iw_state differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_ldq_idx !== vif.expected_io_resp_bits_uop_ldq_idx) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_ldq_idx differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_ldst !== vif.expected_io_resp_bits_uop_ldst) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_ldst differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_ldst_is_rs1 !== vif.expected_io_resp_bits_uop_ldst_is_rs1) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_ldst_is_rs1 differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_ldst_val !== vif.expected_io_resp_bits_uop_ldst_val) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_ldst_val differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_lrs1 !== vif.expected_io_resp_bits_uop_lrs1) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_lrs1 differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_lrs1_rtype !== vif.expected_io_resp_bits_uop_lrs1_rtype) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_lrs1_rtype differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_lrs2 !== vif.expected_io_resp_bits_uop_lrs2) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_lrs2 differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_lrs2_rtype !== vif.expected_io_resp_bits_uop_lrs2_rtype) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_lrs2_rtype differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_lrs3 !== vif.expected_io_resp_bits_uop_lrs3) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_lrs3 differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_mem_cmd !== vif.expected_io_resp_bits_uop_mem_cmd) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_mem_cmd differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_mem_signed !== vif.expected_io_resp_bits_uop_mem_signed) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_mem_signed differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_mem_size !== vif.expected_io_resp_bits_uop_mem_size) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_mem_size differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_pc_lob !== vif.expected_io_resp_bits_uop_pc_lob) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_pc_lob differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_pdst !== vif.expected_io_resp_bits_uop_pdst) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_pdst differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_ppred !== vif.expected_io_resp_bits_uop_ppred) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_ppred differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_ppred_busy !== vif.expected_io_resp_bits_uop_ppred_busy) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_ppred_busy differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_prs1 !== vif.expected_io_resp_bits_uop_prs1) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_prs1 differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_prs1_busy !== vif.expected_io_resp_bits_uop_prs1_busy) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_prs1_busy differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_prs2 !== vif.expected_io_resp_bits_uop_prs2) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_prs2 differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_prs2_busy !== vif.expected_io_resp_bits_uop_prs2_busy) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_prs2_busy differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_prs3 !== vif.expected_io_resp_bits_uop_prs3) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_prs3 differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_prs3_busy !== vif.expected_io_resp_bits_uop_prs3_busy) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_prs3_busy differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_rob_idx !== vif.expected_io_resp_bits_uop_rob_idx) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_rob_idx differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_rxq_idx !== vif.expected_io_resp_bits_uop_rxq_idx) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_rxq_idx differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_stale_pdst !== vif.expected_io_resp_bits_uop_stale_pdst) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_stale_pdst differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_stq_idx !== vif.expected_io_resp_bits_uop_stq_idx) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_stq_idx differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_taken !== vif.expected_io_resp_bits_uop_taken) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_taken differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_uopc !== vif.expected_io_resp_bits_uop_uopc) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_uopc differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_uses_ldq !== vif.expected_io_resp_bits_uop_uses_ldq) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_uses_ldq differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_uses_stq !== vif.expected_io_resp_bits_uop_uses_stq) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_uses_stq differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_xcpt_ae_if !== vif.expected_io_resp_bits_uop_xcpt_ae_if) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_xcpt_ae_if differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_xcpt_ma_if !== vif.expected_io_resp_bits_uop_xcpt_ma_if) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_xcpt_ma_if differs from independent predictor")
      end
      if(vif.io_resp_bits_uop_xcpt_pf_if !== vif.expected_io_resp_bits_uop_xcpt_pf_if) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_bits_uop_xcpt_pf_if differs from independent predictor")
      end
      if(vif.io_resp_valid !== vif.expected_io_resp_valid) begin
        mismatches++;
        if(mismatches<=12) `uvm_error("COMPARE","io_resp_valid differs from independent predictor")
      end
    endtask
    task run_phase(uvm_phase phase); forever begin @(negedge vif.clock); #2; compare(); @(posedge vif.clock); #2; if(vif.reset && vif.io_req_valid) initialized=1; compare(); end endtask
    function void check_phase(uvm_phase phase); if(observations<100) `uvm_error("VACUITY","insufficient samples") if(mismatches>0) `uvm_error("TOTAL",$sformatf("%0d mismatches",mismatches)) endfunction
  endclass
  class biom_sequence extends uvm_sequence #(biom_item);
    `uvm_object_utils(biom_sequence)
    int beats;
    function new(string name="biom_sequence"); super.new(name); endfunction
    task beat(int mode,int command=0,int size=0,int lane=0,int signed_value=0);
      biom_item item=biom_item::type_id::create("drive");
      start_item(item); if(!item.randomize()) `uvm_fatal("RANDOM","randomization failed")
      beats++;
      if(item.io_req_bits_uop_mem_cmd==7) item.io_req_bits_uop_mem_cmd=6;
      if(beats%3==0) item.io_req_bits_addr='0; else if(beats%3==1) item.io_req_bits_addr='1;
      if(beats%3==0) item.io_req_bits_data='0; else if(beats%3==1) item.io_req_bits_data='1;
      if(beats%3==0) item.io_req_bits_is_hella='0; else if(beats%3==1) item.io_req_bits_is_hella='1;
      if(beats%3==0) item.io_req_bits_uop_bp_debug_if='0; else if(beats%3==1) item.io_req_bits_uop_bp_debug_if='1;
      if(beats%3==0) item.io_req_bits_uop_bp_xcpt_if='0; else if(beats%3==1) item.io_req_bits_uop_bp_xcpt_if='1;
      if(beats%3==0) item.io_req_bits_uop_br_mask='0; else if(beats%3==1) item.io_req_bits_uop_br_mask='1;
      if(beats%3==0) item.io_req_bits_uop_br_tag='0; else if(beats%3==1) item.io_req_bits_uop_br_tag='1;
      if(beats%3==0) item.io_req_bits_uop_bypassable='0; else if(beats%3==1) item.io_req_bits_uop_bypassable='1;
      if(beats%3==0) item.io_req_bits_uop_csr_addr='0; else if(beats%3==1) item.io_req_bits_uop_csr_addr='1;
      if(beats%3==0) item.io_req_bits_uop_ctrl_br_type='0; else if(beats%3==1) item.io_req_bits_uop_ctrl_br_type='1;
      if(beats%3==0) item.io_req_bits_uop_ctrl_csr_cmd='0; else if(beats%3==1) item.io_req_bits_uop_ctrl_csr_cmd='1;
      if(beats%3==0) item.io_req_bits_uop_ctrl_fcn_dw='0; else if(beats%3==1) item.io_req_bits_uop_ctrl_fcn_dw='1;
      if(beats%3==0) item.io_req_bits_uop_ctrl_imm_sel='0; else if(beats%3==1) item.io_req_bits_uop_ctrl_imm_sel='1;
      if(beats%3==0) item.io_req_bits_uop_ctrl_is_load='0; else if(beats%3==1) item.io_req_bits_uop_ctrl_is_load='1;
      if(beats%3==0) item.io_req_bits_uop_ctrl_is_sta='0; else if(beats%3==1) item.io_req_bits_uop_ctrl_is_sta='1;
      if(beats%3==0) item.io_req_bits_uop_ctrl_is_std='0; else if(beats%3==1) item.io_req_bits_uop_ctrl_is_std='1;
      if(beats%3==0) item.io_req_bits_uop_ctrl_op1_sel='0; else if(beats%3==1) item.io_req_bits_uop_ctrl_op1_sel='1;
      if(beats%3==0) item.io_req_bits_uop_ctrl_op2_sel='0; else if(beats%3==1) item.io_req_bits_uop_ctrl_op2_sel='1;
      if(beats%3==0) item.io_req_bits_uop_ctrl_op_fcn='0; else if(beats%3==1) item.io_req_bits_uop_ctrl_op_fcn='1;
      if(beats%3==0) item.io_req_bits_uop_debug_fsrc='0; else if(beats%3==1) item.io_req_bits_uop_debug_fsrc='1;
      if(beats%3==0) item.io_req_bits_uop_debug_inst='0; else if(beats%3==1) item.io_req_bits_uop_debug_inst='1;
      if(beats%3==0) item.io_req_bits_uop_debug_pc='0; else if(beats%3==1) item.io_req_bits_uop_debug_pc='1;
      if(beats%3==0) item.io_req_bits_uop_debug_tsrc='0; else if(beats%3==1) item.io_req_bits_uop_debug_tsrc='1;
      if(beats%3==0) item.io_req_bits_uop_dst_rtype='0; else if(beats%3==1) item.io_req_bits_uop_dst_rtype='1;
      if(beats%3==0) item.io_req_bits_uop_edge_inst='0; else if(beats%3==1) item.io_req_bits_uop_edge_inst='1;
      if(beats%3==0) item.io_req_bits_uop_exc_cause='0; else if(beats%3==1) item.io_req_bits_uop_exc_cause='1;
      if(beats%3==0) item.io_req_bits_uop_exception='0; else if(beats%3==1) item.io_req_bits_uop_exception='1;
      if(beats%3==0) item.io_req_bits_uop_flush_on_commit='0; else if(beats%3==1) item.io_req_bits_uop_flush_on_commit='1;
      if(beats%3==0) item.io_req_bits_uop_fp_single='0; else if(beats%3==1) item.io_req_bits_uop_fp_single='1;
      if(beats%3==0) item.io_req_bits_uop_fp_val='0; else if(beats%3==1) item.io_req_bits_uop_fp_val='1;
      if(beats%3==0) item.io_req_bits_uop_frs3_en='0; else if(beats%3==1) item.io_req_bits_uop_frs3_en='1;
      if(beats%3==0) item.io_req_bits_uop_ftq_idx='0; else if(beats%3==1) item.io_req_bits_uop_ftq_idx='1;
      if(beats%3==0) item.io_req_bits_uop_fu_code='0; else if(beats%3==1) item.io_req_bits_uop_fu_code='1;
      if(beats%3==0) item.io_req_bits_uop_imm_packed='0; else if(beats%3==1) item.io_req_bits_uop_imm_packed='1;
      if(beats%3==0) item.io_req_bits_uop_inst='0; else if(beats%3==1) item.io_req_bits_uop_inst='1;
      if(beats%3==0) item.io_req_bits_uop_iq_type='0; else if(beats%3==1) item.io_req_bits_uop_iq_type='1;
      if(beats%3==0) item.io_req_bits_uop_is_amo='0; else if(beats%3==1) item.io_req_bits_uop_is_amo='1;
      if(beats%3==0) item.io_req_bits_uop_is_br='0; else if(beats%3==1) item.io_req_bits_uop_is_br='1;
      if(beats%3==0) item.io_req_bits_uop_is_fence='0; else if(beats%3==1) item.io_req_bits_uop_is_fence='1;
      if(beats%3==0) item.io_req_bits_uop_is_fencei='0; else if(beats%3==1) item.io_req_bits_uop_is_fencei='1;
      if(beats%3==0) item.io_req_bits_uop_is_jal='0; else if(beats%3==1) item.io_req_bits_uop_is_jal='1;
      if(beats%3==0) item.io_req_bits_uop_is_jalr='0; else if(beats%3==1) item.io_req_bits_uop_is_jalr='1;
      if(beats%3==0) item.io_req_bits_uop_is_rvc='0; else if(beats%3==1) item.io_req_bits_uop_is_rvc='1;
      if(beats%3==0) item.io_req_bits_uop_is_sfb='0; else if(beats%3==1) item.io_req_bits_uop_is_sfb='1;
      if(beats%3==0) item.io_req_bits_uop_is_sys_pc2epc='0; else if(beats%3==1) item.io_req_bits_uop_is_sys_pc2epc='1;
      if(beats%3==0) item.io_req_bits_uop_is_unique='0; else if(beats%3==1) item.io_req_bits_uop_is_unique='1;
      if(beats%3==0) item.io_req_bits_uop_iw_p1_poisoned='0; else if(beats%3==1) item.io_req_bits_uop_iw_p1_poisoned='1;
      if(beats%3==0) item.io_req_bits_uop_iw_p2_poisoned='0; else if(beats%3==1) item.io_req_bits_uop_iw_p2_poisoned='1;
      if(beats%3==0) item.io_req_bits_uop_iw_state='0; else if(beats%3==1) item.io_req_bits_uop_iw_state='1;
      if(beats%3==0) item.io_req_bits_uop_ldq_idx='0; else if(beats%3==1) item.io_req_bits_uop_ldq_idx='1;
      if(beats%3==0) item.io_req_bits_uop_ldst='0; else if(beats%3==1) item.io_req_bits_uop_ldst='1;
      if(beats%3==0) item.io_req_bits_uop_ldst_is_rs1='0; else if(beats%3==1) item.io_req_bits_uop_ldst_is_rs1='1;
      if(beats%3==0) item.io_req_bits_uop_ldst_val='0; else if(beats%3==1) item.io_req_bits_uop_ldst_val='1;
      if(beats%3==0) item.io_req_bits_uop_lrs1='0; else if(beats%3==1) item.io_req_bits_uop_lrs1='1;
      if(beats%3==0) item.io_req_bits_uop_lrs1_rtype='0; else if(beats%3==1) item.io_req_bits_uop_lrs1_rtype='1;
      if(beats%3==0) item.io_req_bits_uop_lrs2='0; else if(beats%3==1) item.io_req_bits_uop_lrs2='1;
      if(beats%3==0) item.io_req_bits_uop_lrs2_rtype='0; else if(beats%3==1) item.io_req_bits_uop_lrs2_rtype='1;
      if(beats%3==0) item.io_req_bits_uop_lrs3='0; else if(beats%3==1) item.io_req_bits_uop_lrs3='1;
      if(beats%3==0) item.io_req_bits_uop_mem_cmd='0; else if(beats%3==1) item.io_req_bits_uop_mem_cmd='1;
      if(beats%3==0) item.io_req_bits_uop_mem_signed='0; else if(beats%3==1) item.io_req_bits_uop_mem_signed='1;
      if(beats%3==0) item.io_req_bits_uop_mem_size='0; else if(beats%3==1) item.io_req_bits_uop_mem_size='1;
      if(beats%3==0) item.io_req_bits_uop_pc_lob='0; else if(beats%3==1) item.io_req_bits_uop_pc_lob='1;
      if(beats%3==0) item.io_req_bits_uop_pdst='0; else if(beats%3==1) item.io_req_bits_uop_pdst='1;
      if(beats%3==0) item.io_req_bits_uop_ppred='0; else if(beats%3==1) item.io_req_bits_uop_ppred='1;
      if(beats%3==0) item.io_req_bits_uop_ppred_busy='0; else if(beats%3==1) item.io_req_bits_uop_ppred_busy='1;
      if(beats%3==0) item.io_req_bits_uop_prs1='0; else if(beats%3==1) item.io_req_bits_uop_prs1='1;
      if(beats%3==0) item.io_req_bits_uop_prs1_busy='0; else if(beats%3==1) item.io_req_bits_uop_prs1_busy='1;
      if(beats%3==0) item.io_req_bits_uop_prs2='0; else if(beats%3==1) item.io_req_bits_uop_prs2='1;
      if(beats%3==0) item.io_req_bits_uop_prs2_busy='0; else if(beats%3==1) item.io_req_bits_uop_prs2_busy='1;
      if(beats%3==0) item.io_req_bits_uop_prs3='0; else if(beats%3==1) item.io_req_bits_uop_prs3='1;
      if(beats%3==0) item.io_req_bits_uop_prs3_busy='0; else if(beats%3==1) item.io_req_bits_uop_prs3_busy='1;
      if(beats%3==0) item.io_req_bits_uop_rob_idx='0; else if(beats%3==1) item.io_req_bits_uop_rob_idx='1;
      if(beats%3==0) item.io_req_bits_uop_rxq_idx='0; else if(beats%3==1) item.io_req_bits_uop_rxq_idx='1;
      if(beats%3==0) item.io_req_bits_uop_stale_pdst='0; else if(beats%3==1) item.io_req_bits_uop_stale_pdst='1;
      if(beats%3==0) item.io_req_bits_uop_stq_idx='0; else if(beats%3==1) item.io_req_bits_uop_stq_idx='1;
      if(beats%3==0) item.io_req_bits_uop_taken='0; else if(beats%3==1) item.io_req_bits_uop_taken='1;
      if(beats%3==0) item.io_req_bits_uop_uopc='0; else if(beats%3==1) item.io_req_bits_uop_uopc='1;
      if(beats%3==0) item.io_req_bits_uop_uses_ldq='0; else if(beats%3==1) item.io_req_bits_uop_uses_ldq='1;
      if(beats%3==0) item.io_req_bits_uop_uses_stq='0; else if(beats%3==1) item.io_req_bits_uop_uses_stq='1;
      if(beats%3==0) item.io_req_bits_uop_xcpt_ae_if='0; else if(beats%3==1) item.io_req_bits_uop_xcpt_ae_if='1;
      if(beats%3==0) item.io_req_bits_uop_xcpt_ma_if='0; else if(beats%3==1) item.io_req_bits_uop_xcpt_ma_if='1;
      if(beats%3==0) item.io_req_bits_uop_xcpt_pf_if='0; else if(beats%3==1) item.io_req_bits_uop_xcpt_pf_if='1;
      item.short_reset=(mode==9); item.reset=(mode==0 || mode==10); item.io_req_valid=(mode>=1 && mode<=6);
      item.io_mem_access_ready=(mode==3 || mode==11); item.io_mem_ack_valid=(mode==5 || mode==8 || mode==10 || mode==11 || mode==12); item.io_resp_ready=(mode==7);
      if(mode==0 || mode==1) begin item.io_req_valid=1; item.io_req_bits_uop_mem_cmd=command; item.io_req_bits_uop_mem_size=size; item.io_req_bits_uop_mem_signed=signed_value; item.io_req_bits_addr[3:0]=lane; end
      finish_item(item);
    endtask
    task transaction(int command,int size,int lane,int signed_value);
      beat(1,command,size,lane,signed_value);
      beat(12); beat(2); beat(11);
      repeat(2) beat(4); beat(5);
      if(command inside {0,4,6,8,9,10,11,12,13,14,15,16}) begin repeat(2) beat(6); beat(7); end
      else beat(7);
      beat(8);
    endtask
    task body();
      beat(0); beat(8);
      for(int command=0;command<32;command++) begin
        if(command==7) continue;
        for(int size=0;size<4;size++) for(int signed_value=0;signed_value<2;signed_value++) transaction(command,size,(command+size*4)%16,signed_value);
      end
      for(int size=0;size<4;size++) for(int lane=0;lane<16;lane++) for(int signed_value=0;signed_value<2;signed_value++) transaction(0,size,lane,signed_value);
      for(int target=1;target<4;target++) begin
        beat(0,4); beat(1,4,3,8,1);
        if(target>=2) beat(3);
        if(target>=3) beat(5);
        beat(9);
        if(target==2) beat(10); else beat(0,6,1,2,0); beat(8);
      end
      beat(0,7); beat(8); transaction(0,3,0,0);
      beat(0); beat(8);
    endtask
  endclass
  class dvbench_test extends uvm_test;
    `uvm_component_utils(dvbench_test)
    uvm_sequencer #(biom_item) sequencer;
    biom_driver driver;
    biom_scoreboard scoreboard;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase); sequencer=new("sequencer",this); driver=biom_driver::type_id::create("driver",this); scoreboard=biom_scoreboard::type_id::create("scoreboard",this); endfunction
    function void connect_phase(uvm_phase phase); driver.seq_item_port.connect(sequencer.seq_item_export); endfunction
    task run_phase(uvm_phase phase); biom_sequence sequence_handle=biom_sequence::type_id::create("sequence_handle"); phase.raise_objection(this); sequence_handle.start(sequencer); repeat(3) @(posedge driver.vif.clock); phase.drop_objection(this); endtask
    function void report_phase(uvm_phase phase); uvm_report_server reports=uvm_report_server::get_server(); if(reports.get_severity_count(UVM_ERROR)==0 && reports.get_severity_count(UVM_FATAL)==0) $display("DVBench_COMPLETED"); endfunction
  endclass
endpackage
