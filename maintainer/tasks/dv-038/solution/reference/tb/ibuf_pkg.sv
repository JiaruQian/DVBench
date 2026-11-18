`timescale 1ns/1ps
package ibuf_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class ibuf_item extends uvm_sequence_item;
        `uvm_object_utils(ibuf_item)
        bit reset_request;
        bit ibuffer_in_valid_i;
        bit [1:0] ibuffer_in_control_mask_i;
        bit ibuffer_flush_wid_valid_i;
        bit [2:0] ibuffer_flush_wid_i;
        bit [7:0] ibuffer2issue_io_in_ready_i;
        bit [7:0] warp_sche_io_warp_ready_i;
        bit [7:0] ibuffer2issue_grant_i;
        bit [63:0] ibuffer_in_control_Signals_inst_i;
        bit [5:0] ibuffer_in_control_Signals_wid_i;
        bit [1:0] ibuffer_in_control_Signals_fp_i;
        bit [3:0] ibuffer_in_control_Signals_branch_i;
        bit [1:0] ibuffer_in_control_Signals_simt_stack_i;
        bit [1:0] ibuffer_in_control_Signals_simt_stack_op_i;
        bit [1:0] ibuffer_in_control_Signals_barrier_i;
        bit [3:0] ibuffer_in_control_Signals_csr_i;
        bit [1:0] ibuffer_in_control_Signals_reverse_i;
        bit [3:0] ibuffer_in_control_Signals_sel_alu2_i;
        bit [3:0] ibuffer_in_control_Signals_sel_alu1_i;
        bit [3:0] ibuffer_in_control_Signals_sel_alu3_i;
        bit [1:0] ibuffer_in_control_Signals_isvec_i;
        bit [1:0] ibuffer_in_control_Signals_mask_i;
        bit [7:0] ibuffer_in_control_Signals_sel_imm_i;
        bit [3:0] ibuffer_in_control_Signals_mem_whb_i;
        bit [1:0] ibuffer_in_control_Signals_mem_unsigned_i;
        bit [11:0] ibuffer_in_control_Signals_alu_fn_i;
        bit [1:0] ibuffer_in_control_Signals_force_rm_rtz_i;
        bit [1:0] ibuffer_in_control_Signals_is_vls12_i;
        bit [1:0] ibuffer_in_control_Signals_mem_i;
        bit [1:0] ibuffer_in_control_Signals_mul_i;
        bit [1:0] ibuffer_in_control_Signals_tc_i;
        bit [1:0] ibuffer_in_control_Signals_disable_mask_i;
        bit [1:0] ibuffer_in_control_Signals_custom_signal_0_i;
        bit [3:0] ibuffer_in_control_Signals_mem_cmd_i;
        bit [3:0] ibuffer_in_control_Signals_mop_i;
        bit [15:0] ibuffer_in_control_Signals_reg_idx1_i;
        bit [15:0] ibuffer_in_control_Signals_reg_idx2_i;
        bit [15:0] ibuffer_in_control_Signals_reg_idx3_i;
        bit [15:0] ibuffer_in_control_Signals_reg_idxw_i;
        bit [1:0] ibuffer_in_control_Signals_wvd_i;
        bit [1:0] ibuffer_in_control_Signals_fence_i;
        bit [1:0] ibuffer_in_control_Signals_sfu_i;
        bit [1:0] ibuffer_in_control_Signals_readmask_i;
        bit [1:0] ibuffer_in_control_Signals_writemask_i;
        bit [1:0] ibuffer_in_control_Signals_wxd_i;
        bit [63:0] ibuffer_in_control_Signals_pc_i;
        bit [11:0] ibuffer_in_control_Signals_imm_ext_i;
        bit [1:0] ibuffer_in_control_Signals_atomic_i;
        bit [1:0] ibuffer_in_control_Signals_aq_i;
        bit [1:0] ibuffer_in_control_Signals_rl_i;
        bit [5:0] ibuffer_in_control_Signals_rm_i;
        bit [1:0] ibuffer_in_control_Signals_rm_is_static_i;

        function new(string name="ibuf_item");super.new(name);endfunction
    endclass
    class ibuf_sequence extends uvm_sequence #(ibuf_item);
        `uvm_object_utils(ibuf_sequence)
        virtual ibuf_if vif;
        function new(string name="ibuf_sequence");super.new(name);endfunction
        task send_reset();
            ibuf_item item=ibuf_item::type_id::create("reset");
            if(vif.stop_requested)return;
            start_item(item);item.reset_request=1;finish_item(item);
        endtask
        task send(bit [2:0] bank,bit [1:0] lane_mask,bit enqueue,bit [7:0] issue_ready,bit [7:0] warp_ready,bit [7:0] grant,bit flush,bit [2:0] flush_bank,bit randomized);
            ibuf_item item=ibuf_item::type_id::create("pair_operation");
            if(vif.stop_requested)return;
            start_item(item);
            item.ibuffer_in_valid_i=$urandom;
            item.ibuffer_in_control_mask_i[0+:2]=$urandom;
            item.ibuffer_flush_wid_valid_i=$urandom;
            item.ibuffer_flush_wid_i[0+:3]=$urandom;
            item.ibuffer2issue_io_in_ready_i[0+:8]=$urandom;
            item.warp_sche_io_warp_ready_i[0+:8]=$urandom;
            item.ibuffer2issue_grant_i[0+:8]=$urandom;
            item.ibuffer_in_control_Signals_inst_i[0+:32]=$urandom;
            item.ibuffer_in_control_Signals_inst_i[32+:32]=$urandom;
            item.ibuffer_in_control_Signals_wid_i[0+:6]=$urandom;
            item.ibuffer_in_control_Signals_fp_i[0+:2]=$urandom;
            item.ibuffer_in_control_Signals_branch_i[0+:4]=$urandom;
            item.ibuffer_in_control_Signals_simt_stack_i[0+:2]=$urandom;
            item.ibuffer_in_control_Signals_simt_stack_op_i[0+:2]=$urandom;
            item.ibuffer_in_control_Signals_barrier_i[0+:2]=$urandom;
            item.ibuffer_in_control_Signals_csr_i[0+:4]=$urandom;
            item.ibuffer_in_control_Signals_reverse_i[0+:2]=$urandom;
            item.ibuffer_in_control_Signals_sel_alu2_i[0+:4]=$urandom;
            item.ibuffer_in_control_Signals_sel_alu1_i[0+:4]=$urandom;
            item.ibuffer_in_control_Signals_sel_alu3_i[0+:4]=$urandom;
            item.ibuffer_in_control_Signals_isvec_i[0+:2]=$urandom;
            item.ibuffer_in_control_Signals_mask_i[0+:2]=$urandom;
            item.ibuffer_in_control_Signals_sel_imm_i[0+:8]=$urandom;
            item.ibuffer_in_control_Signals_mem_whb_i[0+:4]=$urandom;
            item.ibuffer_in_control_Signals_mem_unsigned_i[0+:2]=$urandom;
            item.ibuffer_in_control_Signals_alu_fn_i[0+:12]=$urandom;
            item.ibuffer_in_control_Signals_force_rm_rtz_i[0+:2]=$urandom;
            item.ibuffer_in_control_Signals_is_vls12_i[0+:2]=$urandom;
            item.ibuffer_in_control_Signals_mem_i[0+:2]=$urandom;
            item.ibuffer_in_control_Signals_mul_i[0+:2]=$urandom;
            item.ibuffer_in_control_Signals_tc_i[0+:2]=$urandom;
            item.ibuffer_in_control_Signals_disable_mask_i[0+:2]=$urandom;
            item.ibuffer_in_control_Signals_custom_signal_0_i[0+:2]=$urandom;
            item.ibuffer_in_control_Signals_mem_cmd_i[0+:4]=$urandom;
            item.ibuffer_in_control_Signals_mop_i[0+:4]=$urandom;
            item.ibuffer_in_control_Signals_reg_idx1_i[0+:16]=$urandom;
            item.ibuffer_in_control_Signals_reg_idx2_i[0+:16]=$urandom;
            item.ibuffer_in_control_Signals_reg_idx3_i[0+:16]=$urandom;
            item.ibuffer_in_control_Signals_reg_idxw_i[0+:16]=$urandom;
            item.ibuffer_in_control_Signals_wvd_i[0+:2]=$urandom;
            item.ibuffer_in_control_Signals_fence_i[0+:2]=$urandom;
            item.ibuffer_in_control_Signals_sfu_i[0+:2]=$urandom;
            item.ibuffer_in_control_Signals_readmask_i[0+:2]=$urandom;
            item.ibuffer_in_control_Signals_writemask_i[0+:2]=$urandom;
            item.ibuffer_in_control_Signals_wxd_i[0+:2]=$urandom;
            item.ibuffer_in_control_Signals_pc_i[0+:32]=$urandom;
            item.ibuffer_in_control_Signals_pc_i[32+:32]=$urandom;
            item.ibuffer_in_control_Signals_imm_ext_i[0+:12]=$urandom;
            item.ibuffer_in_control_Signals_atomic_i[0+:2]=$urandom;
            item.ibuffer_in_control_Signals_aq_i[0+:2]=$urandom;
            item.ibuffer_in_control_Signals_rl_i[0+:2]=$urandom;
            item.ibuffer_in_control_Signals_rm_i[0+:6]=$urandom;
            item.ibuffer_in_control_Signals_rm_is_static_i[0+:2]=$urandom;
            if(!randomized)begin
                item.ibuffer_in_control_Signals_wid_i[2:0]=bank;item.ibuffer_in_control_mask_i=lane_mask;item.ibuffer_in_valid_i=enqueue;
                item.ibuffer2issue_io_in_ready_i=issue_ready;item.warp_sche_io_warp_ready_i=warp_ready;item.ibuffer2issue_grant_i=grant;
                item.ibuffer_flush_wid_valid_i=flush;item.ibuffer_flush_wid_i=flush_bank;
            end
            finish_item(item);
        endtask

        task duplicate_pair_witness();
            for(int bank=0;bank<8;bank++)begin
                for(int lane_mask=0;lane_mask<4;lane_mask++)begin
                    send_reset();
                    for(int copy_index=0;copy_index<2;copy_index++)begin
                        ibuf_item item=ibuf_item::type_id::create("identical_pair");
                        if(vif.stop_requested)return;
                        start_item(item);
                        item.ibuffer_in_valid_i=1;
                        item.ibuffer_in_control_mask_i=2'(lane_mask);
                        item.ibuffer_in_control_Signals_wid_i={3'(bank^7),3'(bank)};
                        item.ibuffer_in_control_Signals_inst_i=64'hdeadbeef12345678;
                        item.ibuffer_in_control_Signals_pc_i=64'h8000000400000100;
                        finish_item(item);
                    end
                    repeat(12)send(bank,0,0,255,255,255,0,bank,0);
                end
            end
            send_reset();
        endtask
        task body();
            int unsigned random_value;
            if(!uvm_config_db#(virtual ibuf_if)::get(null,"","vif",vif))`uvm_fatal("CONFIG","Missing sequence interface")
            send_reset();
            duplicate_pair_witness();
            for(int bank=0;bank<8;bank++)for(int lane_mask=0;lane_mask<4;lane_mask++)begin
                repeat(6)send(bank,lane_mask,1,0,0,0,0,bank,0);
                for(int iteration=0;iteration<12;iteration++)send(bank,lane_mask,0,255,255,iteration%3==0?0:255,0,bank,0);
                send(bank,lane_mask,1,255,255,255,1,bank,0);
                repeat(3)send(bank,lane_mask,0,255,255,255,0,bank,0);
            end
            for(int bank=0;bank<8;bank++)begin
                repeat(5)send(bank,3,1,255,255,0,0,bank,0);
                repeat(5)send(bank,3,1,255,0,255,0,bank,0);
                repeat(5)send(bank,3,1,0,255,255,0,bank,0);
                repeat(15)send(bank,3,1,255,255,255,0,bank,0);
            end
            send_reset();
            for(int iteration=0;iteration<7000;iteration++)begin
                send(0,0,0,0,0,0,0,0,1);
                if(iteration==831||iteration==4611)send_reset();
            end
            send_reset();
            repeat(10)send(0,0,0,255,255,255,0,0,0);

        endtask
    endclass
    class ibuf_driver extends uvm_driver #(ibuf_item);
        `uvm_component_utils(ibuf_driver)
        virtual ibuf_if vif;
        function new(string name,uvm_component parent);super.new(name,parent);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual ibuf_if)::get(this,"","vif",vif))`uvm_fatal("CONFIG","Missing driver interface")
        endfunction
        task run_phase(uvm_phase phase);
            ibuf_item item;
            forever begin
                seq_item_port.get_next_item(item);
                @(negedge vif.clk);
                if(item.reset_request)begin
                    vif.checking=1;
                    #2 vif.rst_n=0;
                    repeat(3)@(posedge vif.clk);
                    @(negedge vif.clk);vif.rst_n=1;
                end else begin
                    vif.ibuffer_in_valid_i=item.ibuffer_in_valid_i;
                    vif.ibuffer_in_control_mask_i=item.ibuffer_in_control_mask_i;
                    vif.ibuffer_flush_wid_valid_i=item.ibuffer_flush_wid_valid_i;
                    vif.ibuffer_flush_wid_i=item.ibuffer_flush_wid_i;
                    vif.ibuffer2issue_io_in_ready_i=item.ibuffer2issue_io_in_ready_i;
                    vif.warp_sche_io_warp_ready_i=item.warp_sche_io_warp_ready_i;
                    vif.ibuffer2issue_grant_i=item.ibuffer2issue_grant_i;
                    vif.ibuffer_in_control_Signals_inst_i=item.ibuffer_in_control_Signals_inst_i;
                    vif.ibuffer_in_control_Signals_wid_i=item.ibuffer_in_control_Signals_wid_i;
                    vif.ibuffer_in_control_Signals_fp_i=item.ibuffer_in_control_Signals_fp_i;
                    vif.ibuffer_in_control_Signals_branch_i=item.ibuffer_in_control_Signals_branch_i;
                    vif.ibuffer_in_control_Signals_simt_stack_i=item.ibuffer_in_control_Signals_simt_stack_i;
                    vif.ibuffer_in_control_Signals_simt_stack_op_i=item.ibuffer_in_control_Signals_simt_stack_op_i;
                    vif.ibuffer_in_control_Signals_barrier_i=item.ibuffer_in_control_Signals_barrier_i;
                    vif.ibuffer_in_control_Signals_csr_i=item.ibuffer_in_control_Signals_csr_i;
                    vif.ibuffer_in_control_Signals_reverse_i=item.ibuffer_in_control_Signals_reverse_i;
                    vif.ibuffer_in_control_Signals_sel_alu2_i=item.ibuffer_in_control_Signals_sel_alu2_i;
                    vif.ibuffer_in_control_Signals_sel_alu1_i=item.ibuffer_in_control_Signals_sel_alu1_i;
                    vif.ibuffer_in_control_Signals_sel_alu3_i=item.ibuffer_in_control_Signals_sel_alu3_i;
                    vif.ibuffer_in_control_Signals_isvec_i=item.ibuffer_in_control_Signals_isvec_i;
                    vif.ibuffer_in_control_Signals_mask_i=item.ibuffer_in_control_Signals_mask_i;
                    vif.ibuffer_in_control_Signals_sel_imm_i=item.ibuffer_in_control_Signals_sel_imm_i;
                    vif.ibuffer_in_control_Signals_mem_whb_i=item.ibuffer_in_control_Signals_mem_whb_i;
                    vif.ibuffer_in_control_Signals_mem_unsigned_i=item.ibuffer_in_control_Signals_mem_unsigned_i;
                    vif.ibuffer_in_control_Signals_alu_fn_i=item.ibuffer_in_control_Signals_alu_fn_i;
                    vif.ibuffer_in_control_Signals_force_rm_rtz_i=item.ibuffer_in_control_Signals_force_rm_rtz_i;
                    vif.ibuffer_in_control_Signals_is_vls12_i=item.ibuffer_in_control_Signals_is_vls12_i;
                    vif.ibuffer_in_control_Signals_mem_i=item.ibuffer_in_control_Signals_mem_i;
                    vif.ibuffer_in_control_Signals_mul_i=item.ibuffer_in_control_Signals_mul_i;
                    vif.ibuffer_in_control_Signals_tc_i=item.ibuffer_in_control_Signals_tc_i;
                    vif.ibuffer_in_control_Signals_disable_mask_i=item.ibuffer_in_control_Signals_disable_mask_i;
                    vif.ibuffer_in_control_Signals_custom_signal_0_i=item.ibuffer_in_control_Signals_custom_signal_0_i;
                    vif.ibuffer_in_control_Signals_mem_cmd_i=item.ibuffer_in_control_Signals_mem_cmd_i;
                    vif.ibuffer_in_control_Signals_mop_i=item.ibuffer_in_control_Signals_mop_i;
                    vif.ibuffer_in_control_Signals_reg_idx1_i=item.ibuffer_in_control_Signals_reg_idx1_i;
                    vif.ibuffer_in_control_Signals_reg_idx2_i=item.ibuffer_in_control_Signals_reg_idx2_i;
                    vif.ibuffer_in_control_Signals_reg_idx3_i=item.ibuffer_in_control_Signals_reg_idx3_i;
                    vif.ibuffer_in_control_Signals_reg_idxw_i=item.ibuffer_in_control_Signals_reg_idxw_i;
                    vif.ibuffer_in_control_Signals_wvd_i=item.ibuffer_in_control_Signals_wvd_i;
                    vif.ibuffer_in_control_Signals_fence_i=item.ibuffer_in_control_Signals_fence_i;
                    vif.ibuffer_in_control_Signals_sfu_i=item.ibuffer_in_control_Signals_sfu_i;
                    vif.ibuffer_in_control_Signals_readmask_i=item.ibuffer_in_control_Signals_readmask_i;
                    vif.ibuffer_in_control_Signals_writemask_i=item.ibuffer_in_control_Signals_writemask_i;
                    vif.ibuffer_in_control_Signals_wxd_i=item.ibuffer_in_control_Signals_wxd_i;
                    vif.ibuffer_in_control_Signals_pc_i=item.ibuffer_in_control_Signals_pc_i;
                    vif.ibuffer_in_control_Signals_imm_ext_i=item.ibuffer_in_control_Signals_imm_ext_i;
                    vif.ibuffer_in_control_Signals_atomic_i=item.ibuffer_in_control_Signals_atomic_i;
                    vif.ibuffer_in_control_Signals_aq_i=item.ibuffer_in_control_Signals_aq_i;
                    vif.ibuffer_in_control_Signals_rl_i=item.ibuffer_in_control_Signals_rl_i;
                    vif.ibuffer_in_control_Signals_rm_i=item.ibuffer_in_control_Signals_rm_i;
                    vif.ibuffer_in_control_Signals_rm_is_static_i=item.ibuffer_in_control_Signals_rm_is_static_i;

                    @(posedge vif.clk);#2;
                end
                seq_item_port.item_done();
            end
        endtask
    endclass
    class ibuf_sample extends uvm_sequence_item;
        `uvm_object_utils(ibuf_sample)
        logic actual_ibuffer_in_ready_o;
        logic expected_ibuffer_in_ready_o;
        logic [7:0] actual_ibuffer_ready_o;
        logic [7:0] expected_ibuffer_ready_o;
        logic [7:0] actual_ibuffer_out_valid_o;
        logic [7:0] expected_ibuffer_out_valid_o;
        logic [255:0] actual_ibuffer_warps_control_Signals_inst_o;
        logic [255:0] expected_ibuffer_warps_control_Signals_inst_o;
        logic [23:0] actual_ibuffer_warps_control_Signals_wid_o;
        logic [23:0] expected_ibuffer_warps_control_Signals_wid_o;
        logic [7:0] actual_ibuffer_warps_control_Signals_fp_o;
        logic [7:0] expected_ibuffer_warps_control_Signals_fp_o;
        logic [15:0] actual_ibuffer_warps_control_Signals_branch_o;
        logic [15:0] expected_ibuffer_warps_control_Signals_branch_o;
        logic [7:0] actual_ibuffer_warps_control_Signals_simt_stack_o;
        logic [7:0] expected_ibuffer_warps_control_Signals_simt_stack_o;
        logic [7:0] actual_ibuffer_warps_control_Signals_simt_stack_op_o;
        logic [7:0] expected_ibuffer_warps_control_Signals_simt_stack_op_o;
        logic [7:0] actual_ibuffer_warps_control_Signals_barrier_o;
        logic [7:0] expected_ibuffer_warps_control_Signals_barrier_o;
        logic [15:0] actual_ibuffer_warps_control_Signals_csr_o;
        logic [15:0] expected_ibuffer_warps_control_Signals_csr_o;
        logic [7:0] actual_ibuffer_warps_control_Signals_reverse_o;
        logic [7:0] expected_ibuffer_warps_control_Signals_reverse_o;
        logic [15:0] actual_ibuffer_warps_control_Signals_sel_alu2_o;
        logic [15:0] expected_ibuffer_warps_control_Signals_sel_alu2_o;
        logic [15:0] actual_ibuffer_warps_control_Signals_sel_alu1_o;
        logic [15:0] expected_ibuffer_warps_control_Signals_sel_alu1_o;
        logic [15:0] actual_ibuffer_warps_control_Signals_sel_alu3_o;
        logic [15:0] expected_ibuffer_warps_control_Signals_sel_alu3_o;
        logic [7:0] actual_ibuffer_warps_control_Signals_isvec_o;
        logic [7:0] expected_ibuffer_warps_control_Signals_isvec_o;
        logic [7:0] actual_ibuffer_warps_control_Signals_mask_o;
        logic [7:0] expected_ibuffer_warps_control_Signals_mask_o;
        logic [31:0] actual_ibuffer_warps_control_Signals_sel_imm_o;
        logic [31:0] expected_ibuffer_warps_control_Signals_sel_imm_o;
        logic [15:0] actual_ibuffer_warps_control_Signals_mem_whb_o;
        logic [15:0] expected_ibuffer_warps_control_Signals_mem_whb_o;
        logic [7:0] actual_ibuffer_warps_control_Signals_mem_unsigned_o;
        logic [7:0] expected_ibuffer_warps_control_Signals_mem_unsigned_o;
        logic [47:0] actual_ibuffer_warps_control_Signals_alu_fn_o;
        logic [47:0] expected_ibuffer_warps_control_Signals_alu_fn_o;
        logic [7:0] actual_ibuffer_warps_control_Signals_force_rm_rtz_o;
        logic [7:0] expected_ibuffer_warps_control_Signals_force_rm_rtz_o;
        logic [7:0] actual_ibuffer_warps_control_Signals_is_vls12_o;
        logic [7:0] expected_ibuffer_warps_control_Signals_is_vls12_o;
        logic [7:0] actual_ibuffer_warps_control_Signals_mem_o;
        logic [7:0] expected_ibuffer_warps_control_Signals_mem_o;
        logic [7:0] actual_ibuffer_warps_control_Signals_mul_o;
        logic [7:0] expected_ibuffer_warps_control_Signals_mul_o;
        logic [7:0] actual_ibuffer_warps_control_Signals_tc_o;
        logic [7:0] expected_ibuffer_warps_control_Signals_tc_o;
        logic [7:0] actual_ibuffer_warps_control_Signals_disable_mask_o;
        logic [7:0] expected_ibuffer_warps_control_Signals_disable_mask_o;
        logic [7:0] actual_ibuffer_warps_control_Signals_custom_signal_0_o;
        logic [7:0] expected_ibuffer_warps_control_Signals_custom_signal_0_o;
        logic [15:0] actual_ibuffer_warps_control_Signals_mem_cmd_o;
        logic [15:0] expected_ibuffer_warps_control_Signals_mem_cmd_o;
        logic [15:0] actual_ibuffer_warps_control_Signals_mop_o;
        logic [15:0] expected_ibuffer_warps_control_Signals_mop_o;
        logic [63:0] actual_ibuffer_warps_control_Signals_reg_idx1_o;
        logic [63:0] expected_ibuffer_warps_control_Signals_reg_idx1_o;
        logic [63:0] actual_ibuffer_warps_control_Signals_reg_idx2_o;
        logic [63:0] expected_ibuffer_warps_control_Signals_reg_idx2_o;
        logic [63:0] actual_ibuffer_warps_control_Signals_reg_idx3_o;
        logic [63:0] expected_ibuffer_warps_control_Signals_reg_idx3_o;
        logic [63:0] actual_ibuffer_warps_control_Signals_reg_idxw_o;
        logic [63:0] expected_ibuffer_warps_control_Signals_reg_idxw_o;
        logic [7:0] actual_ibuffer_warps_control_Signals_wvd_o;
        logic [7:0] expected_ibuffer_warps_control_Signals_wvd_o;
        logic [7:0] actual_ibuffer_warps_control_Signals_fence_o;
        logic [7:0] expected_ibuffer_warps_control_Signals_fence_o;
        logic [7:0] actual_ibuffer_warps_control_Signals_sfu_o;
        logic [7:0] expected_ibuffer_warps_control_Signals_sfu_o;
        logic [7:0] actual_ibuffer_warps_control_Signals_readmask_o;
        logic [7:0] expected_ibuffer_warps_control_Signals_readmask_o;
        logic [7:0] actual_ibuffer_warps_control_Signals_wxd_o;
        logic [7:0] expected_ibuffer_warps_control_Signals_wxd_o;
        logic [255:0] actual_ibuffer_warps_control_Signals_pc_o;
        logic [255:0] expected_ibuffer_warps_control_Signals_pc_o;
        logic [47:0] actual_ibuffer_warps_control_Signals_imm_ext_o;
        logic [47:0] expected_ibuffer_warps_control_Signals_imm_ext_o;
        logic [7:0] actual_ibuffer_warps_control_Signals_atomic_o;
        logic [7:0] expected_ibuffer_warps_control_Signals_atomic_o;
        logic [7:0] actual_ibuffer_warps_control_Signals_aq_o;
        logic [7:0] expected_ibuffer_warps_control_Signals_aq_o;
        logic [7:0] actual_ibuffer_warps_control_Signals_rl_o;
        logic [7:0] expected_ibuffer_warps_control_Signals_rl_o;
        logic [23:0] actual_ibuffer_warps_control_Signals_rm_o;
        logic [23:0] expected_ibuffer_warps_control_Signals_rm_o;
        logic [7:0] actual_ibuffer_warps_control_Signals_rm_is_static_o;
        logic [7:0] expected_ibuffer_warps_control_Signals_rm_is_static_o;

        bit asynchronous_reset;
        function new(string name="ibuf_sample");super.new(name);endfunction
    endclass
    class ibuf_monitor extends uvm_monitor;
        `uvm_component_utils(ibuf_monitor)
        virtual ibuf_if vif;
        uvm_analysis_port #(ibuf_sample) samples;
        function new(string name,uvm_component parent);super.new(name,parent);samples=new("samples",this);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual ibuf_if)::get(this,"","vif",vif))`uvm_fatal("CONFIG","Missing monitor interface")
        endfunction
        task sample_ports(bit asynchronous_reset);
            ibuf_sample sample=ibuf_sample::type_id::create("sample");
            #1;
            if(vif.checking)begin
                sample.actual_ibuffer_in_ready_o=vif.ibuffer_in_ready_o;sample.expected_ibuffer_in_ready_o=vif.expected_ibuffer_in_ready_o;
                sample.actual_ibuffer_ready_o=vif.ibuffer_ready_o;sample.expected_ibuffer_ready_o=vif.expected_ibuffer_ready_o;
                sample.actual_ibuffer_out_valid_o=vif.ibuffer_out_valid_o;sample.expected_ibuffer_out_valid_o=vif.expected_ibuffer_out_valid_o;
                sample.actual_ibuffer_warps_control_Signals_inst_o=vif.ibuffer_warps_control_Signals_inst_o;sample.expected_ibuffer_warps_control_Signals_inst_o=vif.expected_ibuffer_warps_control_Signals_inst_o;
                sample.actual_ibuffer_warps_control_Signals_wid_o=vif.ibuffer_warps_control_Signals_wid_o;sample.expected_ibuffer_warps_control_Signals_wid_o=vif.expected_ibuffer_warps_control_Signals_wid_o;
                sample.actual_ibuffer_warps_control_Signals_fp_o=vif.ibuffer_warps_control_Signals_fp_o;sample.expected_ibuffer_warps_control_Signals_fp_o=vif.expected_ibuffer_warps_control_Signals_fp_o;
                sample.actual_ibuffer_warps_control_Signals_branch_o=vif.ibuffer_warps_control_Signals_branch_o;sample.expected_ibuffer_warps_control_Signals_branch_o=vif.expected_ibuffer_warps_control_Signals_branch_o;
                sample.actual_ibuffer_warps_control_Signals_simt_stack_o=vif.ibuffer_warps_control_Signals_simt_stack_o;sample.expected_ibuffer_warps_control_Signals_simt_stack_o=vif.expected_ibuffer_warps_control_Signals_simt_stack_o;
                sample.actual_ibuffer_warps_control_Signals_simt_stack_op_o=vif.ibuffer_warps_control_Signals_simt_stack_op_o;sample.expected_ibuffer_warps_control_Signals_simt_stack_op_o=vif.expected_ibuffer_warps_control_Signals_simt_stack_op_o;
                sample.actual_ibuffer_warps_control_Signals_barrier_o=vif.ibuffer_warps_control_Signals_barrier_o;sample.expected_ibuffer_warps_control_Signals_barrier_o=vif.expected_ibuffer_warps_control_Signals_barrier_o;
                sample.actual_ibuffer_warps_control_Signals_csr_o=vif.ibuffer_warps_control_Signals_csr_o;sample.expected_ibuffer_warps_control_Signals_csr_o=vif.expected_ibuffer_warps_control_Signals_csr_o;
                sample.actual_ibuffer_warps_control_Signals_reverse_o=vif.ibuffer_warps_control_Signals_reverse_o;sample.expected_ibuffer_warps_control_Signals_reverse_o=vif.expected_ibuffer_warps_control_Signals_reverse_o;
                sample.actual_ibuffer_warps_control_Signals_sel_alu2_o=vif.ibuffer_warps_control_Signals_sel_alu2_o;sample.expected_ibuffer_warps_control_Signals_sel_alu2_o=vif.expected_ibuffer_warps_control_Signals_sel_alu2_o;
                sample.actual_ibuffer_warps_control_Signals_sel_alu1_o=vif.ibuffer_warps_control_Signals_sel_alu1_o;sample.expected_ibuffer_warps_control_Signals_sel_alu1_o=vif.expected_ibuffer_warps_control_Signals_sel_alu1_o;
                sample.actual_ibuffer_warps_control_Signals_sel_alu3_o=vif.ibuffer_warps_control_Signals_sel_alu3_o;sample.expected_ibuffer_warps_control_Signals_sel_alu3_o=vif.expected_ibuffer_warps_control_Signals_sel_alu3_o;
                sample.actual_ibuffer_warps_control_Signals_isvec_o=vif.ibuffer_warps_control_Signals_isvec_o;sample.expected_ibuffer_warps_control_Signals_isvec_o=vif.expected_ibuffer_warps_control_Signals_isvec_o;
                sample.actual_ibuffer_warps_control_Signals_mask_o=vif.ibuffer_warps_control_Signals_mask_o;sample.expected_ibuffer_warps_control_Signals_mask_o=vif.expected_ibuffer_warps_control_Signals_mask_o;
                sample.actual_ibuffer_warps_control_Signals_sel_imm_o=vif.ibuffer_warps_control_Signals_sel_imm_o;sample.expected_ibuffer_warps_control_Signals_sel_imm_o=vif.expected_ibuffer_warps_control_Signals_sel_imm_o;
                sample.actual_ibuffer_warps_control_Signals_mem_whb_o=vif.ibuffer_warps_control_Signals_mem_whb_o;sample.expected_ibuffer_warps_control_Signals_mem_whb_o=vif.expected_ibuffer_warps_control_Signals_mem_whb_o;
                sample.actual_ibuffer_warps_control_Signals_mem_unsigned_o=vif.ibuffer_warps_control_Signals_mem_unsigned_o;sample.expected_ibuffer_warps_control_Signals_mem_unsigned_o=vif.expected_ibuffer_warps_control_Signals_mem_unsigned_o;
                sample.actual_ibuffer_warps_control_Signals_alu_fn_o=vif.ibuffer_warps_control_Signals_alu_fn_o;sample.expected_ibuffer_warps_control_Signals_alu_fn_o=vif.expected_ibuffer_warps_control_Signals_alu_fn_o;
                sample.actual_ibuffer_warps_control_Signals_force_rm_rtz_o=vif.ibuffer_warps_control_Signals_force_rm_rtz_o;sample.expected_ibuffer_warps_control_Signals_force_rm_rtz_o=vif.expected_ibuffer_warps_control_Signals_force_rm_rtz_o;
                sample.actual_ibuffer_warps_control_Signals_is_vls12_o=vif.ibuffer_warps_control_Signals_is_vls12_o;sample.expected_ibuffer_warps_control_Signals_is_vls12_o=vif.expected_ibuffer_warps_control_Signals_is_vls12_o;
                sample.actual_ibuffer_warps_control_Signals_mem_o=vif.ibuffer_warps_control_Signals_mem_o;sample.expected_ibuffer_warps_control_Signals_mem_o=vif.expected_ibuffer_warps_control_Signals_mem_o;
                sample.actual_ibuffer_warps_control_Signals_mul_o=vif.ibuffer_warps_control_Signals_mul_o;sample.expected_ibuffer_warps_control_Signals_mul_o=vif.expected_ibuffer_warps_control_Signals_mul_o;
                sample.actual_ibuffer_warps_control_Signals_tc_o=vif.ibuffer_warps_control_Signals_tc_o;sample.expected_ibuffer_warps_control_Signals_tc_o=vif.expected_ibuffer_warps_control_Signals_tc_o;
                sample.actual_ibuffer_warps_control_Signals_disable_mask_o=vif.ibuffer_warps_control_Signals_disable_mask_o;sample.expected_ibuffer_warps_control_Signals_disable_mask_o=vif.expected_ibuffer_warps_control_Signals_disable_mask_o;
                sample.actual_ibuffer_warps_control_Signals_custom_signal_0_o=vif.ibuffer_warps_control_Signals_custom_signal_0_o;sample.expected_ibuffer_warps_control_Signals_custom_signal_0_o=vif.expected_ibuffer_warps_control_Signals_custom_signal_0_o;
                sample.actual_ibuffer_warps_control_Signals_mem_cmd_o=vif.ibuffer_warps_control_Signals_mem_cmd_o;sample.expected_ibuffer_warps_control_Signals_mem_cmd_o=vif.expected_ibuffer_warps_control_Signals_mem_cmd_o;
                sample.actual_ibuffer_warps_control_Signals_mop_o=vif.ibuffer_warps_control_Signals_mop_o;sample.expected_ibuffer_warps_control_Signals_mop_o=vif.expected_ibuffer_warps_control_Signals_mop_o;
                sample.actual_ibuffer_warps_control_Signals_reg_idx1_o=vif.ibuffer_warps_control_Signals_reg_idx1_o;sample.expected_ibuffer_warps_control_Signals_reg_idx1_o=vif.expected_ibuffer_warps_control_Signals_reg_idx1_o;
                sample.actual_ibuffer_warps_control_Signals_reg_idx2_o=vif.ibuffer_warps_control_Signals_reg_idx2_o;sample.expected_ibuffer_warps_control_Signals_reg_idx2_o=vif.expected_ibuffer_warps_control_Signals_reg_idx2_o;
                sample.actual_ibuffer_warps_control_Signals_reg_idx3_o=vif.ibuffer_warps_control_Signals_reg_idx3_o;sample.expected_ibuffer_warps_control_Signals_reg_idx3_o=vif.expected_ibuffer_warps_control_Signals_reg_idx3_o;
                sample.actual_ibuffer_warps_control_Signals_reg_idxw_o=vif.ibuffer_warps_control_Signals_reg_idxw_o;sample.expected_ibuffer_warps_control_Signals_reg_idxw_o=vif.expected_ibuffer_warps_control_Signals_reg_idxw_o;
                sample.actual_ibuffer_warps_control_Signals_wvd_o=vif.ibuffer_warps_control_Signals_wvd_o;sample.expected_ibuffer_warps_control_Signals_wvd_o=vif.expected_ibuffer_warps_control_Signals_wvd_o;
                sample.actual_ibuffer_warps_control_Signals_fence_o=vif.ibuffer_warps_control_Signals_fence_o;sample.expected_ibuffer_warps_control_Signals_fence_o=vif.expected_ibuffer_warps_control_Signals_fence_o;
                sample.actual_ibuffer_warps_control_Signals_sfu_o=vif.ibuffer_warps_control_Signals_sfu_o;sample.expected_ibuffer_warps_control_Signals_sfu_o=vif.expected_ibuffer_warps_control_Signals_sfu_o;
                sample.actual_ibuffer_warps_control_Signals_readmask_o=vif.ibuffer_warps_control_Signals_readmask_o;sample.expected_ibuffer_warps_control_Signals_readmask_o=vif.expected_ibuffer_warps_control_Signals_readmask_o;
                sample.actual_ibuffer_warps_control_Signals_wxd_o=vif.ibuffer_warps_control_Signals_wxd_o;sample.expected_ibuffer_warps_control_Signals_wxd_o=vif.expected_ibuffer_warps_control_Signals_wxd_o;
                sample.actual_ibuffer_warps_control_Signals_pc_o=vif.ibuffer_warps_control_Signals_pc_o;sample.expected_ibuffer_warps_control_Signals_pc_o=vif.expected_ibuffer_warps_control_Signals_pc_o;
                sample.actual_ibuffer_warps_control_Signals_imm_ext_o=vif.ibuffer_warps_control_Signals_imm_ext_o;sample.expected_ibuffer_warps_control_Signals_imm_ext_o=vif.expected_ibuffer_warps_control_Signals_imm_ext_o;
                sample.actual_ibuffer_warps_control_Signals_atomic_o=vif.ibuffer_warps_control_Signals_atomic_o;sample.expected_ibuffer_warps_control_Signals_atomic_o=vif.expected_ibuffer_warps_control_Signals_atomic_o;
                sample.actual_ibuffer_warps_control_Signals_aq_o=vif.ibuffer_warps_control_Signals_aq_o;sample.expected_ibuffer_warps_control_Signals_aq_o=vif.expected_ibuffer_warps_control_Signals_aq_o;
                sample.actual_ibuffer_warps_control_Signals_rl_o=vif.ibuffer_warps_control_Signals_rl_o;sample.expected_ibuffer_warps_control_Signals_rl_o=vif.expected_ibuffer_warps_control_Signals_rl_o;
                sample.actual_ibuffer_warps_control_Signals_rm_o=vif.ibuffer_warps_control_Signals_rm_o;sample.expected_ibuffer_warps_control_Signals_rm_o=vif.expected_ibuffer_warps_control_Signals_rm_o;
                sample.actual_ibuffer_warps_control_Signals_rm_is_static_o=vif.ibuffer_warps_control_Signals_rm_is_static_o;sample.expected_ibuffer_warps_control_Signals_rm_is_static_o=vif.expected_ibuffer_warps_control_Signals_rm_is_static_o;

                sample.asynchronous_reset=asynchronous_reset;
                samples.write(sample);
            end
        endtask
        task run_phase(uvm_phase phase);
            fork
                forever begin @(posedge vif.clk);sample_ports(0);end
                forever begin @(negedge vif.rst_n);sample_ports(1);end
            join
        endtask
    endclass
    class ibuf_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(ibuf_scoreboard)
        virtual ibuf_if vif;
        uvm_analysis_imp #(ibuf_sample,ibuf_scoreboard) samples;
        int unsigned checks,failures,reset_checks;
        function new(string name,uvm_component parent);super.new(name,parent);samples=new("samples",this);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual ibuf_if)::get(this,"","vif",vif))`uvm_fatal("CONFIG","Missing scoreboard interface")
        endfunction
        function void write(ibuf_sample sample);
            bit mismatch=0;
            reset_checks+=sample.asynchronous_reset;
            checks++;if(sample.actual_ibuffer_in_ready_o!==sample.expected_ibuffer_in_ready_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_in_ready_o=%h/%h async_reset=%b",sample.actual_ibuffer_in_ready_o,sample.expected_ibuffer_in_ready_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_ready_o!==sample.expected_ibuffer_ready_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_ready_o=%h/%h async_reset=%b",sample.actual_ibuffer_ready_o,sample.expected_ibuffer_ready_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_out_valid_o!==sample.expected_ibuffer_out_valid_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_out_valid_o=%h/%h async_reset=%b",sample.actual_ibuffer_out_valid_o,sample.expected_ibuffer_out_valid_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_inst_o!==sample.expected_ibuffer_warps_control_Signals_inst_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_inst_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_inst_o,sample.expected_ibuffer_warps_control_Signals_inst_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_wid_o!==sample.expected_ibuffer_warps_control_Signals_wid_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_wid_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_wid_o,sample.expected_ibuffer_warps_control_Signals_wid_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_fp_o!==sample.expected_ibuffer_warps_control_Signals_fp_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_fp_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_fp_o,sample.expected_ibuffer_warps_control_Signals_fp_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_branch_o!==sample.expected_ibuffer_warps_control_Signals_branch_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_branch_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_branch_o,sample.expected_ibuffer_warps_control_Signals_branch_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_simt_stack_o!==sample.expected_ibuffer_warps_control_Signals_simt_stack_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_simt_stack_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_simt_stack_o,sample.expected_ibuffer_warps_control_Signals_simt_stack_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_simt_stack_op_o!==sample.expected_ibuffer_warps_control_Signals_simt_stack_op_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_simt_stack_op_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_simt_stack_op_o,sample.expected_ibuffer_warps_control_Signals_simt_stack_op_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_barrier_o!==sample.expected_ibuffer_warps_control_Signals_barrier_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_barrier_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_barrier_o,sample.expected_ibuffer_warps_control_Signals_barrier_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_csr_o!==sample.expected_ibuffer_warps_control_Signals_csr_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_csr_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_csr_o,sample.expected_ibuffer_warps_control_Signals_csr_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_reverse_o!==sample.expected_ibuffer_warps_control_Signals_reverse_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_reverse_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_reverse_o,sample.expected_ibuffer_warps_control_Signals_reverse_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_sel_alu2_o!==sample.expected_ibuffer_warps_control_Signals_sel_alu2_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_sel_alu2_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_sel_alu2_o,sample.expected_ibuffer_warps_control_Signals_sel_alu2_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_sel_alu1_o!==sample.expected_ibuffer_warps_control_Signals_sel_alu1_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_sel_alu1_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_sel_alu1_o,sample.expected_ibuffer_warps_control_Signals_sel_alu1_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_sel_alu3_o!==sample.expected_ibuffer_warps_control_Signals_sel_alu3_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_sel_alu3_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_sel_alu3_o,sample.expected_ibuffer_warps_control_Signals_sel_alu3_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_isvec_o!==sample.expected_ibuffer_warps_control_Signals_isvec_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_isvec_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_isvec_o,sample.expected_ibuffer_warps_control_Signals_isvec_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_mask_o!==sample.expected_ibuffer_warps_control_Signals_mask_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_mask_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_mask_o,sample.expected_ibuffer_warps_control_Signals_mask_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_sel_imm_o!==sample.expected_ibuffer_warps_control_Signals_sel_imm_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_sel_imm_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_sel_imm_o,sample.expected_ibuffer_warps_control_Signals_sel_imm_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_mem_whb_o!==sample.expected_ibuffer_warps_control_Signals_mem_whb_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_mem_whb_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_mem_whb_o,sample.expected_ibuffer_warps_control_Signals_mem_whb_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_mem_unsigned_o!==sample.expected_ibuffer_warps_control_Signals_mem_unsigned_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_mem_unsigned_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_mem_unsigned_o,sample.expected_ibuffer_warps_control_Signals_mem_unsigned_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_alu_fn_o!==sample.expected_ibuffer_warps_control_Signals_alu_fn_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_alu_fn_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_alu_fn_o,sample.expected_ibuffer_warps_control_Signals_alu_fn_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_force_rm_rtz_o!==sample.expected_ibuffer_warps_control_Signals_force_rm_rtz_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_force_rm_rtz_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_force_rm_rtz_o,sample.expected_ibuffer_warps_control_Signals_force_rm_rtz_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_is_vls12_o!==sample.expected_ibuffer_warps_control_Signals_is_vls12_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_is_vls12_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_is_vls12_o,sample.expected_ibuffer_warps_control_Signals_is_vls12_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_mem_o!==sample.expected_ibuffer_warps_control_Signals_mem_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_mem_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_mem_o,sample.expected_ibuffer_warps_control_Signals_mem_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_mul_o!==sample.expected_ibuffer_warps_control_Signals_mul_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_mul_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_mul_o,sample.expected_ibuffer_warps_control_Signals_mul_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_tc_o!==sample.expected_ibuffer_warps_control_Signals_tc_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_tc_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_tc_o,sample.expected_ibuffer_warps_control_Signals_tc_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_disable_mask_o!==sample.expected_ibuffer_warps_control_Signals_disable_mask_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_disable_mask_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_disable_mask_o,sample.expected_ibuffer_warps_control_Signals_disable_mask_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_custom_signal_0_o!==sample.expected_ibuffer_warps_control_Signals_custom_signal_0_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_custom_signal_0_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_custom_signal_0_o,sample.expected_ibuffer_warps_control_Signals_custom_signal_0_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_mem_cmd_o!==sample.expected_ibuffer_warps_control_Signals_mem_cmd_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_mem_cmd_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_mem_cmd_o,sample.expected_ibuffer_warps_control_Signals_mem_cmd_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_mop_o!==sample.expected_ibuffer_warps_control_Signals_mop_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_mop_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_mop_o,sample.expected_ibuffer_warps_control_Signals_mop_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_reg_idx1_o!==sample.expected_ibuffer_warps_control_Signals_reg_idx1_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_reg_idx1_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_reg_idx1_o,sample.expected_ibuffer_warps_control_Signals_reg_idx1_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_reg_idx2_o!==sample.expected_ibuffer_warps_control_Signals_reg_idx2_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_reg_idx2_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_reg_idx2_o,sample.expected_ibuffer_warps_control_Signals_reg_idx2_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_reg_idx3_o!==sample.expected_ibuffer_warps_control_Signals_reg_idx3_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_reg_idx3_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_reg_idx3_o,sample.expected_ibuffer_warps_control_Signals_reg_idx3_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_reg_idxw_o!==sample.expected_ibuffer_warps_control_Signals_reg_idxw_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_reg_idxw_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_reg_idxw_o,sample.expected_ibuffer_warps_control_Signals_reg_idxw_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_wvd_o!==sample.expected_ibuffer_warps_control_Signals_wvd_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_wvd_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_wvd_o,sample.expected_ibuffer_warps_control_Signals_wvd_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_fence_o!==sample.expected_ibuffer_warps_control_Signals_fence_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_fence_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_fence_o,sample.expected_ibuffer_warps_control_Signals_fence_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_sfu_o!==sample.expected_ibuffer_warps_control_Signals_sfu_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_sfu_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_sfu_o,sample.expected_ibuffer_warps_control_Signals_sfu_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_readmask_o!==sample.expected_ibuffer_warps_control_Signals_readmask_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_readmask_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_readmask_o,sample.expected_ibuffer_warps_control_Signals_readmask_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_wxd_o!==sample.expected_ibuffer_warps_control_Signals_wxd_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_wxd_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_wxd_o,sample.expected_ibuffer_warps_control_Signals_wxd_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_pc_o!==sample.expected_ibuffer_warps_control_Signals_pc_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_pc_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_pc_o,sample.expected_ibuffer_warps_control_Signals_pc_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_imm_ext_o!==sample.expected_ibuffer_warps_control_Signals_imm_ext_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_imm_ext_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_imm_ext_o,sample.expected_ibuffer_warps_control_Signals_imm_ext_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_atomic_o!==sample.expected_ibuffer_warps_control_Signals_atomic_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_atomic_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_atomic_o,sample.expected_ibuffer_warps_control_Signals_atomic_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_aq_o!==sample.expected_ibuffer_warps_control_Signals_aq_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_aq_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_aq_o,sample.expected_ibuffer_warps_control_Signals_aq_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_rl_o!==sample.expected_ibuffer_warps_control_Signals_rl_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_rl_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_rl_o,sample.expected_ibuffer_warps_control_Signals_rl_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_rm_o!==sample.expected_ibuffer_warps_control_Signals_rm_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_rm_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_rm_o,sample.expected_ibuffer_warps_control_Signals_rm_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_ibuffer_warps_control_Signals_rm_is_static_o!==sample.expected_ibuffer_warps_control_Signals_rm_is_static_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("ibuffer_warps_control_Signals_rm_is_static_o=%h/%h async_reset=%b",sample.actual_ibuffer_warps_control_Signals_rm_is_static_o,sample.expected_ibuffer_warps_control_Signals_rm_is_static_o,sample.asynchronous_reset))end

            if(mismatch)begin
                failures++;
                vif.stop_requested=1;
            end
        endfunction
        function void check_phase(uvm_phase phase);
            super.check_phase(phase);
            if(failures==0 && (checks<300000 || reset_checks<4))`uvm_error("VACUOUS","Required comparison windows did not execute")
            if(failures>20)`uvm_error("MISMATCH_TOTAL",$sformatf("Total failed samples=%0d",failures))
        endfunction
    endclass
    class ibuf_env extends uvm_env;
        `uvm_component_utils(ibuf_env)
        uvm_sequencer #(ibuf_item) sequencer;
        ibuf_driver driver;
        ibuf_monitor monitor;
        ibuf_scoreboard scoreboard;
        function new(string name,uvm_component parent);super.new(name,parent);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sequencer=uvm_sequencer#(ibuf_item)::type_id::create("sequencer",this);
            driver=ibuf_driver::type_id::create("driver",this);
            monitor=ibuf_monitor::type_id::create("monitor",this);
            scoreboard=ibuf_scoreboard::type_id::create("scoreboard",this);
        endfunction
        function void connect_phase(uvm_phase phase);
            driver.seq_item_port.connect(sequencer.seq_item_export);
            monitor.samples.connect(scoreboard.samples);
        endfunction
    endclass
    class dvbench_test extends uvm_test;
        `uvm_component_utils(dvbench_test)
        ibuf_env env;
        function new(string name,uvm_component parent);super.new(name,parent);endfunction
        function void build_phase(uvm_phase phase);super.build_phase(phase);env=ibuf_env::type_id::create("env",this);endfunction
        task run_phase(uvm_phase phase);
            ibuf_sequence sequence_instance=ibuf_sequence::type_id::create("sequence_instance");
            phase.raise_objection(this);sequence_instance.start(env.sequencer);#20;phase.drop_objection(this);
        endtask
        function void report_phase(uvm_phase phase);
            uvm_report_server server=uvm_report_server::get_server();
            super.report_phase(phase);
            `uvm_info("CHECK_COUNTS",$sformatf("checks=%0d failures=%0d reset_checks=%0d",env.scoreboard.checks,env.scoreboard.failures,env.scoreboard.reset_checks),UVM_NONE)
            if(server.get_severity_count(UVM_ERROR)==0 && server.get_severity_count(UVM_FATAL)==0)$display("DVBench_COMPLETED");
        endfunction
    endclass
endpackage
