`timescale 1ns/1ps
package cq_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class cq_item extends uvm_sequence_item;
        `uvm_object_utils(cq_item)
        bit reset_request;
        bit short_reset;
        bit write_valid;
        bit read_ready;
        bit [6:0] write_data;
        bit [31:0] power_pattern;
        function new(string name="cq_item"); super.new(name); endfunction
    endclass
    class cq_sequence extends uvm_sequence #(cq_item);
        `uvm_object_utils(cq_sequence)
        virtual cq_if vif;
        function new(string name="cq_sequence"); super.new(name); endfunction
        task send_cycle(bit write_valid,bit read_ready,bit [6:0] write_data,bit [31:0] power_pattern);
            cq_item item=cq_item::type_id::create("cycle");
            if(vif.stop_requested) return;
            start_item(item);
            item.write_valid=write_valid;
            item.read_ready=read_ready;
            item.write_data=write_data;
            item.power_pattern=power_pattern;
            finish_item(item);
        endtask
        task send_reset();
            cq_item item=cq_item::type_id::create("reset");
            if(vif.stop_requested) return;
            start_item(item);
            item.reset_request=1;
            finish_item(item);
        endtask
        task send_short_reset();
            cq_item item=cq_item::type_id::create("short_reset");
            if(vif.stop_requested) return;
            start_item(item);
            item.reset_request=1;
            item.short_reset=1;
            finish_item(item);
        endtask
        task short_reset_witnesses();
            int completed_cases;
            completed_cases=0;
            for(int prior_writes=1;prior_writes<=256;prior_writes++)begin
                if(vif.stop_requested) return;
                send_reset();
                for(int write_index=0;write_index<prior_writes;write_index++)
                    send_cycle(1,1,write_index%128,0);
                repeat(3) send_cycle(0,1,0,0);
                if(vif.expected_valid !== 1'b0 || vif.expected_ready !== 1'b1)
                    `uvm_error("PROBE_VACUITY","Independent queue failed to drain before short reset")
                send_short_reset();
                send_cycle(1,0,7'h7f,32'hffffffff);
                send_cycle(0,0,0,0);
                if(!vif.stop_requested && (vif.expected_valid !== 1'b1 || vif.expected_data !== 7'h7f))
                    `uvm_error("PROBE_VACUITY","Independent queue failed post-reset isolated readback")
                send_cycle(0,1,0,0);
                completed_cases++;
            end
            if(!vif.stop_requested && completed_cases!=256)
                `uvm_error("PROBE_VACUITY","Short reset pointer matrix incomplete")
        endtask
        
        task body();
            int unsigned random_value;
            if(!uvm_config_db#(virtual cq_if)::get(null,"","vif",vif)) `uvm_fatal("CONFIG","Missing sequence interface")
            send_reset();
            for(int phase_index=0;phase_index<3;phase_index++) begin
                for(int cycle_index=0;cycle_index<300;cycle_index++)
                    send_cycle(1,0,cycle_index^(phase_index*39),cycle_index[0]?32'h55555555:32'haaaaaaaa);
                repeat(20) send_cycle(1,0,7'h7f,32'hffffffff);
                repeat(5) send_cycle(1,1,7'h31,32'h12345678);
                repeat(5) send_cycle(1,0,7'h72,32'h87654321);
                for(int cycle_index=0;cycle_index<350;cycle_index++) send_cycle(0,1,cycle_index,0);
                repeat(10) send_cycle(0,1,0,0);
            end
            for(int cycle_index=0;cycle_index<3000;cycle_index++) begin
                random_value=$urandom;
                send_cycle(random_value[0],random_value[1],random_value[8:2],$urandom);
                if(cycle_index==731 || cycle_index==1771) send_reset();
            end
            repeat(300) send_cycle(0,1,0,0);
            repeat(10) send_cycle(0,0,0,32'hffffffff);
            send_reset();
            repeat(10) send_cycle(1,1,7'h36,0);
            repeat(20) send_cycle(0,1,0,0);
            short_reset_witnesses();
        endtask
    endclass
    class cq_driver extends uvm_driver #(cq_item);
        `uvm_component_utils(cq_driver)
        virtual cq_if vif;
        function new(string name,uvm_component parent); super.new(name,parent); endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual cq_if)::get(this,"","vif",vif)) `uvm_fatal("CONFIG","Missing native port interface")
        endfunction
        task run_phase(uvm_phase phase);
            cq_item item;
            forever begin
                seq_item_port.get_next_item(item);
                @(negedge vif.clk);
                if(item.reset_request) begin
                    vif.checking=1;
                    #2 vif.rstn=0;
                    vif.write_valid=1;
                    vif.read_ready=1;
                    vif.write_data=7'h55;
                    vif.power_pattern=32'hffffffff;
                    if(item.short_reset) begin
                        vif.write_valid=0;
                        vif.read_ready=0;
                        #2;
                    end else begin
                        repeat(3) @(posedge vif.clk);
                        @(negedge vif.clk);
                    end
                    vif.rstn=1;
                    vif.write_valid=0;
                    vif.read_ready=0;
                end else begin
                    vif.write_valid=item.write_valid;
                    vif.read_ready=item.read_ready;
                    vif.write_data=item.write_data;
                    vif.power_pattern=item.power_pattern;
                    @(posedge vif.clk);
                    #2;
                end
                seq_item_port.item_done();
            end
        endtask
    endclass
    class cq_sample extends uvm_sequence_item;
        `uvm_object_utils(cq_sample)
        logic actual_ready,actual_valid,expected_ready,expected_valid;
        logic [6:0] actual_data,expected_data;
        bit asynchronous_reset;
        function new(string name="cq_sample"); super.new(name); endfunction
    endclass
    class cq_monitor extends uvm_monitor;
        `uvm_component_utils(cq_monitor)
        virtual cq_if vif;
        uvm_analysis_port #(cq_sample) samples;
        function new(string name,uvm_component parent); super.new(name,parent); samples=new("samples",this); endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual cq_if)::get(this,"","vif",vif)) `uvm_fatal("CONFIG","Missing native port interface")
        endfunction
        task sample_ports(bit asynchronous_reset);
            cq_sample sample=cq_sample::type_id::create("sample");
            #1;
            if(vif.checking) begin
                sample.actual_ready=vif.write_ready;
                sample.actual_valid=vif.read_valid;
                sample.actual_data=vif.read_data;
                sample.expected_ready=vif.expected_ready;
                sample.expected_valid=vif.expected_valid;
                sample.expected_data=vif.expected_data;
                sample.asynchronous_reset=asynchronous_reset;
                samples.write(sample);
            end
        endtask
        task run_phase(uvm_phase phase);
            fork
                forever begin @(posedge vif.clk); sample_ports(0); end
                forever begin @(negedge vif.rstn); sample_ports(1); end
            join
        endtask
    endclass
    class cq_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(cq_scoreboard)
        uvm_analysis_imp #(cq_sample,cq_scoreboard) samples;
        int unsigned checks,failures,reset_checks,valid_checks;
        virtual cq_if vif;
        function new(string name,uvm_component parent); super.new(name,parent); samples=new("samples",this); endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual cq_if)::get(this,"","vif",vif)) `uvm_fatal("CONFIG","Missing scoreboard interface")
        endfunction
        function void write(cq_sample sample);
            bit mismatch;
            checks+=2;
            reset_checks+=sample.asynchronous_reset;
            mismatch=sample.actual_ready!==sample.expected_ready || sample.actual_valid!==sample.expected_valid;
            if(sample.expected_valid===1'b1) begin
                checks++;
                valid_checks++;
                mismatch|=sample.actual_data!==sample.expected_data;
            end
            if(mismatch) begin
                failures++;
                vif.stop_requested=1;
                if(failures<=20) `uvm_error("NATIVE_MISMATCH",$sformatf("ready=%b/%b valid=%b/%b data=%h/%h async_reset=%b",sample.actual_ready,sample.expected_ready,sample.actual_valid,sample.expected_valid,sample.actual_data,sample.expected_data,sample.asynchronous_reset))
            end
        endfunction
        function void check_phase(uvm_phase phase);
            super.check_phase(phase);
            if(failures==0 && (checks<10000 || reset_checks<4 || valid_checks<1000)) `uvm_error("VACUOUS","Required port comparison windows did not execute")
            if(failures>20) `uvm_error("MISMATCH_TOTAL",$sformatf("Total failed samples=%0d",failures))
        endfunction
    endclass
    class cq_env extends uvm_env;
        `uvm_component_utils(cq_env)
        uvm_sequencer #(cq_item) sequencer;
        cq_driver driver;
        cq_monitor monitor;
        cq_scoreboard scoreboard;
        function new(string name,uvm_component parent); super.new(name,parent); endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sequencer=uvm_sequencer#(cq_item)::type_id::create("sequencer",this);
            driver=cq_driver::type_id::create("driver",this);
            monitor=cq_monitor::type_id::create("monitor",this);
            scoreboard=cq_scoreboard::type_id::create("scoreboard",this);
        endfunction
        function void connect_phase(uvm_phase phase);
            driver.seq_item_port.connect(sequencer.seq_item_export);
            monitor.samples.connect(scoreboard.samples);
        endfunction
    endclass
    class dvbench_test extends uvm_test;
        `uvm_component_utils(dvbench_test)
        cq_env env;
        function new(string name,uvm_component parent); super.new(name,parent); endfunction
        function void build_phase(uvm_phase phase); super.build_phase(phase); env=cq_env::type_id::create("env",this); endfunction
        task run_phase(uvm_phase phase);
            cq_sequence sequence_instance=cq_sequence::type_id::create("sequence_instance");
            phase.raise_objection(this);
            sequence_instance.start(env.sequencer);
            #20;
            phase.drop_objection(this);
        endtask
        function void report_phase(uvm_phase phase);
            uvm_report_server server=uvm_report_server::get_server();
            super.report_phase(phase);
            `uvm_info("CHECK_COUNTS",$sformatf("checks=%0d failures=%0d reset_checks=%0d valid_checks=%0d",env.scoreboard.checks,env.scoreboard.failures,env.scoreboard.reset_checks,env.scoreboard.valid_checks),UVM_NONE)
            if(server.get_severity_count(UVM_ERROR)==0 && server.get_severity_count(UVM_FATAL)==0) $display("DVBench_COMPLETED");
        endfunction
    endclass
endpackage
