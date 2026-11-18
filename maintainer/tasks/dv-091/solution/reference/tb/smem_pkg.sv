`timescale 1ns/1ps
package smem_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class smem_item extends uvm_sequence_item;
        `uvm_object_utils(smem_item)
        bit reset_request;
        bit short_reset;
        bit release_probe, pending_reset_probe;
        bit core_req_valid_i;
        bit [2:0] core_req_instrid_i;
        bit core_req_iswrite_i;
        bit [23:0] core_req_tag_i;
        bit [4:0] core_req_setidx_i;
        bit [3:0] core_req_activemask_i;
        bit [3:0] core_req_blockoffset_i;
        bit [15:0] core_req_wordoffset1h_i;
        bit [127:0] core_req_data_i;
        bit core_rsp_ready_i;

        function new(string name="smem_item");super.new(name);endfunction
    endclass
    class smem_sequence extends uvm_sequence #(smem_item);
        `uvm_object_utils(smem_sequence)
        virtual smem_if vif;
        function new(string name="smem_sequence");super.new(name);endfunction
        task send_reset();
            smem_item item=smem_item::type_id::create("reset");
            if(vif.stop_requested)return;
            start_item(item);item.reset_request=1;finish_item(item);
        endtask
        task send(bit valid,bit writing,bit [2:0] identity,bit [23:0] tag,bit [4:0] row,bit [3:0] lanes,bit [3:0] banks,bit [15:0] bytes,bit [127:0] words,bit ready);
            smem_item item=smem_item::type_id::create("request");
            if(vif.stop_requested)return;
            start_item(item);
            item.core_req_valid_i=valid;item.core_req_iswrite_i=writing;item.core_req_instrid_i=identity;
            item.core_req_tag_i=tag;item.core_req_setidx_i=row;item.core_req_activemask_i=lanes;
            item.core_req_blockoffset_i=banks;item.core_req_wordoffset1h_i=bytes;item.core_req_data_i=words;item.core_rsp_ready_i=ready;
            finish_item(item);
        endtask
        task drain();
            repeat(20)send(0,0,0,0,0,0,0,0,0,1);
        endtask
        task send_short_reset();
            smem_item item=smem_item::type_id::create("short_reset");
            if(vif.stop_requested)return;
            start_item(item);item.reset_request=1;item.short_reset=1;finish_item(item);
        endtask

        task memory_reset_witnesses();
            bit [31:0] bank_zero_word,bank_one_word;
            for(int row_index=0;row_index<128;row_index++)begin
                if(vif.stop_requested)return;
                drain();
                send_reset();
                drain();
                bank_zero_word=32'h12340000+row_index;
                bank_one_word=32'hfedc0000+row_index;
                send(1,1,row_index,row_index>>5,row_index,4'b0011,4'b0010,16'hffff,{64'b0,bank_one_word,bank_zero_word},1);
                drain();
                send(1,0,row_index,row_index>>5,row_index,4'b0011,4'b0010,16'hffff,0,0);
                repeat(8)send(0,0,0,0,0,0,0,0,0,0);
                if(vif.stop_requested)return;
                if(vif.expected_core_rsp_valid_o!==1'b1 || vif.expected_core_rsp_iswrite_o!==1'b0 || vif.expected_core_rsp_activemask_o!==4'b0011 || vif.expected_core_rsp_data_o[63:0]!=={bank_one_word,bank_zero_word})
                    `uvm_error("RESET_WITNESS_SETUP","Both bank words must be nonzero in a held read response before the short reset")
                drain();
                send_short_reset();
                drain();
                send(1,0,row_index,row_index>>5,row_index,4'b0011,4'b0010,16'hffff,0,0);
                repeat(8)send(0,0,0,0,0,0,0,0,0,0);
                if(vif.stop_requested)return;
                if(vif.expected_core_rsp_valid_o!==1'b1 || vif.expected_core_rsp_iswrite_o!==1'b0 || vif.expected_core_rsp_activemask_o!==4'b0011 || vif.expected_core_rsp_data_o[63:0]!==64'b0)
                    `uvm_error("RESET_WITNESS_READBACK","Both cleared bank words must be observed in a held read response after the short reset")
                drain();
            end
        endtask

        task pending_and_release_witnesses();
            smem_item item;
            for(int location=0;location<128;location++)begin
                if(vif.stop_requested)return;
                send_reset();drain();
                if(vif.expected_core_req_ready_o!==1'b1)
                    `uvm_error("PREP_NONVACUITY","Independent empty pipeline must accept a request")
                item=smem_item::type_id::create("reset_release_probe");
                start_item(item);item.release_probe=1;
                item.core_req_instrid_i=location;item.core_req_setidx_i=location;
                item.core_req_tag_i=location>>5;item.core_req_activemask_i=1 << (location%4);
                item.core_req_blockoffset_i=location;finish_item(item);
                drain();
                if(vif.stop_requested)return;
                if(vif.expected_core_rsp_valid_o!==1'b0 || vif.expected_core_rsp_data_o!==128'b0)
                    `uvm_error("RELEASE_NONVACUITY","No real acceptance edge means no response or memory access")
                send(1,0,location,location>>5,location,1 << (location%4),location,0,0,1);
                item=smem_item::type_id::create("pending_short_reset_probe");
                start_item(item);item.pending_reset_probe=1;finish_item(item);
                drain();
                if(vif.stop_requested)return;
                if(vif.expected_core_rsp_valid_o!==1'b0 || vif.expected_core_rsp_data_o!==128'b0)
                    `uvm_error("PENDING_RESET_NONVACUITY","Short asynchronous reset must cancel the accepted operation")
            end
        endtask

        task body();
            int unsigned random_value;
            if(!uvm_config_db#(virtual smem_if)::get(null,"","vif",vif))`uvm_fatal("CONFIG","Missing sequence interface")
            send_reset();
            for(int row_index=0;row_index<128;row_index++)begin
                send(1,1,row_index,row_index>>5,row_index,4'b0011,4'b0010,16'hffff,{$urandom,$urandom,32'hfedc0000+row_index,32'h12340000+row_index},1);
                drain();
                send(1,0,row_index,24'hfffffc|(row_index>>5),row_index,4'b1111,4'b1010,16'hffff,0,1);
                drain();
            end
            for(int mask=0;mask<16;mask++)begin
                for(int banks=0;banks<16;banks++)begin
                    send(1,1,mask,banks,mask,mask,banks,{4{4'(mask)}},{$urandom,$urandom,$urandom,$urandom},1);
                    drain();
                    send(1,0,banks,banks,mask,mask,banks,16'hffff,0,1);
                    drain();
                end
            end
            for(int iteration=0;iteration<7000;iteration++)begin
                random_value=$urandom;
                send(random_value[0],random_value[1],random_value[4:2],$urandom,$urandom,random_value[8:5],random_value[12:9],$urandom,{$urandom,$urandom,$urandom,$urandom},random_value[13]);
                if(iteration==731 || iteration==3011)send_reset();
                if(iteration==2001)send_short_reset();
            end
            memory_reset_witnesses();
            pending_and_release_witnesses();
            send_reset();
            drain();

        endtask
    endclass
    class smem_driver extends uvm_driver #(smem_item);
        `uvm_component_utils(smem_driver)
        virtual smem_if vif;
        function new(string name,uvm_component parent);super.new(name,parent);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual smem_if)::get(this,"","vif",vif))`uvm_fatal("CONFIG","Missing driver interface")
        endfunction
        task run_phase(uvm_phase phase);
            smem_item item;
            forever begin
                seq_item_port.get_next_item(item);
                @(negedge vif.clk);
                if(item.release_probe || item.pending_reset_probe)begin
                    vif.checking=1;
                    vif.core_req_valid_i=0;vif.core_rsp_ready_i=1;
                    #1;vif.rst_n=0;
                    #1;
                    if(item.release_probe)begin
                        vif.core_req_valid_i=1;vif.core_req_iswrite_i=0;
                        vif.core_req_instrid_i=item.core_req_instrid_i;
                        vif.core_req_setidx_i=item.core_req_setidx_i;
                        vif.core_req_tag_i=item.core_req_tag_i;
                        vif.core_req_activemask_i=item.core_req_activemask_i;
                        vif.core_req_blockoffset_i=item.core_req_blockoffset_i;
                        vif.core_req_wordoffset1h_i=0;vif.core_req_data_i=0;
                    end
                    #1;vif.rst_n=1;
                    #1;vif.core_req_valid_i=0;
                    @(posedge vif.clk);#2;
                end else if(item.reset_request)begin
                    vif.checking=1;
                    #2 vif.rst_n=0;
                    if(item.short_reset)begin #2;vif.rst_n=1;end
                    else begin repeat(3)@(posedge vif.clk);@(negedge vif.clk);vif.rst_n=1;end
                end else begin
                    vif.core_req_valid_i=item.core_req_valid_i;
                    vif.core_req_instrid_i=item.core_req_instrid_i;
                    vif.core_req_iswrite_i=item.core_req_iswrite_i;
                    vif.core_req_tag_i=item.core_req_tag_i;
                    vif.core_req_setidx_i=item.core_req_setidx_i;
                    vif.core_req_activemask_i=item.core_req_activemask_i;
                    vif.core_req_blockoffset_i=item.core_req_blockoffset_i;
                    vif.core_req_wordoffset1h_i=item.core_req_wordoffset1h_i;
                    vif.core_req_data_i=item.core_req_data_i;
                    vif.core_rsp_ready_i=item.core_rsp_ready_i;

                    @(posedge vif.clk);#2;
                end
                seq_item_port.item_done();
            end
        endtask
    endclass
    class smem_sample extends uvm_sequence_item;
        `uvm_object_utils(smem_sample)
        logic actual_core_req_ready_o;
        logic expected_core_req_ready_o;
        logic actual_core_rsp_valid_o;
        logic expected_core_rsp_valid_o;
        logic actual_core_rsp_iswrite_o;
        logic expected_core_rsp_iswrite_o;
        logic [2:0] actual_core_rsp_instrid_o;
        logic [2:0] expected_core_rsp_instrid_o;
        logic [127:0] actual_core_rsp_data_o;
        logic [127:0] expected_core_rsp_data_o;
        logic [3:0] actual_core_rsp_activemask_o;
        logic [3:0] expected_core_rsp_activemask_o;

        bit asynchronous_reset;
        function new(string name="smem_sample");super.new(name);endfunction
    endclass
    class smem_monitor extends uvm_monitor;
        `uvm_component_utils(smem_monitor)
        virtual smem_if vif;
        uvm_analysis_port #(smem_sample) samples;
        function new(string name,uvm_component parent);super.new(name,parent);samples=new("samples",this);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual smem_if)::get(this,"","vif",vif))`uvm_fatal("CONFIG","Missing monitor interface")
        endfunction
        task sample_ports(bit asynchronous_reset);
            smem_sample sample=smem_sample::type_id::create("sample");
            #1;
            if(vif.checking)begin
                sample.actual_core_req_ready_o=vif.core_req_ready_o;sample.expected_core_req_ready_o=vif.expected_core_req_ready_o;
                sample.actual_core_rsp_valid_o=vif.core_rsp_valid_o;sample.expected_core_rsp_valid_o=vif.expected_core_rsp_valid_o;
                sample.actual_core_rsp_iswrite_o=vif.core_rsp_iswrite_o;sample.expected_core_rsp_iswrite_o=vif.expected_core_rsp_iswrite_o;
                sample.actual_core_rsp_instrid_o=vif.core_rsp_instrid_o;sample.expected_core_rsp_instrid_o=vif.expected_core_rsp_instrid_o;
                sample.actual_core_rsp_data_o=vif.core_rsp_data_o;sample.expected_core_rsp_data_o=vif.expected_core_rsp_data_o;
                sample.actual_core_rsp_activemask_o=vif.core_rsp_activemask_o;sample.expected_core_rsp_activemask_o=vif.expected_core_rsp_activemask_o;

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
    class smem_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(smem_scoreboard)
        virtual smem_if vif;
        uvm_analysis_imp #(smem_sample,smem_scoreboard) samples;
        int unsigned checks,failures,reset_checks;
        function new(string name,uvm_component parent);super.new(name,parent);samples=new("samples",this);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual smem_if)::get(this,"","vif",vif))`uvm_fatal("CONFIG","Missing scoreboard interface")
        endfunction
        function void write(smem_sample sample);
            bit mismatch=0;
            reset_checks+=sample.asynchronous_reset;
            checks++;if(sample.actual_core_req_ready_o!==sample.expected_core_req_ready_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("core_req_ready_o=%h/%h async_reset=%b",sample.actual_core_req_ready_o,sample.expected_core_req_ready_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_core_rsp_valid_o!==sample.expected_core_rsp_valid_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("core_rsp_valid_o=%h/%h async_reset=%b",sample.actual_core_rsp_valid_o,sample.expected_core_rsp_valid_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_core_rsp_iswrite_o!==sample.expected_core_rsp_iswrite_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("core_rsp_iswrite_o=%h/%h async_reset=%b",sample.actual_core_rsp_iswrite_o,sample.expected_core_rsp_iswrite_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_core_rsp_instrid_o!==sample.expected_core_rsp_instrid_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("core_rsp_instrid_o=%h/%h async_reset=%b",sample.actual_core_rsp_instrid_o,sample.expected_core_rsp_instrid_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_core_rsp_data_o!==sample.expected_core_rsp_data_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("core_rsp_data_o=%h/%h async_reset=%b",sample.actual_core_rsp_data_o,sample.expected_core_rsp_data_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_core_rsp_activemask_o!==sample.expected_core_rsp_activemask_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("core_rsp_activemask_o=%h/%h async_reset=%b",sample.actual_core_rsp_activemask_o,sample.expected_core_rsp_activemask_o,sample.asynchronous_reset))end

            if(mismatch)begin
                failures++;
                vif.stop_requested=1;
            end
        endfunction
        function void check_phase(uvm_phase phase);
            super.check_phase(phase);
            if(failures==0 && (checks<100000 || reset_checks<3))`uvm_error("VACUOUS","Required comparison windows did not execute")
            if(failures>20)`uvm_error("MISMATCH_TOTAL",$sformatf("Total failed samples=%0d",failures))
        endfunction
    endclass
    class smem_env extends uvm_env;
        `uvm_component_utils(smem_env)
        uvm_sequencer #(smem_item) sequencer;
        smem_driver driver;
        smem_monitor monitor;
        smem_scoreboard scoreboard;
        function new(string name,uvm_component parent);super.new(name,parent);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sequencer=uvm_sequencer#(smem_item)::type_id::create("sequencer",this);
            driver=smem_driver::type_id::create("driver",this);
            monitor=smem_monitor::type_id::create("monitor",this);
            scoreboard=smem_scoreboard::type_id::create("scoreboard",this);
        endfunction
        function void connect_phase(uvm_phase phase);
            driver.seq_item_port.connect(sequencer.seq_item_export);
            monitor.samples.connect(scoreboard.samples);
        endfunction
    endclass
    class dvbench_test extends uvm_test;
        `uvm_component_utils(dvbench_test)
        smem_env env;
        function new(string name,uvm_component parent);super.new(name,parent);endfunction
        function void build_phase(uvm_phase phase);super.build_phase(phase);env=smem_env::type_id::create("env",this);endfunction
        task run_phase(uvm_phase phase);
            smem_sequence sequence_instance=smem_sequence::type_id::create("sequence_instance");
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
