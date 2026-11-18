`timescale 1ns/1ps
package csr_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class csr_item extends uvm_sequence_item;
        `uvm_object_utils(csr_item)
        bit reset_request,short_reset_request;
        bit [31:0] ctrl_inst_i;
        bit [1:0] ctrl_csr_i;
        bit ctrl_custom_signal_0_i;
        bit ctrl_isvec_i;
        bit [7:0] ctrl_reg_idxw_i;
        bit ctrl_wxd_i;
        bit [2:0] ctrl_wid_i;
        bit in_valid_i;
        bit out_ready_i;
        bit [31:0] in1_i;
        bit [8:0] rm_wid_i;
        bit [2:0] lsu_wid_i;
        bit [2:0] simt_wid_i;
        bit CTA2csr_valid_i;
        bit [3:0] dispatch2cu_wg_wf_count_i;
        bit [9:0] dispatch2cu_wf_size_dispatch_i;
        bit [10:0] dispatch2cu_sgpr_base_dispatch_i;
        bit [10:0] dispatch2cu_vgpr_base_dispatch_i;
        bit [6:0] dispatch2cu_wf_tag_dispatch_i;
        bit [17:0] dispatch2cu_lds_base_dispatch_i;
        bit [31:0] dispatch2cu_pds_base_dispatch_i;
        bit [31:0] dispatch2cu_csr_knl_dispatch_i;
        bit [9:0] dispatch2cu_wgid_x_dispatch_i;
        bit [9:0] dispatch2cu_wgid_y_dispatch_i;
        bit [9:0] dispatch2cu_wgid_z_dispatch_i;
        bit [31:0] dispatch2cu_wg_id_i;
        bit [2:0] wid_i;

        function new(string name="csr_item");super.new(name);endfunction
    endclass
    class csr_sequence extends uvm_sequence #(csr_item);
        `uvm_object_utils(csr_sequence)
        virtual csr_if vif;
        function new(string name="csr_sequence");super.new(name);endfunction
        task send_reset();
            csr_item item=csr_item::type_id::create("reset");
            if(vif.stop_requested)return;
            start_item(item);item.reset_request=1;finish_item(item);
        endtask
        task send(bit [11:0] address,bit [2:0] bank,bit [1:0] operation,bit [31:0] value,bit randomized);
            csr_item item=csr_item::type_id::create("operation");
            if(vif.stop_requested)return;
            start_item(item);
            item.ctrl_inst_i=$urandom;
            item.ctrl_csr_i=$urandom;
            item.ctrl_custom_signal_0_i=$urandom;
            item.ctrl_isvec_i=$urandom;
            item.ctrl_reg_idxw_i=$urandom;
            item.ctrl_wxd_i=$urandom;
            item.ctrl_wid_i=$urandom;
            item.in_valid_i=$urandom;
            item.out_ready_i=$urandom;
            item.in1_i=$urandom;
            item.rm_wid_i=$urandom;
            item.lsu_wid_i=$urandom;
            item.simt_wid_i=$urandom;
            item.CTA2csr_valid_i=$urandom;
            item.dispatch2cu_wg_wf_count_i=$urandom;
            item.dispatch2cu_wf_size_dispatch_i=$urandom;
            item.dispatch2cu_sgpr_base_dispatch_i=$urandom;
            item.dispatch2cu_vgpr_base_dispatch_i=$urandom;
            item.dispatch2cu_wf_tag_dispatch_i=$urandom;
            item.dispatch2cu_lds_base_dispatch_i=$urandom;
            item.dispatch2cu_pds_base_dispatch_i=$urandom;
            item.dispatch2cu_csr_knl_dispatch_i=$urandom;
            item.dispatch2cu_wgid_x_dispatch_i=$urandom;
            item.dispatch2cu_wgid_y_dispatch_i=$urandom;
            item.dispatch2cu_wgid_z_dispatch_i=$urandom;
            item.dispatch2cu_wg_id_i=$urandom;
            item.wid_i=$urandom;
            item.ctrl_inst_i[31:20]=address;item.ctrl_wid_i=bank;item.ctrl_csr_i=operation;item.in1_i=value;
            if(!randomized)begin item.CTA2csr_valid_i=0;item.in_valid_i=1;item.out_ready_i=1;item.ctrl_custom_signal_0_i=0;item.ctrl_isvec_i=0;end
            finish_item(item);
        endtask
        task send_short_reset();
            csr_item item=csr_item::type_id::create("short_reset");
            if(vif.stop_requested)return;
            start_item(item);item.reset_request=1;item.short_reset_request=1;finish_item(item);
        endtask

        task body();
            int unsigned random_value;
            if(!uvm_config_db#(virtual csr_if)::get(null,"","vif",vif))`uvm_fatal("CONFIG","Missing sequence interface")
            send_reset();
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'h300,bank,operation,32'hffffffff,0);send(12'h300,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'h304,bank,operation,32'hffffffff,0);send(12'h304,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'h305,bank,operation,32'hffffffff,0);send(12'h305,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'h340,bank,operation,32'hffffffff,0);send(12'h340,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'h341,bank,operation,32'hffffffff,0);send(12'h341,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'h342,bank,operation,32'hffffffff,0);send(12'h342,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'h343,bank,operation,32'hffffffff,0);send(12'h343,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'h344,bank,operation,32'hffffffff,0);send(12'h344,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'h001,bank,operation,32'hffffffff,0);send(12'h001,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'h002,bank,operation,32'hffffffff,0);send(12'h002,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'h003,bank,operation,32'hffffffff,0);send(12'h003,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'hc21,bank,operation,32'hffffffff,0);send(12'hc21,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'h800,bank,operation,32'hffffffff,0);send(12'h800,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'h801,bank,operation,32'hffffffff,0);send(12'h801,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'h802,bank,operation,32'hffffffff,0);send(12'h802,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'h803,bank,operation,32'hffffffff,0);send(12'h803,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'h804,bank,operation,32'hffffffff,0);send(12'h804,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'h805,bank,operation,32'hffffffff,0);send(12'h805,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'h806,bank,operation,32'hffffffff,0);send(12'h806,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'h807,bank,operation,32'hffffffff,0);send(12'h807,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'h808,bank,operation,32'hffffffff,0);send(12'h808,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'h809,bank,operation,32'hffffffff,0);send(12'h809,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'h80a,bank,operation,32'hffffffff,0);send(12'h80a,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'h80b,bank,operation,32'hffffffff,0);send(12'h80b,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'h80c,bank,operation,32'hffffffff,0);send(12'h80c,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'h000,bank,operation,32'hffffffff,0);send(12'h000,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'hfff,bank,operation,32'hffffffff,0);send(12'hfff,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'hc20,bank,operation,32'hffffffff,0);send(12'hc20,bank,0,0,0);end
            for(int bank=0;bank<8;bank++)for(int operation=0;operation<4;operation++)begin send(12'hc22,bank,operation,32'hffffffff,0);send(12'hc22,bank,0,0,0);end
            send(12'h340,0,1,32'h13579bdf,0);send(12'h340,0,0,0,0);send_short_reset();send(12'h340,0,0,0,0);
            for(int iteration=0;iteration<7000;iteration++)begin
                bit [11:0] address;
                case(iteration%29)
                    0:address=12'h300;
                    1:address=12'h304;
                    2:address=12'h305;
                    3:address=12'h340;
                    4:address=12'h341;
                    5:address=12'h342;
                    6:address=12'h343;
                    7:address=12'h344;
                    8:address=12'h001;
                    9:address=12'h002;
                    10:address=12'h003;
                    11:address=12'hc21;
                    12:address=12'h800;
                    13:address=12'h801;
                    14:address=12'h802;
                    15:address=12'h803;
                    16:address=12'h804;
                    17:address=12'h805;
                    18:address=12'h806;
                    19:address=12'h807;
                    20:address=12'h808;
                    21:address=12'h809;
                    22:address=12'h80a;
                    23:address=12'h80b;
                    24:address=12'h80c;
                    25:address=12'h000;
                    26:address=12'hfff;
                    27:address=12'hc20;
                    28:address=12'hc22;
                endcase
                random_value=$urandom;send(address,random_value[2:0],random_value[4:3],$urandom,1);
                if(iteration==711||iteration==4301)send_reset();
            end
            send_reset();
            repeat(10)send(0,0,0,0,0);

        endtask
    endclass
    class csr_driver extends uvm_driver #(csr_item);
        `uvm_component_utils(csr_driver)
        virtual csr_if vif;
        function new(string name,uvm_component parent);super.new(name,parent);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual csr_if)::get(this,"","vif",vif))`uvm_fatal("CONFIG","Missing driver interface")
        endfunction
        task run_phase(uvm_phase phase);
            csr_item item;
            forever begin
                seq_item_port.get_next_item(item);
                @(negedge vif.clk);
                if(item.reset_request)begin
                    vif.checking=1;
                    #2 vif.rst_n=0;
                    if(item.short_reset_request)begin #2;vif.rst_n=1;end
                    else begin repeat(3)@(posedge vif.clk);@(negedge vif.clk);vif.rst_n=1;end
                end else begin
                    vif.ctrl_inst_i=item.ctrl_inst_i;
                    vif.ctrl_csr_i=item.ctrl_csr_i;
                    vif.ctrl_custom_signal_0_i=item.ctrl_custom_signal_0_i;
                    vif.ctrl_isvec_i=item.ctrl_isvec_i;
                    vif.ctrl_reg_idxw_i=item.ctrl_reg_idxw_i;
                    vif.ctrl_wxd_i=item.ctrl_wxd_i;
                    vif.ctrl_wid_i=item.ctrl_wid_i;
                    vif.in_valid_i=item.in_valid_i;
                    vif.out_ready_i=item.out_ready_i;
                    vif.in1_i=item.in1_i;
                    vif.rm_wid_i=item.rm_wid_i;
                    vif.lsu_wid_i=item.lsu_wid_i;
                    vif.simt_wid_i=item.simt_wid_i;
                    vif.CTA2csr_valid_i=item.CTA2csr_valid_i;
                    vif.dispatch2cu_wg_wf_count_i=item.dispatch2cu_wg_wf_count_i;
                    vif.dispatch2cu_wf_size_dispatch_i=item.dispatch2cu_wf_size_dispatch_i;
                    vif.dispatch2cu_sgpr_base_dispatch_i=item.dispatch2cu_sgpr_base_dispatch_i;
                    vif.dispatch2cu_vgpr_base_dispatch_i=item.dispatch2cu_vgpr_base_dispatch_i;
                    vif.dispatch2cu_wf_tag_dispatch_i=item.dispatch2cu_wf_tag_dispatch_i;
                    vif.dispatch2cu_lds_base_dispatch_i=item.dispatch2cu_lds_base_dispatch_i;
                    vif.dispatch2cu_pds_base_dispatch_i=item.dispatch2cu_pds_base_dispatch_i;
                    vif.dispatch2cu_csr_knl_dispatch_i=item.dispatch2cu_csr_knl_dispatch_i;
                    vif.dispatch2cu_wgid_x_dispatch_i=item.dispatch2cu_wgid_x_dispatch_i;
                    vif.dispatch2cu_wgid_y_dispatch_i=item.dispatch2cu_wgid_y_dispatch_i;
                    vif.dispatch2cu_wgid_z_dispatch_i=item.dispatch2cu_wgid_z_dispatch_i;
                    vif.dispatch2cu_wg_id_i=item.dispatch2cu_wg_id_i;
                    vif.wid_i=item.wid_i;

                    @(posedge vif.clk);#2;
                end
                seq_item_port.item_done();
            end
        endtask
    endclass
    class csr_sample extends uvm_sequence_item;
        `uvm_object_utils(csr_sample)
        logic actual_in_ready_o;
        logic expected_in_ready_o;
        logic actual_out_valid_o;
        logic expected_out_valid_o;
        logic [31:0] actual_wb_wxd_rd_o;
        logic [31:0] expected_wb_wxd_rd_o;
        logic actual_wxd_o;
        logic expected_wxd_o;
        logic [7:0] actual_reg_idxw_o;
        logic [7:0] expected_reg_idxw_o;
        logic [2:0] actual_warp_id_o;
        logic [2:0] expected_warp_id_o;
        logic [8:0] actual_rm_o;
        logic [8:0] expected_rm_o;
        logic [87:0] actual_sgpr_base_o;
        logic [87:0] expected_sgpr_base_o;
        logic [87:0] actual_vgpr_base_o;
        logic [87:0] expected_vgpr_base_o;
        logic [31:0] actual_lsu_tid_o;
        logic [31:0] expected_lsu_tid_o;
        logic [31:0] actual_lsu_pds_o;
        logic [31:0] expected_lsu_pds_o;
        logic [31:0] actual_lsu_numw_o;
        logic [31:0] expected_lsu_numw_o;
        logic [31:0] actual_simt_rpc_o;
        logic [31:0] expected_simt_rpc_o;

        bit asynchronous_reset;
        function new(string name="csr_sample");super.new(name);endfunction
    endclass
    class csr_monitor extends uvm_monitor;
        `uvm_component_utils(csr_monitor)
        virtual csr_if vif;
        uvm_analysis_port #(csr_sample) samples;
        function new(string name,uvm_component parent);super.new(name,parent);samples=new("samples",this);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual csr_if)::get(this,"","vif",vif))`uvm_fatal("CONFIG","Missing monitor interface")
        endfunction
        task sample_ports(bit asynchronous_reset);
            csr_sample sample=csr_sample::type_id::create("sample");
            #1;
            if(vif.checking)begin
                sample.actual_in_ready_o=vif.in_ready_o;sample.expected_in_ready_o=vif.expected_in_ready_o;
                sample.actual_out_valid_o=vif.out_valid_o;sample.expected_out_valid_o=vif.expected_out_valid_o;
                sample.actual_wb_wxd_rd_o=vif.wb_wxd_rd_o;sample.expected_wb_wxd_rd_o=vif.expected_wb_wxd_rd_o;
                sample.actual_wxd_o=vif.wxd_o;sample.expected_wxd_o=vif.expected_wxd_o;
                sample.actual_reg_idxw_o=vif.reg_idxw_o;sample.expected_reg_idxw_o=vif.expected_reg_idxw_o;
                sample.actual_warp_id_o=vif.warp_id_o;sample.expected_warp_id_o=vif.expected_warp_id_o;
                sample.actual_rm_o=vif.rm_o;sample.expected_rm_o=vif.expected_rm_o;
                sample.actual_sgpr_base_o=vif.sgpr_base_o;sample.expected_sgpr_base_o=vif.expected_sgpr_base_o;
                sample.actual_vgpr_base_o=vif.vgpr_base_o;sample.expected_vgpr_base_o=vif.expected_vgpr_base_o;
                sample.actual_lsu_tid_o=vif.lsu_tid_o;sample.expected_lsu_tid_o=vif.expected_lsu_tid_o;
                sample.actual_lsu_pds_o=vif.lsu_pds_o;sample.expected_lsu_pds_o=vif.expected_lsu_pds_o;
                sample.actual_lsu_numw_o=vif.lsu_numw_o;sample.expected_lsu_numw_o=vif.expected_lsu_numw_o;
                sample.actual_simt_rpc_o=vif.simt_rpc_o;sample.expected_simt_rpc_o=vif.expected_simt_rpc_o;

                sample.asynchronous_reset=asynchronous_reset;
                samples.write(sample);
            end
        endtask
        task run_phase(uvm_phase phase);
            fork
                forever begin @(posedge vif.clk);sample_ports(0);end
                forever begin @(negedge vif.rst_n);sample_ports(1);end
                forever begin @(vif.rm_wid_i or vif.lsu_wid_i or vif.simt_wid_i);sample_ports(0);end
            join
        endtask
    endclass
    class csr_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(csr_scoreboard)
        virtual csr_if vif;
        uvm_analysis_imp #(csr_sample,csr_scoreboard) samples;
        int unsigned checks,failures,reset_checks;
        function new(string name,uvm_component parent);super.new(name,parent);samples=new("samples",this);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual csr_if)::get(this,"","vif",vif))`uvm_fatal("CONFIG","Missing scoreboard interface")
        endfunction
        function void write(csr_sample sample);
            bit mismatch=0;
            reset_checks+=sample.asynchronous_reset;
            checks++;if(sample.actual_in_ready_o!==sample.expected_in_ready_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("in_ready_o=%h/%h async_reset=%b",sample.actual_in_ready_o,sample.expected_in_ready_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_out_valid_o!==sample.expected_out_valid_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("out_valid_o=%h/%h async_reset=%b",sample.actual_out_valid_o,sample.expected_out_valid_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_wb_wxd_rd_o!==sample.expected_wb_wxd_rd_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("wb_wxd_rd_o=%h/%h async_reset=%b",sample.actual_wb_wxd_rd_o,sample.expected_wb_wxd_rd_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_wxd_o!==sample.expected_wxd_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("wxd_o=%h/%h async_reset=%b",sample.actual_wxd_o,sample.expected_wxd_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_reg_idxw_o!==sample.expected_reg_idxw_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("reg_idxw_o=%h/%h async_reset=%b",sample.actual_reg_idxw_o,sample.expected_reg_idxw_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_warp_id_o!==sample.expected_warp_id_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("warp_id_o=%h/%h async_reset=%b",sample.actual_warp_id_o,sample.expected_warp_id_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_rm_o!==sample.expected_rm_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("rm_o=%h/%h async_reset=%b",sample.actual_rm_o,sample.expected_rm_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_sgpr_base_o!==sample.expected_sgpr_base_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("sgpr_base_o=%h/%h async_reset=%b",sample.actual_sgpr_base_o,sample.expected_sgpr_base_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_vgpr_base_o!==sample.expected_vgpr_base_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("vgpr_base_o=%h/%h async_reset=%b",sample.actual_vgpr_base_o,sample.expected_vgpr_base_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_lsu_tid_o!==sample.expected_lsu_tid_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("lsu_tid_o=%h/%h async_reset=%b",sample.actual_lsu_tid_o,sample.expected_lsu_tid_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_lsu_pds_o!==sample.expected_lsu_pds_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("lsu_pds_o=%h/%h async_reset=%b",sample.actual_lsu_pds_o,sample.expected_lsu_pds_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_lsu_numw_o!==sample.expected_lsu_numw_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("lsu_numw_o=%h/%h async_reset=%b",sample.actual_lsu_numw_o,sample.expected_lsu_numw_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_simt_rpc_o!==sample.expected_simt_rpc_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("simt_rpc_o=%h/%h async_reset=%b",sample.actual_simt_rpc_o,sample.expected_simt_rpc_o,sample.asynchronous_reset))end

            if(mismatch)begin
                failures++;
                vif.stop_requested=1;
            end
        endfunction
        function void check_phase(uvm_phase phase);
            super.check_phase(phase);
            if(failures==0 && (checks<100000 || reset_checks<4))`uvm_error("VACUOUS","Required comparison windows did not execute")
            if(failures>20)`uvm_error("MISMATCH_TOTAL",$sformatf("Total failed samples=%0d",failures))
        endfunction
    endclass
    class csr_env extends uvm_env;
        `uvm_component_utils(csr_env)
        uvm_sequencer #(csr_item) sequencer;
        csr_driver driver;
        csr_monitor monitor;
        csr_scoreboard scoreboard;
        function new(string name,uvm_component parent);super.new(name,parent);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sequencer=uvm_sequencer#(csr_item)::type_id::create("sequencer",this);
            driver=csr_driver::type_id::create("driver",this);
            monitor=csr_monitor::type_id::create("monitor",this);
            scoreboard=csr_scoreboard::type_id::create("scoreboard",this);
        endfunction
        function void connect_phase(uvm_phase phase);
            driver.seq_item_port.connect(sequencer.seq_item_export);
            monitor.samples.connect(scoreboard.samples);
        endfunction
    endclass
    class dvbench_test extends uvm_test;
        `uvm_component_utils(dvbench_test)
        csr_env env;
        function new(string name,uvm_component parent);super.new(name,parent);endfunction
        function void build_phase(uvm_phase phase);super.build_phase(phase);env=csr_env::type_id::create("env",this);endfunction
        task run_phase(uvm_phase phase);
            csr_sequence sequence_instance=csr_sequence::type_id::create("sequence_instance");
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
