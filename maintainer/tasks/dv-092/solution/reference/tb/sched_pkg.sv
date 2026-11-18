`timescale 1ns/1ps
package sched_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class sched_item extends uvm_sequence_item;
        `uvm_object_utils(sched_item)
        bit reset_request,short_reset_request;
        bit warpReq_valid_i;
        bit [6:0] warpReq_dispatch2cu_wf_tag_dispatch_i;
        bit [2:0] warpReq_wid_i;
        bit [31:0] warpReq_dispatch2cu_start_pc_dispatch_i;
        bit warpRsp_ready_i;
        bit [6:0] wg_id_tag_i;
        bit pc_rsp_valid_i;
        bit [31:0] pc_rsp_addr_i;
        bit [1:0] pc_rsp_mask_i;
        bit [2:0] pc_rsp_wid_i;
        bit pc_rsp_status_i;
        bit branch_valid_i;
        bit [2:0] branch_wid_i;
        bit branch_jump_i;
        bit [31:0] branch_new_pc_i;
        bit warp_control_valid_i;
        bit warp_control_simt_stack_op_i;
        bit [2:0] warp_control_wid_i;
        bit [7:0] scoreboard_busy_i;
        bit [7:0] ibuffer_ready_i;

        function new(string name="sched_item");super.new(name);endfunction
    endclass
    class sched_sequence extends uvm_sequence #(sched_item);
        `uvm_object_utils(sched_sequence)
        virtual sched_if vif;
        function new(string name="sched_sequence");super.new(name);endfunction
        task send_reset();
            sched_item item=sched_item::type_id::create("reset");
            if(vif.stop_requested)return;
            start_item(item);item.reset_request=1;finish_item(item);
        endtask
        task send(bit [2:0] bank,bit [2:0] group_id,bit [31:0] start_address,bit dispatch,bit [7:0] buffer_ready,bit randomized);
            sched_item item=sched_item::type_id::create("scheduler_operation");
            if(vif.stop_requested)return;
            start_item(item);
            item.warpReq_valid_i=$urandom;
            item.warpReq_dispatch2cu_wf_tag_dispatch_i=$urandom;
            item.warpReq_wid_i=$urandom;
            item.warpReq_dispatch2cu_start_pc_dispatch_i=$urandom;
            item.warpRsp_ready_i=$urandom;
            item.wg_id_tag_i=$urandom;
            item.pc_rsp_valid_i=$urandom;
            item.pc_rsp_addr_i=$urandom;
            item.pc_rsp_mask_i=$urandom;
            item.pc_rsp_wid_i=$urandom;
            item.pc_rsp_status_i=$urandom;
            item.branch_valid_i=$urandom;
            item.branch_wid_i=$urandom;
            item.branch_jump_i=$urandom;
            item.branch_new_pc_i=$urandom;
            item.warp_control_valid_i=$urandom;
            item.warp_control_simt_stack_op_i=$urandom;
            item.warp_control_wid_i=$urandom;
            item.scoreboard_busy_i=$urandom;
            item.ibuffer_ready_i=$urandom;
            if(!randomized)begin
                item.warpReq_valid_i=dispatch;item.warpReq_wid_i=bank;item.warpReq_dispatch2cu_wf_tag_dispatch_i={group_id,4'b1010};item.warpReq_dispatch2cu_start_pc_dispatch_i=start_address;
                item.pc_rsp_valid_i=0;item.branch_valid_i=0;item.warp_control_valid_i=0;item.ibuffer_ready_i=buffer_ready;item.wg_id_tag_i={group_id,4'b0101};
            end
            finish_item(item);
        endtask
        task barrier(bit [2:0] bank,bit [2:0] group_id,bit ending);
            sched_item item=sched_item::type_id::create("barrier_or_end");
            if(vif.stop_requested)return;
            start_item(item);item.warp_control_valid_i=1;item.warp_control_wid_i=bank;item.warp_control_simt_stack_op_i=ending;item.wg_id_tag_i={group_id,4'b0000};item.warpRsp_ready_i=1;finish_item(item);
        endtask
        task send_short_reset();
            sched_item item=sched_item::type_id::create("short_reset");
            if(vif.stop_requested)return;
            start_item(item);item.reset_request=1;item.short_reset_request=1;finish_item(item);
        endtask

        task body();
            int unsigned random_value;
            if(!uvm_config_db#(virtual sched_if)::get(null,"","vif",vif))`uvm_fatal("CONFIG","Missing sequence interface")
            send_reset();
            for(int bank=0;bank<8;bank++)for(int offset=0;offset<8;offset++)begin
                send(bank,bank,32'hfffffff8+offset,1,0,0);
                send(bank,bank,0,0,1<<bank,0);
            end
            send_reset();
            send(0,0,0,1,0,0);send(1,0,16,1,0,0);barrier(0,0,0);barrier(1,0,0);
            send_reset();
            send(0,0,0,1,0,0);send(0,0,0,0,0,0);send_short_reset();barrier(0,0,0);send(0,0,0,1,0,0);
            for(int iteration=0;iteration<10000;iteration++)begin
                send(0,0,0,0,0,1);
                if(iteration==831||iteration==4611)send_reset();
            end
            send_reset();
            repeat(10)send(0,0,0,0,0,0);

        endtask
    endclass
    class sched_driver extends uvm_driver #(sched_item);
        `uvm_component_utils(sched_driver)
        virtual sched_if vif;
        function new(string name,uvm_component parent);super.new(name,parent);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual sched_if)::get(this,"","vif",vif))`uvm_fatal("CONFIG","Missing driver interface")
        endfunction
        task run_phase(uvm_phase phase);
            sched_item item;
            forever begin
                seq_item_port.get_next_item(item);
                @(negedge vif.clk);
                if(item.reset_request)begin
                    vif.checking=1;
                    #2 vif.rst_n=0;
                    if(item.short_reset_request)begin #2;vif.rst_n=1;end
                    else begin repeat(3)@(posedge vif.clk);@(negedge vif.clk);vif.rst_n=1;end
                end else begin
                    vif.warpReq_valid_i=item.warpReq_valid_i;
                    vif.warpReq_dispatch2cu_wf_tag_dispatch_i=item.warpReq_dispatch2cu_wf_tag_dispatch_i;
                    vif.warpReq_wid_i=item.warpReq_wid_i;
                    vif.warpReq_dispatch2cu_start_pc_dispatch_i=item.warpReq_dispatch2cu_start_pc_dispatch_i;
                    vif.warpRsp_ready_i=item.warpRsp_ready_i;
                    vif.wg_id_tag_i=item.wg_id_tag_i;
                    vif.pc_rsp_valid_i=item.pc_rsp_valid_i;
                    vif.pc_rsp_addr_i=item.pc_rsp_addr_i;
                    vif.pc_rsp_mask_i=item.pc_rsp_mask_i;
                    vif.pc_rsp_wid_i=item.pc_rsp_wid_i;
                    vif.pc_rsp_status_i=item.pc_rsp_status_i;
                    vif.branch_valid_i=item.branch_valid_i;
                    vif.branch_wid_i=item.branch_wid_i;
                    vif.branch_jump_i=item.branch_jump_i;
                    vif.branch_new_pc_i=item.branch_new_pc_i;
                    vif.warp_control_valid_i=item.warp_control_valid_i;
                    vif.warp_control_simt_stack_op_i=item.warp_control_simt_stack_op_i;
                    vif.warp_control_wid_i=item.warp_control_wid_i;
                    vif.scoreboard_busy_i=item.scoreboard_busy_i;
                    vif.ibuffer_ready_i=item.ibuffer_ready_i;

                    @(posedge vif.clk);#2;
                end
                seq_item_port.item_done();
            end
        endtask
    endclass
    class sched_sample extends uvm_sequence_item;
        `uvm_object_utils(sched_sample)
        logic actual_warpRsp_valid_o;
        logic expected_warpRsp_valid_o;
        logic [2:0] actual_warpRsp_wid_o;
        logic [2:0] expected_warpRsp_wid_o;
        logic [2:0] actual_wg_id_lookup_o;
        logic [2:0] expected_wg_id_lookup_o;
        logic actual_pc_req_valid_o;
        logic expected_pc_req_valid_o;
        logic [31:0] actual_pc_req_addr_o;
        logic [31:0] expected_pc_req_addr_o;
        logic [1:0] actual_pc_req_mask_o;
        logic [1:0] expected_pc_req_mask_o;
        logic [2:0] actual_pc_req_wid_o;
        logic [2:0] expected_pc_req_wid_o;
        logic actual_branch_ready_o;
        logic expected_branch_ready_o;
        logic actual_warp_control_ready_o;
        logic expected_warp_control_ready_o;
        logic [7:0] actual_warp_ready_o;
        logic [7:0] expected_warp_ready_o;
        logic actual_flush_valid_o;
        logic expected_flush_valid_o;
        logic [2:0] actual_flush_wid_o;
        logic [2:0] expected_flush_wid_o;
        logic actual_flushCache_valid_o;
        logic expected_flushCache_valid_o;
        logic [2:0] actual_flushCache_wid_o;
        logic [2:0] expected_flushCache_wid_o;

        bit asynchronous_reset;
        function new(string name="sched_sample");super.new(name);endfunction
    endclass
    class sched_monitor extends uvm_monitor;
        `uvm_component_utils(sched_monitor)
        virtual sched_if vif;
        uvm_analysis_port #(sched_sample) samples;
        function new(string name,uvm_component parent);super.new(name,parent);samples=new("samples",this);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual sched_if)::get(this,"","vif",vif))`uvm_fatal("CONFIG","Missing monitor interface")
        endfunction
        task sample_ports(bit asynchronous_reset);
            sched_sample sample=sched_sample::type_id::create("sample");
            #1;
            if(vif.checking)begin
                sample.actual_warpRsp_valid_o=vif.warpRsp_valid_o;sample.expected_warpRsp_valid_o=vif.expected_warpRsp_valid_o;
                sample.actual_warpRsp_wid_o=vif.warpRsp_wid_o;sample.expected_warpRsp_wid_o=vif.expected_warpRsp_wid_o;
                sample.actual_wg_id_lookup_o=vif.wg_id_lookup_o;sample.expected_wg_id_lookup_o=vif.expected_wg_id_lookup_o;
                sample.actual_pc_req_valid_o=vif.pc_req_valid_o;sample.expected_pc_req_valid_o=vif.expected_pc_req_valid_o;
                sample.actual_pc_req_addr_o=vif.pc_req_addr_o;sample.expected_pc_req_addr_o=vif.expected_pc_req_addr_o;
                sample.actual_pc_req_mask_o=vif.pc_req_mask_o;sample.expected_pc_req_mask_o=vif.expected_pc_req_mask_o;
                sample.actual_pc_req_wid_o=vif.pc_req_wid_o;sample.expected_pc_req_wid_o=vif.expected_pc_req_wid_o;
                sample.actual_branch_ready_o=vif.branch_ready_o;sample.expected_branch_ready_o=vif.expected_branch_ready_o;
                sample.actual_warp_control_ready_o=vif.warp_control_ready_o;sample.expected_warp_control_ready_o=vif.expected_warp_control_ready_o;
                sample.actual_warp_ready_o=vif.warp_ready_o;sample.expected_warp_ready_o=vif.expected_warp_ready_o;
                sample.actual_flush_valid_o=vif.flush_valid_o;sample.expected_flush_valid_o=vif.expected_flush_valid_o;
                sample.actual_flush_wid_o=vif.flush_wid_o;sample.expected_flush_wid_o=vif.expected_flush_wid_o;
                sample.actual_flushCache_valid_o=vif.flushCache_valid_o;sample.expected_flushCache_valid_o=vif.expected_flushCache_valid_o;
                sample.actual_flushCache_wid_o=vif.flushCache_wid_o;sample.expected_flushCache_wid_o=vif.expected_flushCache_wid_o;

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
    class sched_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(sched_scoreboard)
        virtual sched_if vif;
        uvm_analysis_imp #(sched_sample,sched_scoreboard) samples;
        int unsigned checks,failures,reset_checks;
        function new(string name,uvm_component parent);super.new(name,parent);samples=new("samples",this);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual sched_if)::get(this,"","vif",vif))`uvm_fatal("CONFIG","Missing scoreboard interface")
        endfunction
        function void write(sched_sample sample);
            bit mismatch=0;
            reset_checks+=sample.asynchronous_reset;
            checks++;if(sample.actual_warpRsp_valid_o!==sample.expected_warpRsp_valid_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("warpRsp_valid_o=%h/%h async_reset=%b",sample.actual_warpRsp_valid_o,sample.expected_warpRsp_valid_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_warpRsp_wid_o!==sample.expected_warpRsp_wid_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("warpRsp_wid_o=%h/%h async_reset=%b",sample.actual_warpRsp_wid_o,sample.expected_warpRsp_wid_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_wg_id_lookup_o!==sample.expected_wg_id_lookup_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("wg_id_lookup_o=%h/%h async_reset=%b",sample.actual_wg_id_lookup_o,sample.expected_wg_id_lookup_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_pc_req_valid_o!==sample.expected_pc_req_valid_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("pc_req_valid_o=%h/%h async_reset=%b",sample.actual_pc_req_valid_o,sample.expected_pc_req_valid_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_pc_req_addr_o!==sample.expected_pc_req_addr_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("pc_req_addr_o=%h/%h async_reset=%b",sample.actual_pc_req_addr_o,sample.expected_pc_req_addr_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_pc_req_mask_o!==sample.expected_pc_req_mask_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("pc_req_mask_o=%h/%h async_reset=%b",sample.actual_pc_req_mask_o,sample.expected_pc_req_mask_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_pc_req_wid_o!==sample.expected_pc_req_wid_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("pc_req_wid_o=%h/%h async_reset=%b",sample.actual_pc_req_wid_o,sample.expected_pc_req_wid_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_branch_ready_o!==sample.expected_branch_ready_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("branch_ready_o=%h/%h async_reset=%b",sample.actual_branch_ready_o,sample.expected_branch_ready_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_warp_control_ready_o!==sample.expected_warp_control_ready_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("warp_control_ready_o=%h/%h async_reset=%b",sample.actual_warp_control_ready_o,sample.expected_warp_control_ready_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_warp_ready_o!==sample.expected_warp_ready_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("warp_ready_o=%h/%h async_reset=%b",sample.actual_warp_ready_o,sample.expected_warp_ready_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_flush_valid_o!==sample.expected_flush_valid_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("flush_valid_o=%h/%h async_reset=%b",sample.actual_flush_valid_o,sample.expected_flush_valid_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_flush_wid_o!==sample.expected_flush_wid_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("flush_wid_o=%h/%h async_reset=%b",sample.actual_flush_wid_o,sample.expected_flush_wid_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_flushCache_valid_o!==sample.expected_flushCache_valid_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("flushCache_valid_o=%h/%h async_reset=%b",sample.actual_flushCache_valid_o,sample.expected_flushCache_valid_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_flushCache_wid_o!==sample.expected_flushCache_wid_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("flushCache_wid_o=%h/%h async_reset=%b",sample.actual_flushCache_wid_o,sample.expected_flushCache_wid_o,sample.asynchronous_reset))end

            if(mismatch)begin
                failures++;
                vif.stop_requested=1;
            end
        endfunction
        function void check_phase(uvm_phase phase);
            super.check_phase(phase);
            if(failures==0 && (checks<140000 || reset_checks<4))`uvm_error("VACUOUS","Required comparison windows did not execute")
            if(failures>20)`uvm_error("MISMATCH_TOTAL",$sformatf("Total failed samples=%0d",failures))
        endfunction
    endclass
    class sched_env extends uvm_env;
        `uvm_component_utils(sched_env)
        uvm_sequencer #(sched_item) sequencer;
        sched_driver driver;
        sched_monitor monitor;
        sched_scoreboard scoreboard;
        function new(string name,uvm_component parent);super.new(name,parent);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sequencer=uvm_sequencer#(sched_item)::type_id::create("sequencer",this);
            driver=sched_driver::type_id::create("driver",this);
            monitor=sched_monitor::type_id::create("monitor",this);
            scoreboard=sched_scoreboard::type_id::create("scoreboard",this);
        endfunction
        function void connect_phase(uvm_phase phase);
            driver.seq_item_port.connect(sequencer.seq_item_export);
            monitor.samples.connect(scoreboard.samples);
        endfunction
    endclass
    class dvbench_test extends uvm_test;
        `uvm_component_utils(dvbench_test)
        sched_env env;
        function new(string name,uvm_component parent);super.new(name,parent);endfunction
        function void build_phase(uvm_phase phase);super.build_phase(phase);env=sched_env::type_id::create("env",this);endfunction
        task run_phase(uvm_phase phase);
            sched_sequence sequence_instance=sched_sequence::type_id::create("sequence_instance");
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
